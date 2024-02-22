#==============================================================================
# ** Scene_Menu
#------------------------------------------------------------------------------
#  This class performs menu screen processing.
#==============================================================================

class Scene_Menu
	#--------------------------------------------------------------------------
	# * Difficulty Switch IDs
	#--------------------------------------------------------------------------
	Normal_Mode_ID 	= 26
	Hard_Mode_ID 	= 27
	#--------------------------------------------------------------------------
	# * Main
	#--------------------------------------------------------------------------
	def main
		# Create spriteset
		@map = Spriteset_Map.new
		# Create framework
		create_framework
		# Transition graphics
		Graphics.transition
		# Main loop
		while $scene == self
			# Update core modules
			Graphics.update
			Input.update
			# Update mouse sprite
			Mouse.show_cursor(false)
			# Update scene
			update
		end
		# Freeze graphics
		Graphics.freeze
		# Dispose
		@map.dispose
		dispose_framework
	end
	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update
		# Update info
		@windows[:info].update
		# If any dialogs are visible: return
		for dialog in @dialogs.values
			if dialog.visible
				dialog.fade_in if dialog.opacity < 255
				dialog.update
				return
			end
		end
		# Update
		update_tooltips
		@windows[:item].update(@windows[:item].opacity == 255)
		@windows[:system].update(@windows[:system].opacity == 255)
		@windows[:actors].update(!@select.nil? && windows_closed?)
		@windows[:command].update(@select.nil? && windows_closed?)
		# Check for cancel
		if Input.trigger?(Keys::MOUSE_RIGHT) or
			Input.trigger?(Keys::ESC)
			# Play cancel SE
			$game_system.se_play($data_system.cancel_se)
			# Cancel accordingly
			if @windows[:item].opacity == 255
				@windows[:item].opacity = 0
			elsif @windows[:system].opacity == 255
				@windows[:system].opacity = 0
			elsif @select.nil?
				$scene = Scene_Map.new
			else
				case @select
				when :item
					@windows[:item].refresh
					@windows[:item].opacity = 255
				end
				@select = nil
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Windows Closed?
	#--------------------------------------------------------------------------
	def windows_closed?
		(@windows[:item].opacity != 255 and @windows[:system].opacity != 255)
	end
	#--------------------------------------------------------------------------
	# * Command Select
	#--------------------------------------------------------------------------
	def command_select
		# Index case
		case @windows[:command].index
		when 0 # items
			@windows[:item].opacity = 255
		when 1 # skills
			$scene = Scene_Build.new
		when 2 # equip
			$scene = Scene_Equip.new
		when 3 # save
			if $game_system.save_disabled
				$game_system.se_play($data_system.buzzer_se)
			else
				@dialogs[:save].visible = true
			end
		when 4 # system
			@windows[:system].opacity = 255
		end
	end
	#--------------------------------------------------------------------------
	# * Command Item
	#--------------------------------------------------------------------------
	def command_item
		# Set select phase
		@select = :item
		# Set item
		@item = @windows[:item].item
		# Hide item window
		@windows[:item].opacity = 0
	end
	#--------------------------------------------------------------------------
	# * Command Actor
	#--------------------------------------------------------------------------
	def command_actor
		case @select
		when :item
			# Return if no item or no actor
			if @item.nil? or @windows[:actors].item.nil?
				$game_system.se_play($data_system.buzzer_se)
				return
			end
			# Use item
			used = @windows[:actors].item.item_effect(@item)
			# If an item was used
			if used
	    		# Play item use SE
	    		$game_system.se_play(@item.menu_se)
				# If consumable
				if @item.consumable
					# Decrease used items by 1
					$game_party.lose_item(@item.id, 1)
				end
				# Remake actor window contents
				@windows[:actors].refresh
				# If all party members are dead
				if $game_party.all_dead?
					# Switch to game over screen
					$scene = Scene_Gameover.new
					return
				end
				# If common event ID is valid
				if @item.common_event_id > 0
					# Common event call reservation
					$game_temp.common_event_id = @item.common_event_id
					# Switch to map screen
					$scene = Scene_Map.new
					return
				end
			end
			# If item wasn't used
			unless used
				# Play buzzer SE
				$game_system.se_play($data_system.buzzer_se)
			end
			# If ran out of items: return to inventory
			unless $game_party.item_number(@item.id) > 0
				@windows[:item].opacity = 255
				@windows[:item].refresh
				@select = nil
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Command System
	#--------------------------------------------------------------------------
	def command_system
		# Return if invalid index
		return unless @windows[:system].index >= 0
		# Play decision SE
		$game_system.se_play($data_system.decision_se)
		# Index case
		case @windows[:system].index
		when 0 # enchanting
			$scene = Scene_Crafting.new
		when 1 # difficulty
			# Change difficulty (mirror switches)
			$game_switches[Normal_Mode_ID] = !$game_switches[Normal_Mode_ID]
			$game_switches[Hard_Mode_ID] = !$game_switches[Hard_Mode_ID]
			# Refresh system menu
			@windows[:system].refresh
		when 2 # exit game
			@windows[:system].opacity = 0
			@dialogs[:quit].visible = true
		end
	end
	#--------------------------------------------------------------------------
	# * Update Tooltips
	#--------------------------------------------------------------------------
	def update_tooltips
		# Hide all tooltips first
		@tooltips.each_value {|tooltip| tooltip.visible = false}
		# Show required tooltips
		if @windows[:item].item
			@tooltips[@windows[:item].item.id].update
			@tooltips[@windows[:item].item.id].visible = true
		end
	end
	#--------------------------------------------------------------------------
	# * Create Framework
	#--------------------------------------------------------------------------
	def create_framework
		create_windows
		create_dialogs
		create_tooltips
	end
	#--------------------------------------------------------------------------
	# * Create Windows
	#--------------------------------------------------------------------------
	def create_windows
		# Set up map
		@windows = {}
		# Add windows
		@windows[:actors] = Window_ActorSelect.new(70, 112, 500, 256)
		@windows[:actors].bind(Proc.new {command_actor})
		@windows[:command] = Window_MenuSelect.new(70, 74, 500, 38)
		@windows[:command].bind(Proc.new {command_select})
		@windows[:info] = Window_Info.new(70, 368, 500, 32)
		@windows[:item] = Window_Items.new(208, 128)
		@windows[:item].bind(Proc.new {command_item}) 
		@windows[:system] = Window_SystemMenu.new
		@windows[:system].bind(Proc.new {command_system})
	end
	#--------------------------------------------------------------------------
	# * Create Dialogs
	#--------------------------------------------------------------------------
	def create_dialogs
		# Create dialog map
		@dialogs = {}
		# Save overwrite dialog
		save = Interface::Dialog.new(240, 100, 
			"Overwrite save file?", "Yes", "No")
		save.bind(0, Proc.new {
			$game_system.autosave
			Graphics.freeze
			@dialogs[:save].opacity = 0
			@dialogs[:save].visible = false
			Graphics.transition
		})
		save.bind(1, Proc.new {
			Graphics.freeze
			@dialogs[:save].opacity = 0
			@dialogs[:save].visible = false
			Graphics.transition
		})
		@dialogs[:save] = save
		# Quit confirm dialog
		quit = Interface::Dialog.new(240, 100, 
			"Are you sure you wish to quit?", "Yes", "No")
		quit.bind(0, Proc.new {
			$scene = Scene_Title.new
			Graphics.freeze
			@dialogs[:quit].opacity = 0
			@dialogs[:quit].visible = false
			Graphics.transition
		})
		quit.bind(1, Proc.new {
			Graphics.freeze
			@dialogs[:quit].opacity = 0
			@dialogs[:quit].visible = false
			Graphics.transition
		})
		@dialogs[:quit] = quit
	end
	#--------------------------------------------------------------------------
	# * Create Tooltips
	#--------------------------------------------------------------------------
	def create_tooltips
		# Set up map
		@tooltips = {}
		# Create tooltips for items
		$data_items.each do |item|
			# Next if nil
			next unless item
			# Create item tooltips
			if $game_party.item_number(item.id) > 0
				@tooltips[item.id] = Window_ItemTooltip.new(item)
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Dispose Framework
	#--------------------------------------------------------------------------
	def dispose_framework
		@windows.each_value {|window| window.dispose}
		@dialogs.each_value {|dialog| dialog.dispose}
	end
