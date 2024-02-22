#==============================================================================
# ** Alchemy
#------------------------------------------------------------------------------
#  This module is for the alchemy system.
#==============================================================================

module Alchemy
	#--------------------------------------------------------------------------
	# * Substance Constants (refers to system elements)
	#--------------------------------------------------------------------------
	Vitriol 	= 112
	Calamine 	= 113
	Rebis 		= 114
	Orpiment	= 115
	Realgar		= 116
	List		= [Vitriol, Calamine, Rebis, Orpiment, Realgar]
	Names		= ["Vitriol", "Calamine", "Rebis", "Orpiment", "Realgar"]
	#--------------------------------------------------------------------------
	# * Substance Icons
	#--------------------------------------------------------------------------
	Icons = [
		"Framework/Vitriol",
		"Framework/Calamine",
		"Framework/Rebis",
		"Framework/Orpiment",
		"Framework/Realgar"
	]
	#--------------------------------------------------------------------------
	# * Recipes Constant 
	# => A => B
	# => A : the ID of the result elixir
	# => B : the array of amounts of substances needed (see List above)
	#--------------------------------------------------------------------------
	Recipes = {
		114 => [2, 1, 0, 0, 0],
		115 => [1, 1, 1, 0, 0]
	}
	#--------------------------------------------------------------------------
	# * Descriptions of Elixirs
	#--------------------------------------------------------------------------
	Descriptions = {
		114 => "When you activate an ability that costs Mind, " + 
				"but don’t have enough, the ability will still activate.",
		115 => "When you use Enduring Strike, you gain a Bone Barrier for " +
				"5 seconds that restores 86 Health to you when you are hit."
	}
	#--------------------------------------------------------------------------
	# * Is reagent?
	#--------------------------------------------------------------------------
	def Alchemy.is_reagent?(item)
		for substance in List
			return true if item.element_set.include?(substance)
		end
		false
	end
	#--------------------------------------------------------------------------
	# * Brews an Elixir
	# => Returns true if successful, false if not
	#--------------------------------------------------------------------------
	def brew(recipe_id, ingredients)
		# Get recipe
		recipe = Recipes[recipe_id].clone
		# Setup used list
		used = []
		# Check all ingredients
		for item_id in ingredients
			# Break if recipe done
			done = true
			for s in recipe
				done = false if s > 0
			end
			break if done
			# Get the item
			item = $data_items[item_id]
			# Find the substances for this item
			subs = get_substances(item)
			# Subtract from recipe
			u = false
			for s in subs
				if recipe[List.index(s)] > 0
					recipe[List.index(s)] -= 1
					u = true
				end
			end
			# Add to used list
			used << item_id if u
		end
		# Check if all required substances were met
		success = true
		for n in recipe
			if n > 0
				success = false
				break
			end
		end
		# If successful: manage items
		if success
			for item_id in used
				ingredients.delete_at(ingredients.index(item_id))
			end
			$game_party.gain_item(recipe_id, 1, true)
		end
		# Return the success state
		success
	end
	#--------------------------------------------------------------------------
	# * Get Substances
	# => Returns an Array of substances for this item
	#--------------------------------------------------------------------------
	def get_substances(item)
		arry = []
		for substance in item.element_set
			arry << substance if List.include?(substance)
		end
		arry
	end
end

#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  Extension to party object to save Alchemy data.
#==============================================================================

class Game_Party
	#-------------------------------------------------------------------------
	# * Alias Methods
	#-------------------------------------------------------------------------
	alias_method(:sarkilas_alchemy_party_init, :initialize)
	#-------------------------------------------------------------------------
	# * Object Initialization
	#-------------------------------------------------------------------------
	def initialize
		sarkilas_alchemy_party_init
		setup_recipes
	end
	#-------------------------------------------------------------------------
	# * Setup Recipes
	#-------------------------------------------------------------------------
	def setup_recipes
		@learned_recipes = [114,115] if @learned_recipes.nil?
	end
	#-------------------------------------------------------------------------
	# * Learn Recipe
	#-------------------------------------------------------------------------
	def learn_recipe(item_id)
		setup_recipes
		@learned_recipes << item_id
		@learned_recipes.sort!
	end
	#-------------------------------------------------------------------------
	# * Get Learned Recipes
	#-------------------------------------------------------------------------
	def learned_recipes
		setup_recipes
		@learned_recipes
	end
