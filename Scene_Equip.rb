#==============================================================================
# ** Scene_Equip
#------------------------------------------------------------------------------
#  This class performs equip screen processing.
#==============================================================================

class Scene_Equip
	#--------------------------------------------------------------------------
	# * Main
	#--------------------------------------------------------------------------
	def main
		# Create map spriteset
		@map = Spriteset_Map.new
		# Create framework
		create_framework
		# Set actor for windows
		@actor = $game_party.actors[0]
		@windows[:slots].set_actor(@actor)
		@windows[:stats].set_actor(@actor)
		# Transition
		Graphics.transition
		# Main loop
		while $scene == self
			# Update core modules
			Graphics.update
			Input.update
			Mouse.show_cursor(true)
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
		# Update windows
		@windows[:actors].update(@windows[:list].opacity == 0)
		@windows[:slots].update(@windows[:list].opacity == 0)
		@windows[:list].update(@windows[:list].opacity == 255)
		# Update tooltips
		if @windows[:list].opacity == 255
			show_tooltip(:bag, @windows[:list].item)
		else
			if @actor.equipped(@windows[:slots].item)
				show_tooltip(:item, @actor.equipped(@windows[:slots].item))
				y = @windows[:slots].y + 38 + 36 * @windows[:slots].index
				y = y - 36 - 192 if y + 192 > 480
				move_tooltip(:item, @windows[:slots].x + 16, y)
			else
				hide_tooltips
			end
		end
		# Update cancel
		if Input.trigger?(Keys::ESC) or
			Input.trigger?(Keys::MOUSE_RIGHT)
			# Play cancel SE
			$game_system.se_play($data_system.cancel_se)
			# Do appropriate actions
			if @windows[:list].opacity == 255
				hide_tooltips
				@tooltips[:compare].visible = false
				@windows[:list].opacity = 0
			else
				$scene = Scene_Menu.new
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Command Equip
	#--------------------------------------------------------------------------
	def command_equip
		# Get item
		item = @windows[:list].item
		# Get equipped item
		old = @actor.equipped(@slot)
		# If unequip command
		item = nil if item == "Unequip"
		# Get indexer
		indexer = [:weapon1, :weapon2]
		# If weapon: wield
		if indexer.include?(@slot)
			@actor.wield(indexer.index(@slot), item)
		else
			@actor.equip(@slot, item)
		end
		# Remove item from equipment list
		$game_party.equipment.delete(item) if item
		# Add old item to equipment list
		$game_party.equipment.push(old)
		# Play equip SE
		$game_system.se_play($data_system.equip_se)
		# Set new comparison
		@tooltips[:compare].set_item(@actor.equipped(@slot))
		# Refresh windows
		@windows[:slots].refresh
		@windows[:list].refresh
		@windows[:stats].refresh
	end
	#--------------------------------------------------------------------------
	# * Create Framework
	#--------------------------------------------------------------------------
	def create_framework
		create_windows
		create_tooltips
	end
	#--------------------------------------------------------------------------
	# * Create Windows
	#--------------------------------------------------------------------------
	def create_windows
		# Set up map
		@windows = {}
		# Add windows
		@windows[:actors] = Window_ActorSelectSmall.new(252 - 17 * [$game_party.actors.size - 4, 0].max, 32)
		@windows[:actors].bind(Proc.new {
			@actor = @windows[:actors].item
			@windows[:slots].set_actor(@actor)
			@windows[:stats].set_actor(@actor)
		})
		@windows[:slots] = Window_EquipSlots.new(16, 88, 300, 296)
		@windows[:slots].bind(Proc.new {
			if @windows[:slots].item == :weapon2 && 
				@actor.class_id != 1
				$game_system.se_play($data_system.buzzer_se)
				next
			end
			@slot = @windows[:slots].item
			@windows[:list].set_slot(@slot, @actor)
			@tooltips[:compare].set_item(@actor.equipped(@slot))
			@windows[:list].opacity = 255
			hide_tooltips
			move_tooltip(:item, 256, 48)
			@tooltips[:compare].visible = true
		})
		@windows[:stats] = Window_ActorStats.new(316, 88, 308)
		@windows[:stats].visible = true
		@windows[:list] = Window_EquipList.new(32, 48)
		@windows[:list].bind(Proc.new {command_equip})
	end
	#--------------------------------------------------------------------------
	# * Create Tooltips
	#--------------------------------------------------------------------------
	def create_tooltips
		# Set up map
		@tooltips = {}
		# Create tooltip
		@tooltips[:item] = {}
		@tooltips[:bag] = {}
		@tooltips[:compare] = Window_EquipTooltip.new(256, 240, 352, true)
	end
	#--------------------------------------------------------------------------
	# * Show Tooltip
	#--------------------------------------------------------------------------
	def show_tooltip(type, item)
		# If tooltip not found: create
		unless @tooltips[type][item]
			create_tooltip(type, item)
		end
		# Hide all tooltips
		@tooltips[type].each_value {|tooltip| tooltip.visible = false}
		# Show tooltip
		@tooltips[type][item].visible = true
	end
	#--------------------------------------------------------------------------
	# * Move Tooltip
	#--------------------------------------------------------------------------
	def move_tooltip(type, x, y)
		# Move all tooltips
		@tooltips[type].each_value do |tooltip| 
			tooltip.x = x
			tooltip.y = y
		end
	end
	#--------------------------------------------------------------------------
	# * Hide Tooltips
	#--------------------------------------------------------------------------
	def hide_tooltips
		# Hide all tooltips
		@tooltips[:item].each_value {|tooltip| tooltip.visible = false}
		@tooltips[:bag].each_value {|tooltip| tooltip.visible = false}
	end
	#--------------------------------------------------------------------------
	# * Create Tooltip
	#--------------------------------------------------------------------------
	def create_tooltip(type, item)
		@tooltips[type][item] = Window_EquipTooltip.new(256, type == :compare ? 240 : 48, 352, type == :bag)
		@tooltips[type][item].set_item(item)
	end
	#--------------------------------------------------------------------------
	# * Dispose Framework
	#--------------------------------------------------------------------------
	def dispose_framework
		@windows.each_value {|window| window.dispose}
		@tooltips[:item].each_value {|tooltip| tooltip.dispose}
		@tooltips[:compare].dispose
	end
