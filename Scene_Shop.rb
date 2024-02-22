#==============================================================================
# ** Shop System
#------------------------------------------------------------------------------
#  This section contains scripts for the shop and trade system.
#==============================================================================

class Scene_Shop
	#--------------------------------------------------------------------------
	# * Sell Price Multipliers per Rarity
	#--------------------------------------------------------------------------
	Price_Multiplier = [1.0,1.5,2.0,3.0]
	#--------------------------------------------------------------------------
	# * Main Process
	#--------------------------------------------------------------------------
	def main
		# Set phase
		@phase = :buy
		# Create scene objects
		create_framework
		# Transition
		Graphics.transition
		# Main loop
		while $scene == self
			# Update modules
			Input.update
			Graphics.update
			Mouse.show_cursor(true)
			# Update scene
			update
		end
		# Freeze graphics
		Graphics.freeze
		# Dispose scene objects
		dispose_framework
	end
	#--------------------------------------------------------------------------
	# * Create Framework
	#--------------------------------------------------------------------------
	def create_framework
		# Create map
		@map = Spriteset_Map.new
		# Create interface hashes
		@windows = {}
		@buttons = {}
		# Create tooltips hash
		@tooltips = {}
		# Create windows
		@windows[:buy] = Window_ShopBuy.new(32, 64, $game_temp.shop_goods)
		@windows[:buy].bind(Proc.new {buy})
		@windows[:sell] = Window_ShopSell.new(32, 64)
		@windows[:sell].bind(Proc.new {sell})
		@windows[:help] = Window_TextHelp.new(32, 384, 576, 64)
		# Create buttons
		@buttons[:buy] = Interface::Button.new(32, 32, 288, "Buy")
		@buttons[:buy].bind(Proc.new {@phase = :buy ; @windows[:buy].refresh})
		@buttons[:sell] = Interface::Button.new(320, 32, 288, "Sell")
		@buttons[:sell].bind(Proc.new {@phase = :sell})
	end
	#--------------------------------------------------------------------------
	# * Update Scene
	#--------------------------------------------------------------------------
	def update
		# Cancel key closes
		if Input.trigger?(Keys::ESC) or Input.trigger?(Keys::MOUSE_RIGHT)
			# Play cancel SE
			$game_system.se_play($data_system.cancel_se)
			# Set map scene
			$scene = Scene_Map.new
			return
		end
		# Phase update
		case @phase
		when :buy
			@windows[:buy].visible = true
			@windows[:sell].visible = false
			@windows[:help].visible = true
			@windows[:buy].update
			@buttons[:sell].update
			@windows[:help].set_text(@windows[:buy].item ? @windows[:buy].item.description : nil)
		when :sell
			@windows[:buy].visible = false
			@windows[:sell].visible = true
			@windows[:help].visible = false
			@windows[:sell].update
			@buttons[:buy].update
			if @windows[:sell].item
				show_tooltip(@windows[:sell].item)
			else
				hide_tooltips
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Buy
	#--------------------------------------------------------------------------
	def buy
		# Play buzzer if no selected item
		unless @windows[:buy].item
			$game_system.se_play($data_system.buzzer_se)
			return
		end
		# Get item
		item = @windows[:buy].item
		# Play buzzer SE if not enough gold
		if item.price > $game_party.gold
			$game_system.se_play($data_system.buzzer_se)
			return
		end
		# Play shop SE
		$game_system.se_play($data_system.shop_se)
		# Lose gold
		$game_party.lose_gold(item.price)
		# Gain item
		$game_party.gain_item(item.id, 1)
		# Refresh window
		@windows[:buy].refresh
	end
	#--------------------------------------------------------------------------
	# * Sell
	#--------------------------------------------------------------------------
	def sell
		# Play buzzer if no selected item
		unless @windows[:sell].item
			$game_system.se_play($data_system.buzzer_se)
			return
		end
		# Get item
		item = @windows[:sell].item
		# Play shop SE
		$game_system.se_play($data_system.shop_se)
		# Gain gold
		price = (item.attr(:price) * Price_Multiplier[item.rarity]).to_i
		$game_party.gain_gold(price)
		# Lose item
		$game_party.equipment.delete(item)
		# Refresh window
		@windows[:sell].refresh
	end
	#--------------------------------------------------------------------------
	# * Show Tooltip
	#--------------------------------------------------------------------------
	def show_tooltip(item)
		# If tooltip not found: create
		unless @tooltips[item]
			create_tooltip(item)
		end
		# Hide all tooltips
		@tooltips.each_value {|tooltip| tooltip.visible = false}
		# Show tooltip
		@tooltips[item].visible = true
	end
	#--------------------------------------------------------------------------
	# * Move Tooltip
	#--------------------------------------------------------------------------
	def move_tooltip(x, y)
		# Move all tooltips
		@tooltips.each_value do |tooltip| 
			tooltip.x = x
			tooltip.y = y
		end
	end
	#--------------------------------------------------------------------------
	# * Hide Tooltips
	#--------------------------------------------------------------------------
	def hide_tooltips
		# Hide all tooltips
		@tooltips.each_value {|tooltip| tooltip.visible = false}
	end
	#--------------------------------------------------------------------------
	# * Create Tooltip
	#--------------------------------------------------------------------------
	def create_tooltip(item)
		@tooltips[item] = Window_EquipTooltip.new(32, 256, 576)
		@tooltips[item].set_item(item)
	end
	#--------------------------------------------------------------------------
	# * Dispose Framework
	#--------------------------------------------------------------------------
	def dispose_framework
		# Dispose map
		@map.dispose
		# Dispose windows
		@windows.each_value {|window| window.dispose}
		# Dispose buttons
		@buttons.each_value {|button| button.dispose}
		# Dispose tooltips
		@tooltips.each_value {|tooltip| tooltip.dispose}
	end