end

#==============================================================================
# ** Alchemy_Tooltip
#------------------------------------------------------------------------------
#  This component displays tooltips for elixirs or ingredients.
#==============================================================================

class Alchemy_Tooltip < Interface::Tooltip
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(item_id)
		@item = $data_items[item_id]
		calculate_dimensions
		super(0, 0, @width, @height)
		self.objects.each {|obj| obj.z += 9000 unless obj.nil?}
		refresh
		self.visible = false
		self.z = 99999
	end
	#--------------------------------------------------------------------------
	# * Refresh
	#--------------------------------------------------------------------------
	def refresh
		# Create contents
		@contents = Sprite.new
		@contents.x = @x
		@contents.y = @y
		@contents.z = self.objects[0].z + 5000
		# Create bitmap
		bitmap = Bitmap.new(@width, @height)
		# Set up drawing point
		y = 4
		# Draw item name
		bitmap.font.color = Color.new(255, 231, 156, 255)
		bitmap.draw_text(4, y, @width - 8, @dim.height, @item.name)
		y += @dim.height + 2
		# Get type (0 = elixir, 1 = reagent)
		type = @item.element_set.include?(111) ? 0 : 1
		# Get substance data
		data = get_substances(type)
		# Draw icons only if elixir
		x = 4
		if type == 0
			for i in 0...data.size
				next if data[i] == 0
				while data[i] > 0
					icon = RPG::Cache.gui(Alchemy::Icons[i])					
					bitmap.blt(x, y, icon, Rect.new(0, 0, 
						icon.width, icon.height))
					x += icon.width + 4
					data[i] -= 1
				end
			end
		else
			for i in 0...data.size
				next if data[i] == 0
				icon = RPG::Cache.gui(Alchemy::Icons[i])
				bitmap.blt(x, y, icon, Rect.new(0, 0,
					icon.width, icon.height))
				x += icon.width + 4
			end
		end
		# Add to Y
		y += 26
		# Draw charges if elixir
		if type == 0
			bitmap.font.color = Color.new(255, 128, 66)
			bitmap.draw_text(4, y, @width - 8, @dim.height, "#{@item.price} charges")
			y += @dim.height + 2
		end
		# Draw description
		bitmap.font.color = Color.new(255, 255, 255)
		@lines.each_line do |line|
			bitmap.draw_text(4, y, @width - 8, @dim.height, line)
			y += @dim.height + 2
		end
		# Set bitmap
		@contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Get Substances
	#--------------------------------------------------------------------------
	def get_substances(type)
		# Elixir type
		if type == 0
			return Alchemy::Recipes[@item.id].clone
		else
			arry = []
			arry[0] = @item.element_set.include?(112) ? 1 : 0
			arry[1] = @item.element_set.include?(113) ? 1 : 0
			arry[2] = @item.element_set.include?(114) ? 1 : 0
			arry[3] = @item.element_set.include?(115) ? 1 : 0
			arry[4] = @item.element_set.include?(116) ? 1 : 0
		end
		# Return array
		arry
	end
	#--------------------------------------------------------------------------
	# * Calculate Dimensions
	#--------------------------------------------------------------------------
	def calculate_dimensions
		# Create temp bitmap
		temp = Bitmap.new(640, 480)
		# Get base values
		@dim = temp.text_size(@item.name)
		# Start off dimensions
		@width = @dim.width
		@height = @dim.height + 8
		# Get type (0 = elixir, 1 = reagent)
		type = @item.element_set.include?(111) ? 0 : 1
		# Add line for substances
		@height += 34
		# Collect lines
		if type == 0
			@height += @dim.height + 2
			@lines = Kernel.wrap_text(Alchemy::Descriptions[@item.id], 33)
		else
			@lines = Kernel.wrap_text(@item.description, 33)
		end
		# Add height and fix width
		@lines.each_line do |line|
			size = temp.text_size(line)
			@width = size.width > @width ? size.width : @width
			@height += @dim.height + 2
		end
		# Add a bit to width
		@width += 16
	end
	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update
		# Super
		super
		# Set visible flag for contents
		@contents.visible = self.visible
		# Ignore if invisible
		return unless self.visible
		# Update location
		self.x = Mouse.x + 24
		self.y = Mouse.y + 24
		# Snap
		self.x = self.x > 640 - @width ? 640 - @width : self.x
		self.y = self.y > 480 - @height ? 480 - @height : self.y
	end
	#--------------------------------------------------------------------------
	# * Objects
	#--------------------------------------------------------------------------
	def objects
		a = super
		a << @contents
		a
	end