end

#==============================================================================
# ** Window_EquipCompare
#------------------------------------------------------------------------------
#  This class displays the window for tooltips for equipment comparisons.
#==============================================================================

class Window_EquipCompare < Interface::Container
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y)
		super(x, y, 352, 192)
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
		# Get dimensions
		@dim = bitmap.text_size("W")
		# Execute if item set
		if @item && @compare
			# Draw item name
			bitmap.font.color = Color.new(255, 200, 200)
			bitmap.draw_text(4, 4, @width, @dim.height, "Stat change if you equip this item")
			# Draw base stats if any
			@i = 1
			bitmap.font.color = Color.new(255, 255, 255)
			if @item.attr(:pdef) > 0
				draw_comparison(:pdef, bitmap)
			end
			if @item.attr(:mdef) > 0
				draw_comparison(:mdef, bitmap)
			end
			if @item.attr(:atk) > 0
				draw_comparison(:atk, bitmap)
			end
			# Draw all affix lines
			bitmap.font.color = Color.new(200, 200, 255)
			compared = [:pdef, :mdef, :atk]
			@item.affixes.each do |key, value|
				draw_comparison(key, bitmap) unless compared.include?(key)
				compared << key
			end
			@compare.affixes.each do |key, value|
				unless compared.include?(key)
					draw_comparison(key, bitmap)
				end
			end
		elsif @item
			# Draw no equipped item
			bitmap.font.color = Color.new(200, 200, 200)
			bitmap.draw_text(4, 4, @width, @dim.height, "No item equipped")
		else
			# Draw no item selected
			bitmap.font.color = Color.new(200, 200, 200)
			bitmap.draw_text(4, 4, @width, @dim.height, "No item selected")
		end
		# Set bitmap
		@contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Draw Comparison
	#--------------------------------------------------------------------------
	def draw_comparison(symbol, bitmap)
		if @item.attr(symbol) != @compare.attr(symbol)
			val = @item.attr(symbol) - @compare.attr(symbol)
			text = @item.affix_label(symbol, val)
			text.gsub!("+", "") if val < 0
			if val != 0
				bitmap.font.color = val < 0 ? Color.new(255, 120, 60) : Color.new(66, 255, 100)
				lines = Kernel.wrap_text(text, 43)
				lines.each_line do |line|
					bitmap.draw_text(4, 4 + @dim.height * @i, @width, @dim.height, line)
					@i += 1
				end
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Set Items
	#--------------------------------------------------------------------------
	def set_item(item, compare)
		return if item == @item
		@item = item
		@compare = compare
		refresh
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
# ** Window_EquipTooltip
#------------------------------------------------------------------------------
#  This class displays the window for tooltips for equipment.
#==============================================================================

