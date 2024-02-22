#==============================================================================
# ** Lighting Module
#------------------------------------------------------------------------------
#  This module deals with lighting.
#==============================================================================

module Lighting
	#--------------------------------------------------------------------------
	# * List of Scenes To Ignore Lighting Module
	#--------------------------------------------------------------------------
	Inactive_Scenes = [::Scene_Battle, ::Scene_Title]
	#--------------------------------------------------------------------------
	# * Light IDs (Referenced by respective switch IDs)
	#--------------------------------------------------------------------------
	Ambient_Light = 28
	#--------------------------------------------------------------------------
	# * Light Hash
	#--------------------------------------------------------------------------
	@lights = {}
	#--------------------------------------------------------------------------
	# * Class Declaration
	#--------------------------------------------------------------------------
	class << self
		#----------------------------------------------------------------------
		# * Setup
		#----------------------------------------------------------------------
		def setup
			# Create ambient light
			create(Ambient_Light, RPG::Cache.picture("Ambient Light"), 
				Proc.new {-320 + ($game_player.screen_x - 320)}, 
					Proc.new {-240 + ($game_player.screen_y - 240)})
		end
		#----------------------------------------------------------------------
		# * Create Light
		#----------------------------------------------------------------------
		def create(light_id, bitmap, *coords)
			return if @lights[light_id]
			@lights[light_id] = Light.new(bitmap)
			if coords.size == 2
				if coords[0].is_a?(Numeric)
					@lights[light_id].x = coords[0]
				elsif coords[0].is_a?(Proc)
					@lights[light_id].add_block(:x=, coords[0])
				end
				if coords[1].is_a?(Numeric)
					@lights[light_id].y = coords[1]
				elsif coords[1].is_a?(Proc)
					@lights[light_id].add_block(:y=, coords[1])
				end
			end
		end
		#----------------------------------------------------------------------
		# * Active?
		#----------------------------------------------------------------------
		def active?
			!Inactive_Scenes.include?($scene.class)
		end
		#----------------------------------------------------------------------
		# * Update
		#----------------------------------------------------------------------
		def update
			# Update lights
			@lights.each do |key, light|
				light.visible = active? ? $game_switches[key] : false
				light.update if light.visible
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Light Class
	#--------------------------------------------------------------------------
	class Light < Sprite
		#----------------------------------------------------------------------
		# * Object Initialization
		#----------------------------------------------------------------------
		def initialize(bitmap)
			# Call superclass
			super()
			# Set up base
			self.bitmap = bitmap
			self.z = 51 # one above maximum game picture
			self.visible = false
			# Set up blocks hash
			@blocks = {}
		end
		#----------------------------------------------------------------------
		# * Add Block
		#----------------------------------------------------------------------
		def add_block(symbol, block)
			@blocks[symbol] = block
		end
		#----------------------------------------------------------------------
		# * Update
		#----------------------------------------------------------------------
		def update
			@blocks.each do |key, block|
				send(key, block.call)
			end
		end
	end
end

#==============================================================================
# ** Input Module
#------------------------------------------------------------------------------
#  This module implements lighting update into input module.
#==============================================================================

module Input
	# Add class data
	class << self
		#------------------------------------------------------------------------
		# * Alias Methods
		#------------------------------------------------------------------------
		# If the update method has not been aliased
		unless method_defined?(:sarkilas_lighting_input_update)
			# Alias the update method
			alias_method(:sarkilas_lighting_input_update, :update)
		end
		#-------------------------------------------------------------------------
		# * Frame Update
		#-------------------------------------------------------------------------
		def update
			# Call original method
			sarkilas_lighting_input_update
			# Update Lighting module
			Lighting.update
		end
	end
end