end

#==============================================================================
# ** Window_Recipes
#------------------------------------------------------------------------------
#  This window is for viewing and selecting recipes.
#==============================================================================

class Window_Recipes < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y, width, height)
		super(x, y, width, height)
		refresh
		@fade_in = true
	end
	#--------------------------------------------------------------------------
	# * Refresh
	#--------------------------------------------------------------------------
	def refresh
		# Call superclass 
		super
		# Create bitmap
		bitmap = Bitmap.new(@width, @height)
		# Draw all learned recipes
		@data = $game_party.learned_recipes
		for i in 0...@data.size
			draw_item(i, bitmap)
		end
		# Set bitmap
		self.contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Draw Item
	#--------------------------------------------------------------------------
	def draw_item(index, bitmap)
		# Get item
		item = $data_items[@data[index]]
		# Get rect
		rect = item_rect(index)
		# Get the icon
		icon = RPG::Cache.icon(item.icon_name)
		src = Rect.new(0, 0, icon.width, icon.height)
		# Draw the icon to the bitmap
		bitmap.blt(4 + 16 - icon.width / 2, 
			34 * index + 20 - icon.height / 2, icon, src)
		# Draw the text
		bitmap.draw_text(38, 4 + 34 * index, 
			rect.width, rect.height, item.name)
		# Draw number
		n = $game_party.item_number(item.id)
		color = n > 0 ? Color.new(255, 231, 156, 255) : Color.new(255, 100, 100)
		bitmap.font.color = color
		bitmap.draw_text(0, 4 + 34 * index, @width - 8, rect.height, n.to_s, 2)
		bitmap.font.color = Color.new(255, 255, 255)
	end
end

#==============================================================================
# ** Window_Reagents
#------------------------------------------------------------------------------
#  This window is for viewing and removing reagents for brewing.
#==============================================================================

class Window_Reagents < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y, width, height)
		super(x, y, width, height)
		refresh
		@fade_in = true
	end
	#--------------------------------------------------------------------------
	# * Refresh
	#--------------------------------------------------------------------------
	def refresh
		# Call superclass 
		super
		# Create bitmap
		bitmap = Bitmap.new(@width, @height)
		# Draw all learned recipes
		for i in 0...@data.size
			draw_item(i, bitmap)
		end
		# Draw the total substances
		x = 4
		for id in @data
			# Get item
			item = $data_items[id]
			# Get substances for item
			subs = get_substances(item)
			# Iterate all substances
			for i in 0...subs.size
				# Ignore if no substance of type
				next if subs[i] == 0
				# Get icon data
				icon = RPG::Cache.gui(Alchemy::Icons[i])
				src = Rect.new(0, 0, icon.width, icon.height)
				# Draw substance icon
				bitmap.blt(x, @height - 4 - 16 - icon.height / 2, icon, src)
				# Add to X
				x += icon.width
			end
		end
		# Set bitmap
		self.contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Draw Item
	#--------------------------------------------------------------------------
	def draw_item(index, bitmap)
		# Get item
		item = $data_items[@data[index]]
		# Get rect
		rect = item_rect(index)
		# Get the icon
		icon = RPG::Cache.icon(item.icon_name)
		src = Rect.new(0, 0, icon.width, icon.height)
		# Draw the icon to the bitmap
		bitmap.blt(4, 34 * index + 20 - icon.height / 2, icon, src)
		# Get substances
		subs = get_substances(item)
		# Draw all substances
		x = 4 + icon.width
		for i in 0...subs.size
			# Ignore if no substance of type
			next if subs[i] == 0
			# Get icon data
			icon = RPG::Cache.gui(Alchemy::Icons[i])
			src = Rect.new(0, 0, icon.width, icon.height)
			# Draw substance icon
			bitmap.blt(x, 34 * index + 20 - icon.height / 2, icon, src)
			# Add to X
			x += icon.width
		end
	end
	#--------------------------------------------------------------------------
	# * Get Substances
	#--------------------------------------------------------------------------
	def get_substances(item)
		# Generate array
		arry = []
		arry[0] = item.element_set.include?(112) ? 1 : 0
		arry[1] = item.element_set.include?(113) ? 1 : 0
		arry[2] = item.element_set.include?(114) ? 1 : 0
		arry[3] = item.element_set.include?(115) ? 1 : 0
		arry[4] = item.element_set.include?(116) ? 1 : 0
		# Return array
		arry
	end