class Window_EquipTooltip < Interface::Tooltip
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y, width=352, normal=false)
		super(x, y, width, 192, normal)
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
		# Execute if item set
		if @item
			# If unequip item
			if @item == "Unequip"
				# Get dimensions
				@dim = bitmap.text_size(@item)
				# Draw unequip information
				bitmap.draw_text(4, 4, @width, @dim.height, "Unequips your equipped item")
			else
				# Get dimensions
				@dim = bitmap.text_size(@item.name)
				# Draw item name
				bitmap.font.color = @item.color
				bitmap.draw_text(4, 4, @width, @dim.height, @item.name)
				# Draw base stats if any
				i = 1
				bitmap.font.color = Color.new(255, 255, 255)
				if @item.attr(:pdef, true) > 0
					bitmap.font.color = Color.new(255, 255, 255)
					bitmap.draw_text(4, 4 + @dim.height * i, @width, @dim.height, @item.affix_label(:pdef, @item.attr(:pdef, true)))
					i += 1
				end
				if @item.attr(:mdef, true) > 0
					bitmap.font.color = Color.new(255, 255, 255)
					bitmap.draw_text(4, 4 + @dim.height * i, @width, @dim.height, @item.affix_label(:mdef, @item.attr(:mdef, true)))
					i += 1
				end
				if @item.attr(:atk, true) > 0
					bitmap.font.color = Color.new(255, 255, 255)
					bitmap.draw_text(4, 4 + @dim.height * i, @width, @dim.height, @item.affix_label(:atk, @item.attr(:atk, true)))
					i += 1
				end
				# Draw all affix lines
				bitmap.font.color = Color.new(155, 155, 255)
				@item.affixes.each do |key, value|
					next if Equipment::Mythical.keys.include?(key)
					lines = Kernel.wrap_text(@item.affix_label(key, @item.affixes[key]), 43)
					lines.each_line do |line|
						bitmap.draw_text(4, 4 + @dim.height * i, @width, @dim.height, line)
						i += 1
					end
				end
				@item.affixes.each do |key, value|
					next unless Equipment::Mythical.keys.include?(key)
					lines = Kernel.wrap_text(@item.affix_label(key, @item.affixes[key]), 43)
					lines.each_line do |line|
						bitmap.draw_text(4, 4 + @dim.height * i, @width, @dim.height, line)
						i += 1
					end
				end
				# Draw sell price
				price = (@item.attr(:price) * Scene_Shop::Price_Multiplier[@item.rarity]).to_i
				bitmap.font.color = Color.new(255, 255, 255)
				bitmap.draw_text(4, 192 - 4 - @dim.height, @width, @dim.height, "Sell Price: #{price} #{$data_system.words.gold}")
			end
		end
		# Set bitmap
		@contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Set Item
	#--------------------------------------------------------------------------
	def set_item(item)
		return if item == @item
		@item = item
		refresh
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
# ** Window_EquipList
#------------------------------------------------------------------------------
#  This class displays the window for selecting equipment.
#==============================================================================

