#==============================================================================
# ** Scene_Crafting
#------------------------------------------------------------------------------
#  This class performs crafting screen processing.
#==============================================================================

class Scene_Crafting
	#--------------------------------------------------------------------------
	# * Orb Effects
	#--------------------------------------------------------------------------
	Orb_Effects = {
		2 => [0,1],		# Arcane Orb
		3 => [1,1],		# Magic Orb
		4 => [-1,0],	# Dispel Orb
		5 => [0,2],		# Holy Orb
		6 => [2,2],		# Resplendent Orb
		7 => [1,2],		# Majestic Orb
		8 => [2,3],		# Illustrious Orb
		9 => [0,3],		# Lunar Orb
		10=> [3,3]		# Solar Orb
	}
	#--------------------------------------------------------------------------
	# * Main
	#--------------------------------------------------------------------------
	def main
		# Create framework
		create_framework
		# Transition graphics
		Graphics.transition
		# Main loop
		while $scene == self
			# Update modules
			Graphics.update
			Input.update
			Mouse.show_cursor(true)
			# Update frame
			update
		end
		# Freeze graphics
		Graphics.freeze
		# Dispose framework
		dispose_framework
	end
	#--------------------------------------------------------------------------
	# * Create Framework
	#--------------------------------------------------------------------------
	def create_framework
		# Create map background
		@map = Spriteset_Map.new
		# Create maps
		@windows = {}
		@dialogs = {}
		# Create windows
		@windows[:orbs] = Window_Orbs.new(32, 56)
		@windows[:orbs].bind(Proc.new {command_orbs})
		@windows[:inventory] = Window_CraftingEquip.new(320, 56)
		@windows[:equip] = Window_EquipCraft.new(32, 64)
		@windows[:equip].bind(Proc.new {command_use})
		@windows[:help] = Window_TextHelp.new(32, 384, 576, 64)
		@windows[:tooltip] = Window_EquipTooltip.new(32, 256, 576, true)
	end
	#--------------------------------------------------------------------------
	# * Update (frame)
	#--------------------------------------------------------------------------
	def update
		# Update nothing if there is an altered tooltip
		if @new_item
			@new_item.update
			if Input.trigger?(Keys::MOUSE_LEFT) and @ready
				$game_system.se_play($data_system.decision_se)
				@new_item.dispose
				@new_item = nil
				@ready = false
				@windows[:equip].set_orb(@orb)
				if $game_party.item_number(@orb) == 0
					@windows[:equip].visible = false
					@windows[:orbs].visible = true
				end
				return
			end
			@ready = true
		end
		# Only update windows if a dialog is not showing 
		# and the window is visible
		unless dialog_showing?
			@windows.each_value {|window| window.update}
		end
		# Return if showing new item tooltip
		return if @new_item
		# Update text help
		@windows[:help].visible = @windows[:orbs].visible
		@windows[:inventory].visible = @windows[:orbs].visible
		if @windows[:orbs].visible && @windows[:orbs].item
			@windows[:help].set_text($data_items[@windows[:orbs].item].description)
		end
		# Update tooltip
		@windows[:tooltip].visible = @windows[:equip].visible
		if @windows[:equip].visible
			@windows[:tooltip].set_item(@windows[:equip].item)
			if Input.trigger?(Keys::MOUSE_RIGHT)
				$game_system.se_play($data_system.decision_se)
				@windows[:equip].visible = false
				@windows[:orbs].visible = @windows[:inventory].visible = true
				return
			end
		end
		# If orbs visible: allow exit
		if @windows[:orbs].visible
			if Input.trigger?(Keys::MOUSE_RIGHT)
				$game_system.se_play($data_system.decision_se)
				$scene = Scene_Menu.new
				return
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Command Orbs
	#--------------------------------------------------------------------------
	def command_orbs
		# Buzzer if no item
		unless @windows[:orbs].item
			$game_system.se_play($data_system.buzzer_se)
			return
		end
		# Buzzer if you have no items
		unless $game_party.item_number(@windows[:orbs].item) > 0
			$game_system.se_play($data_system.buzzer_se)
			return
		end
		# Set selected orb
		@orb = @windows[:orbs].item
		# Set orb item for equip window
		@windows[:equip].set_orb(@orb)
		# Show respective windows
		@windows[:orbs].visible = false
		@windows[:equip].visible = true
	end
	#--------------------------------------------------------------------------
	# * Command Use (Orb)
	#--------------------------------------------------------------------------
	def command_use
		# Buzzer if no item
		unless @windows[:equip].item
			$game_system.se_play($data_system.buzzer_se)
			return
		end
		# Get old item
		old_item = @windows[:equip].item
		# Alter item
		item = alter_item
		# Lose orb
		$game_party.lose_item(@orb, 1)
		# Lose old item and gain new item
		if item != old_item
			$game_party.equipment.delete(old_item)
			$game_party.equipment << item
		end
		# Create new tooltip
		@new_item = Window_EquipTooltip.new(144, 144, 352, true)
		@new_item.set_item(item)
		@new_item.visible = true
		# Remove tooltip
		@windows[:tooltip].set_item(nil)
		# Refresh windows
		@windows[:equip].refresh
		@windows[:orbs].refresh
		@windows[:inventory].refresh
	end
	#--------------------------------------------------------------------------
	# * Alter Item
	#--------------------------------------------------------------------------
	def alter_item
		# Get effect
		effect = Orb_Effects[@orb]
		# Get item
		item = @windows[:equip].item
		# If both indexes are equal or first index is <= 0: make new item
		if effect[0] == effect[1] || effect[0] <= 0
			return item.class.new(item.base, effect[1])
		else
			return item.upgrade(effect[1])
		end
	end
	#--------------------------------------------------------------------------
	# * Dialog Showing?
	#--------------------------------------------------------------------------
	def dialog_showing?
		showing = false
		@dialogs.each_value do |dialog|
			if dialog.visible
				dialog.update
				showing = true
				break
			end
		end
		showing
	end
	#--------------------------------------------------------------------------
	# * Dispose Framework
	#--------------------------------------------------------------------------
	def dispose_framework
		@map.dispose
		@windows.each_value {|window| window.dispose}
		@dialogs.each_value {|dialog| dialog.dispose}
	end