end

#==============================================================================
# ** Window_ItemTooltip
#------------------------------------------------------------------------------
#  This class displays the window for tooltips for items.
#==============================================================================

class Window_ItemTooltip < Interface::Tooltip
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(item)
		@item = item
		calculate_dimensions
		super(0, 0, @width, @height)
		refresh
		self.visible = false
		self.z = 99999
	end
	#--------------------------------------------------------------------------
	# * Refresh
	#--------------------------------------------------------------------------
	def refresh
		# Dispose contents if necessary
		@contents.dispose if @contents
		# Create new sprite
		@contents = Sprite.new
		@contents.x = @x
		@contents.y = @y
		@contents.z = self.objects[0].z + 500
		@contents.visible = @visible
		# Create bitmap
		bitmap = Bitmap.new(@width, @height)
		# Draw item name
		bitmap.font.color = Color.new(255, 180, 180)
		bitmap.draw_text(4, 4, @width, @dim.height, @item.name)
		# Draw sell price
		i = 1
		if @item.price > 0
			bitmap.font.color = Color.new(180, 180, 255)
			bitmap.draw_text(4, 4 + @dim.height, @width, @dim.height, 
				"Price: #{@item.price} #{$data_system.words.gold}")
			i += 1
		end
		# Draw all description lines
		bitmap.font.color = Color.new(255, 255, 255)
		@lines = wrap_text(@item.description, 33)
		@lines.each_line do |line|
			bitmap.draw_text(4, 4 + @dim.height * i, @width, @dim.height, line)
			i += 1
		end
		# Draw occasion
		bitmap.font.color = Color.new(225, 225, 255)
		case @item.occasion
		when 0 # always
			scope = "Can always be used"
		when 1 # combat only
			scope = "Can only be used in battle"
		when 2 # menu only
			scope = "Not usable in combat"
		when 3
			scope = "Cannot be used"
		end
		bitmap.draw_text(4, 4 + @dim.height * i, @width, @dim.height, scope)
		# Set bitmap
		@contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update
		super
		self.x = Mouse.x
		self.y = Mouse.y - @height
		self.x = 640 - @width if self.x > 640 - @width
		self.y = 0 if self.y < 0
	end
	#--------------------------------------------------------------------------
	# * Calculate Dimensions
	#--------------------------------------------------------------------------
	def calculate_dimensions
		# Create temporary bitmap for size calculations
		bitmap = Bitmap.new(640, 480)
		# Get base dimensions
		@dim = bitmap.text_size(@item.name)
		# Get width of talent name
		@width = @dim.width
		@height = @dim.height + 8
		# Add line for sell price
		@height += @dim.height if @item.price > 0
		# Add line for occasion
		@height += @dim.height
		# Get description lines
		@lines = wrap_text(@item.description, 33)
		# Add all lines
		@lines.each_line do |line| 
			@height += @dim.height
			width = bitmap.text_size(line).width
			@width = width if width > @width
		end
		# Add to width
		@width += 8
	end
	#--------------------------------------------------------------------------
	# * Objects
	#--------------------------------------------------------------------------
	def objects
		a = super
		a << @contents
		a
	end
	#--------------------------------------------------------------------------
	# * Visibility Setting
	#--------------------------------------------------------------------------
	def visible=(bool)
		super
		self.objects[0].visible = bool
		@contents.visible = bool
	end