class Window_EquipList < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y)
		@columns = 6
		super(x, y, 224, 384)
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
		if @slot && @actor
			@data = $game_party.get_equipment(@slot, @actor)
			@data.unshift("Unequip")
			for i in 0...@data.size
				draw_item(i, bitmap)
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
	end
	#--------------------------------------------------------------------------
	# * Set Slot
	#--------------------------------------------------------------------------
	def set_slot(slot, actor)
		@slot = slot
		@actor = actor
		refresh
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
      Rect.new(@x + 4 + ((@width - 8) / @columns) * (index % @columns), @y + 4 + 36 * (index / @columns), (@width - 8) / @columns, 34)
    end
    #--------------------------------------------------------------------------
    # * Draw Item
    #--------------------------------------------------------------------------
    def draw_item(index, bitmap)
    	# Get rect
    	rect = item_rect(index)
    	# Get item
    	item = @data[index]
    	# If it is unequip item: draw unequip icon
    	if item == "Unequip"
    		# Get icon
    		icon = RPG::Cache.gui("Menu/Unequip")
    		# Draw icon
    		bitmap.blt(rect.x - @x + 17 - icon.width / 2, rect.y - @y + 17 - icon.height / 2,
    			icon, Rect.new(0, 0, icon.width, icon.height))
    		# Return from this method
    		return
    	end
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
end

#==============================================================================
# ** Window_EquipSlots
#------------------------------------------------------------------------------
#  This class displays the window for equipment slots.
#==============================================================================

class Window_EquipSlots < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Slot Names
	#--------------------------------------------------------------------------
	Slots = {:weapon1 => "Main Hand", :weapon2 => "Off Hand", :head => "Head",
		:chest => "Chest", :feet => "Feet", :hands => "Hands", :acc1 => "Accessory",
		:acc2 => "Accessory"}
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y, width, height)
		super(x, y, width, height)
		@actor = nil
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
		if @actor
			@data = [:weapon1, :head, :chest, :feet, 
				:hands, :acc1, :acc2]
			@data.insert(1, :weapon2) if @actor.class_id == 1 || @actor.class_id == 5
			for i in 0...@data.size
				draw_item(i, bitmap)
			end
		end
		# Set bitmap
		self.contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Set Actor
	#--------------------------------------------------------------------------
	def set_actor(actor) 
		@actor = actor
		refresh
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
		@active
	end
	#--------------------------------------------------------------------------
	# * Item Rect
	#--------------------------------------------------------------------------
	def item_rect(index)
		Rect.new(@x, @y + 2 + 36 * index, @width, 36)
	end
	#--------------------------------------------------------------------------
	# * Draw Item
	#--------------------------------------------------------------------------
	def draw_item(index, bitmap)
		# Get Y position
		y = 8 + 36 * index
		# Get item
		item = @actor.equipped(@data[index])
		# If item exists
		if item
			# Get icon
			icon = RPG::Cache.icon(item.icon_name)
			# Draw icon
			bitmap.blt(24 - icon.width / 2, y + 12 - icon.height / 2, 
				icon, Rect.new(0, 0, icon.width, icon.height))
			# Draw label
			bitmap.font.color = item.color
			bitmap.draw_text(44, y, item_rect(index).width - 40, 24, item.name(true))
		else
			# Draw label
			bitmap.font.color = Color.new(160, 160, 160)
			bitmap.draw_text(16, y, item_rect(index).width - 16, 24, "[ #{Slots[@data[index]]} ]")
		end
	end
end