end

#==============================================================================
# ** Window_EquipCraft
#------------------------------------------------------------------------------
#  This class displays the window for crafting equipment.
#==============================================================================

class Window_EquipCraft < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y)
		@index = -1
		@columns = 15
		super(x, y, 576, 192)
		refresh
		@fade_in = true
		self.visible = false
		self.z = 99000
	end
	#--------------------------------------------------------------------------
	# * Refresh
	#--------------------------------------------------------------------------
	def refresh
		# Call superclass 
		super
		# Create bitmap
		bitmap = Bitmap.new(@width, @height)
		# Get all items
		@data = $game_party.equipment.compact unless @data
		n = @data.size > 75 ? 75 : @data.size
		for i in 0...n
			draw_item(i, bitmap)
		end
		# If no data: draw text
		if @data.size == 0
			bitmap.draw_text(8, 8, @width, 24, "No target items in inventory")
		end
		# Set bitmap
		self.contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Set Orb
	#--------------------------------------------------------------------------
	def set_orb(orb)
		# Get orb effect
		effect = Scene_Crafting::Orb_Effects[orb]
		# Return selected array
		@data = $game_party.equipment.select do |equip| 
			if equip
				if effect[0] < 0
					next equip.rarity > 0
				else
					next equip.rarity == effect[0]
				end
			else
				next false
			end
		end
		# Refresh
		refresh
	end
	#--------------------------------------------------------------------------
    # * Clickable?
    #--------------------------------------------------------------------------
    def clickable?
    	@index >= 0
    end
	#--------------------------------------------------------------------------
    # * Item Rect
    #--------------------------------------------------------------------------
    def item_rect(index)
    	Rect.new(@x + 4 + ((@width - 8) / @columns) * (index % @columns), 
    		@y + 4 + 36 * (index / @columns), (@width - 8) / @columns, 34)
    end
    #--------------------------------------------------------------------------
    # * Draw Item
    #--------------------------------------------------------------------------
    def draw_item(index, bitmap)
    	# Get rect
    	rect = item_rect(index)
    	# Get item
    	item = @data[index]
    	# Draw rarity background
    	if item.rarity > 0
	    	# Get icon
	    	a = [nil, "Enchanted", "Rare", "Mythical"]
	    	icon = RPG::Cache.icon(a[item.rarity])
	    	# Draw icon
	    	bitmap.blt(rect.x - @x + 17 - icon.width / 2, rect.y - @y + 17 - icon.height / 2, 
	    		icon, Rect.new(0, 0, icon.width, icon.height))
	    end
    	# Get icon
    	icon = RPG::Cache.icon(item.icon_name)
    	# Draw icon
    	bitmap.blt(rect.x - @x + 17 - icon.width / 2, rect.y - @y + 17 - icon.height / 2, 
    		icon, Rect.new(0, 0, icon.width, icon.height))
    end
    #--------------------------------------------------------------------------
    # * Set visible state
    #--------------------------------------------------------------------------
    def visible=(bool)
    	self.objects.each {|obj| obj.visible = bool}
    	@contents.visible = bool
    	self.objects[1].visible = false
    	@visible = bool
    end
end

#==============================================================================
# ** Window_Orbs
#------------------------------------------------------------------------------
#  This class displays the window for listing all orbs.
#==============================================================================

