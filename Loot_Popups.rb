#==============================================================================
# ** Map Module for Loot Popups
#------------------------------------------------------------------------------
#  This module is for loot display on map when loot is acquired.
#==============================================================================

module Loot_Popups
	#--------------------------------------------------------------------------
	# * Update Loot Popup
	#--------------------------------------------------------------------------
	def update_loot_popup
		# Setup loot popup
		setup_loot_popup unless @loot_popup
		# Return if no loot popup
		return unless @loot_popup
		# Update loot popup window
		@loot_popup.update 
		# If done showing loot: dispose and go to next
		if @loot_popup.done?
			@loot_popup.dispose
			@loot_popup = nil
			setup_loot_popup
		end
	end
	#--------------------------------------------------------------------------
	# * Setup Loot Popup
	#--------------------------------------------------------------------------
	def setup_loot_popup
		# Return if popups are disabled
		return if $game_temp.item_log.size == 0
		# Get earliest item data
		item = $game_temp.item_log.shift
		# Get dimensions of item
		measure = Bitmap.new(640, 480)
		obj = $data_items[item[0]]
		width = 64 + measure.text_size("#{obj.name} x #{item[1]}").width
		# Get X-axis position
		x = 320 - width / 2
		# Create loot popup window
		@loot_popup = Loot_Popup.new(x, 352, width, 64, item)
	end
end

class Loot_Popup < Interface::Container
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y, width, height, item)
		super(x, y, width, height)
		@item = item
		refresh
		self.visible = true
		self.opacity = 0
		self.z = 99999
		create_flash
	end
	#--------------------------------------------------------------------------
	# * Done?
	#--------------------------------------------------------------------------
	def done? ; @flash_phase >= 4 ; end
	#--------------------------------------------------------------------------
	# * Create Flash
	#--------------------------------------------------------------------------
	def create_flash
		# Create flash sprite
		@flash = Sprite.new
		@flash.x = self.x
		@flash.y = self.y
		# Create bitmap for sprite
		@flash.bitmap = Bitmap.new(@width, @height)
		# Fill bitmap with white
		@flash.bitmap.fill_rect(0, 0, @width, @height, Color.new(255, 255, 255))
		# Set start opacity to 0
		@flash.opacity = 0
		# Set flash phase to 0
		@flash_phase = 0
		# Play loot SE
		Audio.se_play("Audio/SE/Item")
	end
	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update
		# Update superclass
		super
		# Update flash if necessary
		case @flash_phase
		when 0 # quickly fade in
			@flash.opacity += 50
			self.opacity = self.opacity + 35
			@flash_phase += 1 if @flash.opacity >= 255
		when 1 # fade out
			@flash.opacity -= 25
			if @flash.opacity <= 0
				@flash_phase += 1
				@wait = 200
			end
		when 2 # wait designated time
			@wait -= 1
			@flash_phase += 1 if @wait <= 0
		when 3 # fade out popup
			self.fade_out
			@flash_phase += 1 if self.opacity <= 0
		end
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
		# Draw obtained text
		bitmap.font.color = Color.new(255, 180, 180)
		bitmap.draw_text(8, 0, @width, 32, "Obtained")
		# Get data object
		obj = $data_items[@item[0]]
		# Get dimensions
		dim = bitmap.text_size(obj.name)
		# Draw item icon
		icon = RPG::Cache.icon(obj.icon_name)
		bitmap.blt(8, dim.height + 12 + dim.height / 2 - icon.height / 2, icon, Rect.new(0, 0, icon.width, icon.height))
		# Draw item name
		bitmap.font.color = Color.new(255, 255, 255)
		bitmap.draw_text(12 + icon.width, dim.height + 12, @width, dim.height, "#{obj.name} x #{@item[1]}")
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
    #--------------------------------------------------------------------------
    # * Dispose
    #--------------------------------------------------------------------------
    def dispose
    	super
    	@flash.dispose
    end
end