end

#==============================================================================
# ** Window_Items
#------------------------------------------------------------------------------
#  This class displays the window for selecting items.
#==============================================================================

class Window_Items < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y)
		@columns = 6
		super(x, y, 224, 224)
		refresh
		@fade_in = true
		self.opacity = 0
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
		@data = []
		for i in 1...$data_items.size
			next unless $game_party.item_number(i) > 0
			next if $data_items[i].element_set.include?(27)
			@data << $data_items[i]
		end
		for i in 0...@data.size
			draw_item(i, bitmap)
		end
		# Set bitmap
		self.contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update(active)
		# Set active state
		@active = active
		# Hide highlight if inactive
		unless @active
			@highlight.visible = false
			@index = -1
			return
		end
		# Call superclass
		super()
	end
	#--------------------------------------------------------------------------
    # * Clickable?
    #--------------------------------------------------------------------------
    def clickable?
      @active && @index >= 0
    end
	#--------------------------------------------------------------------------
    # * Item Rect
    #--------------------------------------------------------------------------
    def item_rect(index)
      Rect.new(@x + 4 + ((@width - 8) / @columns) * index, @y + 4, (@width - 8) / @columns, 34)
    end
    #--------------------------------------------------------------------------
    # * Draw Item
    #--------------------------------------------------------------------------
    def draw_item(index, bitmap)
    	# Get rect
    	rect = item_rect(index)
    	# Get item
    	item = @data[index]
    	# Get icon
    	icon = RPG::Cache.icon(item.icon_name)
    	# Draw icon
    	bitmap.blt(rect.x - @x + 17 - icon.width / 2, rect.y - @y + 17 - icon.height / 2, 
    		icon, Rect.new(0, 0, icon.width, icon.height))
    	# Draw amount
    	number = $game_party.item_number(item.id)
    	if number > 1
    		bitmap.draw_text(rect.x - @x, rect.y - @y + 8, rect.width - 4, rect.height - 8, number.to_s, 2)
    	end	
    end
