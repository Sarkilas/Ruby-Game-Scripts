#==============================================================================
# ** Level Up Screen
#------------------------------------------------------------------------------
#  This section deals with showing experience gains and leveling up visually.
#==============================================================================

class Window_LevelUp < Interface::Container
	#--------------------------------------------------------------------------
	# * Attr
	#--------------------------------------------------------------------------
	attr_reader :sound
	#--------------------------------------------------------------------------
	# * Module Inclusion
	#--------------------------------------------------------------------------
	include GFX_Tools
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(exp)
		super(177, 64, 286, 352)
		@exp = exp
		refresh
		self.visible = false
		self.objects[1].visible = false
		self.z = 999999
	end
	#--------------------------------------------------------------------------
	# * Refresh
	#--------------------------------------------------------------------------
	def refresh
		# If new data: freeze graphics
		Graphics.freeze if @new_data
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
		# Draw all actors in party
		for i in 0...$game_party.actors.size
			# Get actor
			actor = $game_party.actors[i]
			# Draw graphic
			draw_actor_graphic(8, 4 + 80 * i, actor, bitmap)
			# Draw name
			bitmap.draw_text(42, 4 + 80 * i, @width, 24, actor.name)
			# Draw level
			if @new_data && @new_data[i][:level] > 0
				bitmap.font.color = Color.new(180, 255, 180)
				bitmap.draw_text(8, 4 + 80 * i, @width - 16, 24, 
					"Reached level #{actor.level}!", 2)
			else
				bitmap.draw_text(8, 4 + 80 * i, @width - 16, 24, 
					"Level #{actor.level}", 2)
			end
			bitmap.font.color = Color.new(255, 255, 255)
			# Draw experience bar
			draw_bar(42, 4 + 80 * i + 28, actor.current_exp, actor.next_exp, 
				RPG::Cache.gui("Exp Bar"), bitmap, 236)
			draw_bar_numbers(42, 4 + 80 * i + 28, "Exp", actor.current_exp, 
				actor.next_exp, bitmap, 236)
			# If learned skills
			if @new_data && @new_data[i][:skills].size > 0
				# Get text width
				w = bitmap.text_size("Learned: ").width
				# Set font color
				bitmap.font.color = Color.new(180, 180, 255)
				# Draw learned text
				bitmap.draw_text(42, 4 + 80 * i + 50, @width, 24, "Learned: ")
				# Draw all learned skills
				bitmap.font.color = Color.new(255, 255, 255)
				cw = 4
				for j in 0...@new_data[i][:skills].size
					# Get skill data
					skill = $data_skills[@new_data[i][:skills][j]]
					# Draw icon
					icon = RPG::Cache.icon(skill.icon_name)
					bitmap.blt(42 + w + cw + 17 - icon.width / 2, 
						4 + 80 * i + 46 + 17 - icon.height / 2, icon, 
						Rect.new(0, 0, icon.width, icon.height))
					# Draw skill name
					bitmap.draw_text(42 + w + cw + 36, 4 + 80 * i + 50, 
						@width, 24, skill.name)
					# Add to width
					cw += bitmap.text_size(skill.name).width + 4
				end
			end
			# Talent points
			if @new_data && (@new_data[i][:talents][0] > 0 || 
				@new_data[i][:talents][1] > 0) &&
				@new_data[i][:skills].size == 0
				# Draw gained talents text
				bitmap.draw_text(8, 4 + 80 * i + 50, @width, 24, "Gained Talents!", 2)
			end
		end
		# Set bitmap
		@contents.bitmap = bitmap
		# Play sound cue if required
		Audio.se_play("Audio/SE/Chain Success") if @sound
		# Transition if needed
		Graphics.transition if @new_data
		# Reset new data
		if @new_data
			@new_data = nil
		else
			# Generate new data
			generate_new_data unless @new_data
		end
	end
	#--------------------------------------------------------------------------
	# * Generate New Data
	#--------------------------------------------------------------------------
	def generate_new_data
		# Initialize new data
		@new_data = []
		# Iterate all actors
		for i in 0...$game_party.actors.size
			# Get actor
			actor = $game_party.actors[i]
			# Create data entry
			@new_data[i] = {}
			# Get last level and skill data
			last_level = actor.level
			skills = actor.skills.clone
			# Get last talent points
			last_talents = actor.talent_points
			# Gain exp
			actor.exp += @exp
			# Set how many levels were gained
			@new_data[i][:level] = actor.level - last_level
			# Set new learned skills array
			@new_data[i][:skills] = actor.skills - skills
			# Set talent point changes
			@new_data[i][:talents] = [actor.talent_points[0] - last_talents[0], 
				actor.talent_points[1] - last_talents[1]]
			# Set sound cue flag
			@sound = actor.level - last_level > 0
		end
	end
	#--------------------------------------------------------------------------
	# * Needs Refresh
	#--------------------------------------------------------------------------
	def needs_refresh
		@new_data
	end
	#--------------------------------------------------------------------------
	# * Visibility Setting
	#--------------------------------------------------------------------------
	def visible=(bool)
		super
		self.objects[0].visible = bool
		@contents.visible = bool
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