class Window_Orbs < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y)
		super(x, y, 288, 328)
		refresh
		@fade_in = true
		self.visible = true
		self.z = 99000
	end
	#--------------------------------------------------------------------------
	# * Refresh
	#--------------------------------------------------------------------------
	def refresh
		# Call superclass 
		super
		# Create bitmap
		bitmap = Bitmap.new(@width, @height)
		# Get all items
		@data = Scene_Crafting::Orb_Effects.keys
		for i in 0...@data.size
			draw_item(i, bitmap)
		end
		# Set bitmap
		self.contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
    # * Clickable?
    #--------------------------------------------------------------------------
    def clickable?
    	@index >= 0
    end
	#--------------------------------------------------------------------------
    # * Item Rect
    #--------------------------------------------------------------------------
    def item_rect(index)
    	Rect.new(@x + 1, @y + 4 + 36 * index, @width - 2, 34)
    end
    #--------------------------------------------------------------------------
    # * Draw Item
    #--------------------------------------------------------------------------
    def draw_item(index, bitmap)
    	# Get rect
    	rect = item_rect(index)
    	# Get item
    	item = $data_items[@data[index]]
    	# Get icon
    	icon = RPG::Cache.icon(item.icon_name)
    	# Draw icon
    	bitmap.blt(rect.x - @x + 17 - icon.width / 2, rect.y - @y + 17 - icon.height / 2, 
    		icon, Rect.new(0, 0, icon.width, icon.height))
    	# Draw item name
    	bitmap.font.color = $game_party.item_number(item.id) == 0 ? Color.new(180, 180, 180) : Color.new(255, 255, 255)
    	bitmap.draw_text(rect.x - @x + 38, rect.y - @y, rect.width, rect.height, item.name)
    	# Draw cost
    	bitmap.draw_text(rect.x - @x + 38, rect.y - @y, rect.width - 42, rect.height, $game_party.item_number(item.id).to_s, 2)
    end
    #--------------------------------------------------------------------------
    # * Set visible state
    #--------------------------------------------------------------------------
    def visible=(bool)
    	self.objects.each {|obj| obj.visible = bool}
    	@contents.visible = bool
    	self.objects[1].visible = false
    	@visible = bool
    end
end

#==============================================================================
# ** Window_CraftingEquip
#------------------------------------------------------------------------------
#  This class displays the window for all crafting equipment.
#==============================================================================

class Window_CraftingEquip < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y)
		@index = -1
		@columns = 8
		super(x, y, 288, 328)
		refresh
		@fade_in = true
		self.visible = true
		self.z = 99000
	end
	#--------------------------------------------------------------------------
	# * Refresh
	#--------------------------------------------------------------------------
	def refresh
		# Call superclass 
		super
		# Create bitmap
		bitmap = Bitmap.new(@width, @height)
		# Get all items
		@data = $game_party.equipment.compact
		n = @data.size > 75 ? 75 : @data.size
		for i in 0...n
			draw_item(i, bitmap)
		end
		# If no data: draw text
		if @data.size == 0
			bitmap.draw_text(8, 8, @width, 24, "No equipment in inventory")
		end
		# Set bitmap
		self.contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Override Update Method
	#--------------------------------------------------------------------------
	def update ; end
	#--------------------------------------------------------------------------
    # * Clickable?
    #--------------------------------------------------------------------------
    def clickable?
    	false
    end
	#--------------------------------------------------------------------------
    # * Item Rect
    #--------------------------------------------------------------------------
    def item_rect(index)
    	Rect.new(@x + 4 + ((@width - 8) / @columns) * (index % @columns), 
    		@y + 4 + 36 * (index / @columns), (@width - 8) / @columns, 34)
    end
    #--------------------------------------------------------------------------
    # * Draw Item
    #--------------------------------------------------------------------------
    def draw_item(index, bitmap)
    	# Get rect
    	rect = item_rect(index)
    	# Get item
    	item = @data[index]
    	# Draw rarity background
    	if item.rarity > 0
	    	# Get icon
	    	a = [nil, "Enchanted", "Rare", "Mythical"]
	    	icon = RPG::Cache.icon(a[item.rarity])
	    	# Draw icon
	    	bitmap.blt(rect.x - @x + 17 - icon.width / 2, rect.y - @y + 17 - icon.height / 2, 
	    		icon, Rect.new(0, 0, icon.width, icon.height))
	    end
    	# Get icon
    	icon = RPG::Cache.icon(item.icon_name)
    	# Draw icon
    	bitmap.blt(rect.x - @x + 17 - icon.width / 2, rect.y - @y + 17 - icon.height / 2, 
    		icon, Rect.new(0, 0, icon.width, icon.height))
    end
    #--------------------------------------------------------------------------
    # * Set visible state
    #--------------------------------------------------------------------------
    def visible=(bool)
    	self.objects.each {|obj| obj.visible = bool}
    	@contents.visible = bool
    	self.objects[1].visible = false
    	@visible = bool
    end
end