end

#==============================================================================
# ** Window_MenuSelect
#------------------------------------------------------------------------------
#  This class displays the window for selecting menu commands.
#==============================================================================

class Window_MenuSelect < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y, width, height)
		@columns = 5
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
		# Draw all options
		@data = ["Items", "Builds", "Equip", "Save", "System"]
		for i in 0...@data.size
			draw_item(i, bitmap)
		end
		# Set bitmap
		self.contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update(active)
		# Set active state
		@active = active
		# Hide highlight if inactive
		unless @active
			@highlight.visible = false
			@index = -1
			return
		end
		# Call superclass
		super()
	end
	#--------------------------------------------------------------------------
    # * Clickable?
    #--------------------------------------------------------------------------
    def clickable?
      @active && @index >= 0
    end
	#--------------------------------------------------------------------------
    # * Item Rect
    #--------------------------------------------------------------------------
    def item_rect(index)
      Rect.new(@x + (@width / @columns) * index, @y, @width / @columns, @height)
    end
    #--------------------------------------------------------------------------
    # * Draw Item
    #--------------------------------------------------------------------------
    def draw_item(index, bitmap)
    	# Get X position
    	x = 4 + (@width / @columns) * index
    	# Get text
    	text = @data[index]
    	# Get icon
    	icon = RPG::Cache.gui("Menu/#{text}")
    	# Draw icon
    	bitmap.blt(x + 16 - icon.width / 2, @height / 2 - icon.height / 2, 
    		icon, Rect.new(0, 0, icon.width, icon.height))
    	# Draw label
    	bitmap.font.color = $game_system.save_disabled && text == "Save" ? Color.new(160, 160, 160) : Color.new(255, 255, 255)
    	bitmap.draw_text(x + 36, 4, item_rect(index).width - 40, @height - 8, text)
    end
end

#==============================================================================
# ** Window_Info
#------------------------------------------------------------------------------
#  This class displays the window for showing playtime and gold.
#==============================================================================

class Window_Info < Interface::Container
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y, width, height)
		super(x, y, width, height)
		refresh
	end
	#--------------------------------------------------------------------------
	# * Refresh
	#--------------------------------------------------------------------------
	def refresh
		# Dispose contents if necessary
		@contents.dispose if @contents
		# Create new sprite
		@contents = Sprite.new
		@contents.x = @x
		@contents.y = @y
		@contents.z = self.objects[0].z + 500
		@contents.visible = @visible
		# Create bitmap
		bitmap = Bitmap.new(@width, @height)
		# Draw labels
		bitmap.font.color = Color.new(255, 180, 180)
		bitmap.draw_text(4, 0, @width - 8, @height, "Play Time")
		bitmap.draw_text(4, 0, @width - 8, @height, $data_system.words.gold, 2)
		# Draw play time
		bitmap.font.color = Color.new(255, 255, 255)
		@total_sec = Graphics.frame_count / Graphics.frame_rate
	    hour = @total_sec / 60 / 60
	    min = @total_sec / 60 % 60
	    sec = @total_sec % 60
	    text = sprintf("%02d:%02d:%02d", hour, min, sec)
	    lw = bitmap.text_size("Play Time").width
	    bitmap.draw_text(12 + lw, 0, @width - 16 - lw, @height, text)
	    # Draw gold amount
	    lw = bitmap.text_size($data_system.words.gold).width
	    bitmap.draw_text(4, 0, @width - 10 - lw, @height, $game_party.gold.to_s, 2)
	    # Set bitmap
	    @contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Frame Update
	#--------------------------------------------------------------------------
	def update
	  super
	  if Graphics.frame_count / Graphics.frame_rate != @total_sec
	    refresh
	  end
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
# ** Window_ActorSelect
#------------------------------------------------------------------------------
#  This class displays the window for showing all party members and selecting.
#==============================================================================

