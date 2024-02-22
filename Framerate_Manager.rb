#==============================================================================
# ** Framerate Change Script
#------------------------------------------------------------------------------
#  This script fixes the game to work with any frame rate.
#==============================================================================

module FramerateManager
	#--------------------------------------------------------------------------
	# * Constants
	#--------------------------------------------------------------------------
	Framerate = 60
	#--------------------------------------------------------------------------
	# * Get Original 40 FPS Scale (Down)
	#--------------------------------------------------------------------------
	def FramerateManager.scale_down
		40.0 / Framerate.to_f
	end
	#--------------------------------------------------------------------------
	# * Get Original 40 FPS Scale (Up)
	#--------------------------------------------------------------------------
	def FramerateManager.scale_up
		Framerate.to_f / 40.0
	end
end

class Game_Character
	#--------------------------------------------------------------------------
	# * Update frame (move)
	#--------------------------------------------------------------------------
	def update_move
		# Convert map coordinates from map move speed into move distance
		distance = ((2 ** @move_speed) * FramerateManager.scale_down).to_i
		# If logical coordinates are further down than real coordinates
		if @y * 128 > @real_y
			# Move down
			@real_y = [@real_y + distance, @y * 128].min
		end
		# If logical coordinates are more to the left than real coordinates
		if @x * 128 < @real_x
			# Move left
			@real_x = [@real_x - distance, @x * 128].max
		end
		# If logical coordinates are more to the right than real coordinates
		if @x * 128 > @real_x
			# Move right
			@real_x = [@real_x + distance, @x * 128].min
		end
		# If logical coordinates are further up than real coordinates
		if @y * 128 < @real_y
			# Move up
			@real_y = [@real_y - distance, @y * 128].max
		end
		# If move animation is ON
		if @walk_anime
			# Increase animation count by 1.5
			@anime_count += 1.5
		# If move animation is OFF, and stop animation is ON
		elsif @step_anime
			# Increase animation count by 1
			@anime_count += 1
		end
	end
	#--------------------------------------------------------------------------
	# * Frame Update
	#--------------------------------------------------------------------------
	def update
		# Branch with jumping, moving, and stopping
		if jumping?
			update_jump
		elsif moving?
			update_move
		else
			update_stop
		end
		# If animation count exceeds maximum value
		# * Maximum value is move speed * 1 taken from basic value 18
		if @anime_count > (18 * FramerateManager.scale_up).to_i - (@move_speed * 2)
			# If stop animation is OFF when stopping
			if not @step_anime and @stop_count > 0
				# Return to original pattern
				@pattern = @original_pattern
			# If stop animation is ON when moving
			else
				# Update pattern
				@pattern = (@pattern + 1) % 4
			end
			# Clear animation count
			@anime_count = 0
		end
		# If waiting
		if @wait_count > 0
			# Reduce wait count
			@wait_count -= 1
			return
		end
		# If move route is forced
		if @move_route_forcing
			# Custom move
			move_type_custom
			return
		end
		# When waiting for event execution or locked
		if @starting or lock?
			# Not moving by self
			return
		end
		# If stop count exceeds a certain value (computed from move frequency)
		if @stop_count > (40 - @move_frequency * 2) * (6 - @move_frequency)
			# Branch by move type
			case @move_type
			when 1  # Random
				move_type_random
			when 2  # Approach
				move_type_toward_player
			when 3  # Custom
				move_type_custom
			end
		end
	end
end