end

#==============================================================================
# ** Window_ShopSell
#------------------------------------------------------------------------------
#  This class displays the window for selling equipment.
#==============================================================================

class Window_ShopSell < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y)
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
		@data = $game_party.equipment.compact
		n = @data.size > 75 ? 75 : @data.size
		for i in 0...n
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
# ** Window_ShopBuy
#------------------------------------------------------------------------------
#  This class displays the window for buying shop goods.
#==============================================================================

class Window_ShopBuy < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y, shop_goods)
		@shop_goods = shop_goods
		super(x, y, 576, 320)
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
		@data = []
		for goods_item in @shop_goods
			case goods_item[0]
			when 0
				item = $data_items[goods_item[1]]
			when 1
				item = $data_weapons[goods_item[1]]
			when 2
				item = $data_armors[goods_item[1]]
			end
			if item != nil
				@data.push(item)
			end
		end
		for i in 0...@data.size
			draw_item(i, bitmap)
		end
		# Draw your current gold
		bitmap.font.color = Color.new(255, 255, 255)
		bitmap.draw_text(4, @height - 34, @width - 8, 34, "Current #{$data_system.words.gold}: #{$game_party.gold}")
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
    	item = @data[index]
    	# Get icon
    	icon = RPG::Cache.icon(item.icon_name)
    	# Draw icon
    	bitmap.blt(rect.x - @x + 17 - icon.width / 2, rect.y - @y + 17 - icon.height / 2, 
    		icon, Rect.new(0, 0, icon.width, icon.height))
    	# Draw item name
    	bitmap.font.color = item.price > $game_party.gold ? Color.new(180, 180, 180) : Color.new(255, 255, 255)
    	bitmap.draw_text(rect.x - @x + 38, rect.y - @y, rect.width, rect.height, item.name)
    	# Draw cost
    	bitmap.draw_text(rect.x - @x + 38, rect.y - @y, rect.width - 42, rect.height, "#{item.price} #{$data_system.words.gold}", 2)
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
# ** Window_TextHelp
#------------------------------------------------------------------------------
#  This class displays the window for quick help messages.
#==============================================================================

class Window_TextHelp < Interface::Container
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y, width, height)
		super(x, y, width, height)
		refresh
		self.visible = false
		self.z = 99999
	end
	#--------------------------------------------------------------------------
	# * Set Text
	#--------------------------------------------------------------------------
	def set_text(text)
		return if text == @text
		@text = text
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
		# Draw text
		if @text.is_a?(String)
			dim = bitmap.text_size(@text)
			wrapped_text = wrap_text(@text, width / 8)
			lines = 0
			wrapped_text.each_line {|line| lines += 1}
			if lines == 1
				y = @height / 2 - dim.height / 2
			else
				count = @height / dim.height
				y = @height / 2 - dim.height * (count - lines)
			end
			i = 0
			wrapped_text.each_line do |line|
				bitmap.draw_text(8, y + i * dim.height, @width - 16, dim.height, line)
				i += 1
			end
		end
		# Set bitmap to contents
		@contents.bitmap = bitmap
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
    # * Set visible state
    #--------------------------------------------------------------------------
    def visible=(bool)
    	self.objects.each {|obj| obj.visible = bool}
    	@contents.visible = bool
    	self.objects[1].visible = false
    	@visible = bool
    end
end