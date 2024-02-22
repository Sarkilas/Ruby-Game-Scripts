#==============================================================================
# ** Randomized Worlds
#------------------------------------------------------------------------------
#  This module allows randomized worlds.
#==============================================================================

module Randomizer
	#==========================================================================
	# * Layout object (map data with additional features)
	#==========================================================================
	class Layout
		#----------------------------------------------------------------------
		# * Object Initialization
		#----------------------------------------------------------------------
		def initialize(x, y, map_id)
			# Set coordinates
			@x = x
			@y = y
			# Load map data
			@map = load_data(sprintf("Data/Map%03d.rxdata", @map_id))
			# Get entities from map data
			@entities = @map.entities.clone
			# Randomize layout after data collection
			randomize
		end
		#----------------------------------------------------------------------
		# * Randomize Layout
		#----------------------------------------------------------------------
		def randomize
			# Shuffle entities first
			@map.entities.shuffle!
			# Perform entity actions
			for i in @map.entities.size
				# Get the map entity
				entity = @map.entities[i]
				# Get entity index
				entity_index = @entities.index(entity)
				# If part of group: get group and randomize
				if entity.group?
					group = []
					for j in @map.entities.size
						entity2 = @map.entities[j]
						group << entity2 if entity.grouped_with?(entity2)
					end
					entity.randomize(group)
				else # randomize individual entity
					@entities[entity_index].randomize
				end
			end
		end
	end
	#==========================================================================
	# * World object (collection of layouts)
	#==========================================================================
	class World
		#----------------------------------------------------------------------
		# * Object Initialization
		#----------------------------------------------------------------------
		def initialize(camera)
			@viewport = Screen::Viewport
			@camera = camera
			@layouts = []
			@tilemap = Tilemap.new(@viewport)
		end
		#----------------------------------------------------------------------
		# * Add Layout
		#----------------------------------------------------------------------
		def add_layout(layout)
			@layouts << layout
		end
		#----------------------------------------------------------------------
		# * Render
		#----------------------------------------------------------------------
		def render
			@layouts.each do |layout|
				token = layout.token
				@tilemap.add(token)
				layout.layers.each do |layer|
					map = @tilemap[token]
					map[layer.token] = layer
					map[layer.token].attach(layer.attachment)
				end
				@tilemap[token].render
			end
		end
		#----------------------------------------------------------------------
		# * Update
		#----------------------------------------------------------------------
		def update
			@tilemap.update(@camera)
			@layouts.each do |layout|
				token = layout.token
				layout.entities.each do |entity|
					entity.update(@tilemap[token].location)
				end
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Generate World
	# => width : the width in layouts
	# => height : the height in layouts
	# => prefix : the layout prefix for generation (e.g. cave_)
	#--------------------------------------------------------------------------
	def Randomizer.generate_world(width, height, prefix=nil)
		# First create a new world object
		world = World.new(Game::Camera)
		# Set up collections

	end
end