end

#==============================================================================
# ** Window_ReagentSelect
#------------------------------------------------------------------------------
#  This window is for viewing all reagents you possess and select them.
#==============================================================================

class Window_ReagentSelect < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y, width, height, columns)
		@columns = columns
		super(x, y, width, height)
		refresh
		@fade_in = true
		self.z = 99000
	end
	#--------------------------------------------------------------------------
	# * Refresh
	#--------------------------------------------------------------------------
	def refresh
		# Call superclass 
		super
		# Set up data
		@data = []
		for item in $data_items
			next if $game_party.item_number(item.id) == 0
			@data << item.id if Alchemy.is_reagent?(item)
		end
		# Create bitmap
		bitmap = Bitmap.new(@width, @height)
		# Draw all learned recipes
		for i in 0...@data.size
			draw_item(i, bitmap)
		end
		# Set bitmap
		self.contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Draw Item
	#--------------------------------------------------------------------------
	def draw_item(index, bitmap)
		# Get item
		item = $data_items[@data[index]]
		# Get rect
		rect = item_rect(index)
		# Get the icon
		icon = RPG::Cache.icon(item.icon_name)
		src = Rect.new(0, 0, icon.width, icon.height)
		# Get coordinates
		x = 4 + 32 * (index % @columns)
		y = 4 + 32 * (index / @columns)
		# Draw the icon to the bitmap
		bitmap.blt(x + 16 - icon.width / 2, y + 16 - icon.height / 2, icon, src)
		# Draw amount
		size = bitmap.text_size($game_party.item_number(item.id).to_s)
		bitmap.draw_text(x + 30 - size.width, y + 30 - size.height, 
			size.width, size.height, $game_party.item_number(item.id).to_s)
	end
	#--------------------------------------------------------------------------
	# * Item Rect
	#--------------------------------------------------------------------------
	def item_rect(index)
		cx = @x + 4 + (32 * (index % @columns))
		cy = @y + 4 + (32 * (index / @columns))
		Rect.new(cx, cy, 32, 32)
	end
end

#==============================================================================
# ** Scene_Alchemy
#------------------------------------------------------------------------------
#  This scene for the Alchemy system.
#==============================================================================