class Window_ActorSelect < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Module Inclusion
	#--------------------------------------------------------------------------
	include GFX_Tools
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
		# Draw all actors
		@data = $game_party.actors
		for i in 0...@data.size
			draw_actor(i, bitmap)
		end
		# Set bitmap
		self.contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update(active)
		# Set active state
		@active = active
		# Hide highlight if inactive
		unless @active
			@highlight.visible = false
			@index = -1
			return
		end
		# Call superclass
		super()
	end
	#--------------------------------------------------------------------------
    # * Item Rect
    #--------------------------------------------------------------------------
    def item_rect(index)
      Rect.new(@x, @y + (@height / 4) * index, @width, @height / 4)
    end
    #--------------------------------------------------------------------------
    # * Clickable?
    #--------------------------------------------------------------------------
    def clickable?
      @active && @index >= 0
    end
	#--------------------------------------------------------------------------
	# * Draw Actor
	#--------------------------------------------------------------------------
	def draw_actor(index, bitmap)
		# Get Y
		y = (@height / 4) * index
		# Get actor
		actor = @data[index]
		# Get rect
		rect = item_rect(index)
		# Draw graphic
		draw_actor_graphic(4, 4 + y, actor, bitmap)
		# Draw actor's name
		bitmap.font.color = Color.new(255, 180, 180)
		bitmap.draw_text(36, 4 + y, rect.width, 24, actor.name)
		# Draw level and class
		bitmap.font.color = Color.new(255, 255, 255)
		bitmap.draw_text(36, 20 + y, rect.width, 24, "Level #{actor.level} #{actor.class_name}")
		# Draw experience bar
		draw_bar(36, 40 + y, actor.current_exp, actor.next_exp, RPG::Cache.gui("Exp Bar"), bitmap)
		draw_bar_numbers(36, 40 + y, "Exp", actor.current_exp, actor.next_exp, bitmap)
		# Draw health bar
		draw_bar(@width - 200, 4 + y, actor.hp, actor.maxhp, RPG::Cache.gui("Health Bar"), bitmap)
		draw_bar_numbers(@width - 200, 4 + y, "Life", actor.hp, actor.maxhp, bitmap)
		# Draw mana bar
		draw_bar(@width - 200, 22 + y, actor.sp, actor.maxsp, RPG::Cache.gui("Mana Bar"), bitmap)
		draw_bar_numbers(@width - 200, 22 + y, "Mana", actor.sp, actor.maxsp, bitmap)
		# Draw personal resource bar
		draw_bar(@width - 200, 40 + y, actor.clr, actor.clr_max, RPG::Cache.gui("#{actor.class_resource} Bar"), bitmap)
		draw_bar_numbers(@width - 200, 40 + y, actor.class_resource, actor.clr, actor.clr_max, bitmap)
	end
end

#==============================================================================
# ** Window_SystemMenu
#------------------------------------------------------------------------------
#  This class displays the window for showing the system menu.
#==============================================================================

class Window_SystemMenu < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize
		super(320 - 100, 240 - 57, 200, 114)
		refresh
		@fade_in = true
		self.z = 99999
		self.opacity = 0
	end
	#--------------------------------------------------------------------------
	# * Refresh
	#--------------------------------------------------------------------------
	def refresh
		# Call superclass 
		super
		# Create bitmap
		bitmap = Bitmap.new(@width, @height)
		# Draw all commands
		@data = ["Enchanting", "Difficulty", "Exit Game"]
		for i in 0...@data.size
			# Get x and y
			x = 8
			y = 0 + 38 * i
			# Get icon
			icon = RPG::Cache.gui("Menu/#{@data[i]}")
			# Draw icon
			bitmap.blt(x, y + 19 - icon.height / 2, icon, Rect.new(0, 0, icon.width, icon.height))
			# Get text dimensions
			n = bitmap.text_size(@data[i]).height
			# Draw command text
			bitmap.font.color = Color.new(255, 180, 180)
			bitmap.draw_text(x + 38, y + 19 - n / 2, @width, n, @data[i])
			# Draw difficulty text if applicable
			if @data[i] == "Difficulty"
				text = $game_switches[26] ? "Normal" : "Hard"
				bitmap.font.color = Color.new(255, 255, 255)
				bitmap.draw_text(x, y + 19 - n / 2, @width - 16, n, text, 2)
			end
		end
		# Set bitmap
		self.contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update(active)
		# Set active state
		@active = active
		# Hide highlight if inactive
		unless @active
			@highlight.visible = false
			@index = -1
			return
		end
		# Call superclass
		super()
		puts active
	end
	#--------------------------------------------------------------------------
    # * Item Rect
    #--------------------------------------------------------------------------
    def item_rect(index)
      Rect.new(@x, @y + (@height / 3) * index, @width, @height / 3)
    end
    #--------------------------------------------------------------------------
    # * Clickable?
    #--------------------------------------------------------------------------
    def clickable?
      @active && @index >= 0
    end
end