class Scene_Alchemy
	#--------------------------------------------------------------------------
	# * Module Inclusion
	#--------------------------------------------------------------------------
	include Alchemy
	#--------------------------------------------------------------------------
	# * Main Method
	#--------------------------------------------------------------------------
	def main
		# Create spriteset
		@spriteset = Spriteset_Map.new
		# Create the interface
		create_interface
		# Create tooltips
		create_tooltips
		# Transition graphics
		Graphics.transition
		# Main loop
		loop do
			# Update game screen
		    Graphics.update
		    # Update input information
		    Input.update
		    # Update mouse
		    $mouse.update
		    # Frame update
		    update
		    # Abort loop if screen is changed
		    if $scene != self
		    	break
		    end
		end
		# Freeze the graphics
		Graphics.freeze
		# Dispose spriteset
		@spriteset.dispose
		# Dispose elements
		dispose_interface
	end
	#--------------------------------------------------------------------------
	# * Create Interface
	#--------------------------------------------------------------------------
	def create_interface
		create_windows
		create_buttons
		create_dialogs
	end
	#--------------------------------------------------------------------------
	# * Create Windows
	#--------------------------------------------------------------------------
	def create_windows
		# Set up windows hash
		@windows = {}
		# Create recipe list
		@windows['recipes'] = Window_Recipes.new(96, 96, 280, 288)
		# Create reagent list
		@windows['reagents'] = Window_Reagents.new(376, 96, 168, 228)
		# Create reagent selector
		win = Window_ReagentSelect.new(204, 172, 232, 136, 7)
		win.visible = false
		@windows['select'] = win
	end
	#--------------------------------------------------------------------------
	# * Create Buttons
	#--------------------------------------------------------------------------
	def create_buttons
		# Set up buttons hash
		@buttons = {}
		# Add reagent
		add = Interface::Button.new(376, 324, 168, "Add Reagent")
		add.bind(Proc.new {
			@windows['select'].visible = true
		})
		@buttons['add'] = add
		# Clear reagents
		clear = Interface::Button.new(376, 354, 168, "Clear Reagents")
		clear.bind(Proc.new {
			@dialogs['clear'].visible = true
		})
		@buttons['clear'] = clear
	end
	#--------------------------------------------------------------------------
	# * Create Dialogs
	#--------------------------------------------------------------------------
	def create_dialogs
		# Set up dialogs hash
		@dialogs = {}
		# Missing substances dialog
		missing = Interface::Dialog.new(240, 100, 
			"The reagent substances do not match the recipe.", "OK")
		missing.bind(0, Proc.new { 
			Graphics.freeze
			@dialogs['missing'].opacity = 0
			@dialogs['missing'].visible = false
			Graphics.transition
		})
		@dialogs['missing'] = missing
		# Remove reagent dialog
		remove = Interface::Dialog.new(240, 100, 
			"Remove this reagent?", "Yes", "No")
		remove.bind(0, Proc.new {
			$game_party.gain_item(@windows['reagents'].item, 1, true)
			@windows['reagents'].remove_item(@windows['reagents'].index)
			@windows['reagents'].refresh
			@windows['select'].refresh
			Graphics.freeze
			@dialogs['remove'].opacity = 0
			@dialogs['remove'].visible = false
			Graphics.transition
		})
		remove.bind(1, Proc.new {
			Graphics.freeze
			@dialogs['remove'].opacity = 0
			@dialogs['remove'].visible = false
			Graphics.transition
		})
		@dialogs['remove'] = remove
		# Clear reagents dialog
		clear = Interface::Dialog.new(240, 100, 
			"Clear all reagents?", "Yes", "No")
		clear.bind(0, Proc.new {
			for item in @windows['reagents'].items
				$game_party.gain_item(item, 1, true)
			end
			@windows['reagents'].set_data([])
			@windows['reagents'].refresh
			@windows['select'].refresh
			Graphics.freeze
			@dialogs['clear'].opacity = 0
			@dialogs['clear'].visible = false
			Graphics.transition
		})
		clear.bind(1, Proc.new {
			Graphics.freeze
			@dialogs['clear'].opacity = 0
			@dialogs['clear'].visible = false
			Graphics.transition
		})
		@dialogs['clear'] = clear
		# Brew dialog
		make = Interface::Dialog.new(240, 100, "Brew this elixir?", "Yes", "No")
		make.bind(0, Proc.new {
			success = brew(@windows['recipes'].item, @windows['reagents'].items)
			if success
				@windows['reagents'].refresh
				@windows['recipes'].refresh
			else
				@dialogs['missing'].visible = true
			end
			Graphics.freeze
			@dialogs['brew'].visible = false
			@dialogs['brew'].opacity = 0
			Graphics.transition
		})
		make.bind(1, Proc.new {
			Graphics.freeze
			@dialogs['brew'].visible = false
			@dialogs['brew'].opacity = 0
			Graphics.transition
		})
		@dialogs['brew'] = make
		# Full reagent list
		full = Interface::Dialog.new(240, 100, "Reagent list is full.", "OK")
		full.bind(0, Proc.new {
			Graphics.freeze
			@dialogs['full'].visible = false
			@dialogs['full'].opacity = 0
			Graphics.transition
		})
		@dialogs['full'] = full
	end
	#--------------------------------------------------------------------------
	# * Create Tooltips
	#--------------------------------------------------------------------------
	def create_tooltips
		# Set up tooltips hash
		@tooltips = {}
		# Add learned recipe tooltips
		for item_id in $game_party.learned_recipes
			@tooltips[item_id] = Alchemy_Tooltip.new(item_id)
		end
		# Add all ingredient tooltips
		for item in $data_items
			next if $game_party.item_number(item.id) == 0
			if Alchemy.is_reagent?(item)
				@tooltips[item.id] = Alchemy_Tooltip.new(item.id) 
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update
		# If any dialogs are visible: return
		for dialog in @dialogs.values
			if dialog.visible
				update_tooltips(true)
				dialog.fade_in if dialog.opacity < 255
				dialog.update
				return
			end
		end
		# If reagent selector visible
		if @windows['select'].visible
			# Update
			@windows['select'].update
			# Hide window on right click
			if Input.trigger?(Keys::MOUSE_RIGHT)
				# Cancel SE
				$game_system.se_play($data_system.cancel_se)
				# Hide window
				@windows['select'].visible = false
			elsif Input.trigger?(Keys::MOUSE_LEFT) &&
				@windows['select'].item
				# Play SE
				$game_system.se_play($data_system.decision_se)
				# If full: show overflow dialog
				if @windows['reagents'].items.size == 5
					@dialogs['full'].visible = true
					return
				end
				# Add reagent to list
				@windows['reagents'].add_item(@windows['select'].item)
				# Remove from party
				$game_party.lose_item(@windows['select'].item, 1, true)
				# Refresh select
				@windows['select'].refresh
			end
			# Update tooltips
			update_tooltips
			return
		end
		# Update other elements
		@windows.each_value {|window| window.update}
		@buttons.each_value {|button| button.update}
		# Update tooltips
		update_tooltips
		# Check for recipe list click
		if @windows['recipes'].item && Input.trigger?(Keys::MOUSE_LEFT)
			# Play SE
			$game_system.se_play($data_system.decision_se)
			# Show brew dialog
			@dialogs['brew'].visible = true
			return
		end
		# Check for reagent list click
		if @windows['reagents'].item && Input.trigger?(Keys::MOUSE_LEFT)
			# Play SE
			$game_system.se_play($data_system.decision_se)
			# Ask for confirmation
			@dialogs['remove'].visible = true
			return
		end
		# Return to map
		if Input.trigger?(Keys::ESC) or Input.trigger?(Keys::MOUSE_RIGHT)
			# Play SE
			$game_system.se_play($data_system.cancel_se)
			# Return to map
			$scene = Scene_Map.new
			return
		end
	end
	#--------------------------------------------------------------------------
	# * Update Tooltips
	#--------------------------------------------------------------------------
	def update_tooltips(hide=false)
		@tooltips.each_value {|tooltip| tooltip.visible = false}
		return if hide
		if @windows['select'].visible
			if @windows['select'].item
				item = $data_items[@windows['select'].item]
				@tooltips[item.id].visible = true
			end
		elsif @windows['recipes'].item
			item = $data_items[@windows['recipes'].item]
			@tooltips[item.id].visible = true
		elsif @windows['reagents'].item
			item = $data_items[@windows['reagents'].item]
			@tooltips[item.id].visible = true
		end	
		@tooltips.each_value {|tooltip| tooltip.update}
	end
	#--------------------------------------------------------------------------
	# * Refresh
	#--------------------------------------------------------------------------
	def refresh
		# Reset ingredients
		@ingredients.clear
	end
	#--------------------------------------------------------------------------
	# * Dispose Interface
	#--------------------------------------------------------------------------
	def dispose_interface
		@windows.each_value {|window| window.dispose}
		@buttons.each_value {|button| button.dispose}
		@dialogs.each_value {|dialog| dialog.dispose}
		@tooltips.each_value {|tooltip| tooltip.dispose}
	end
end