#==============================================================================
# ** Battle System - Unison Attacks Module
#------------------------------------------------------------------------------
#  This module is for unison attacks methods to be included.
#==============================================================================

module Battle_Unison_Attacks
	#--------------------------------------------------------------------------
	# * Constants
	#--------------------------------------------------------------------------
	System_Switch_ID = 20	# the switch ID to enable module
	#--------------------------------------------------------------------------
	# * Unison Attacks Data
	# => A => [[B,C,...],[D,E,...]]
	# => A 			: The ID of the skill in database
	# => B,C,... 	: The ID of the actor in database
	# => D,E,...	: The ID of the skill used by each actor
	#--------------------------------------------------------------------------
	Data = {
		56 => [[1,2],[57,58]]		# Cyclone Strike
	}
	#--------------------------------------------------------------------------
	# * Initialize Unison Attacks (resource load)
	#--------------------------------------------------------------------------
	def initialize_unison_attacks
		@unison_window = Window_UnisonAttacks.new
		if $game_switches[System_Switch_ID]
			@unison_gauge = UnisonPower_Gauge.new
		end
	end
	#--------------------------------------------------------------------------
	# * Check Unison Attack
	#--------------------------------------------------------------------------
	def check_unison_attack
		# Ignore if disabled
		return unless $game_switches[System_Switch_ID]
		# Return if actor's turn or actions performing
		return unless can_unison_attack?
		# If Q pressed
		if Input.trigger?(Keys::Q)
			# Play SE
			$game_system.se_play($data_system.decision_se)
			# Start unison attack select
			start_unison_attack_select
		end
	end
	#--------------------------------------------------------------------------
	# * Can Unison Attack?
	#--------------------------------------------------------------------------
	def can_unison_attack?
		return false if @actor_command_window.visible
		return false if @enemy_window.visible
		return false if @actor_arrow
		return false if @skill_window
		return true
	end
	#--------------------------------------------------------------------------
	# * Start Unison Attack Select
	#--------------------------------------------------------------------------
	def start_unison_attack_select
		@unison_window.visible = true
	end
	#--------------------------------------------------------------------------
	# * Update Unison Attack Select
	#--------------------------------------------------------------------------
	def update_unison_attack_select
		# Update window
		@unison_window.update
		# Click event
		if @unison_window.item && Input.trigger?(Keys::MOUSE_LEFT)
			# Play buzzer and return if not enough power
			if $game_temp.unison_power < 50 or !can_perform_unison_attack?(@unison_window.item)
				$game_system.se_play($data_system.buzzer_se)
				return
			end
			# Play SE
			$game_system.se_play($data_system.decision_se)
			# Make action
			make_unison_attack_action(@unison_window.item)
			# Make window hidden
			@unison_window.visible = false
			# Finally return
			return
		end
		# Cancel event
		if Input.trigger?(Keys::MOUSE_RIGHT) || Input.trigger?(Keys::ESC)
			# Play SE
			$game_system.se_play($data_system.cancel_se)
			# Hide unison attack select
			@unison_window.visible = false
		end
	end
	#--------------------------------------------------------------------------
	# * Can Perform Unison Attack?
	#--------------------------------------------------------------------------
	def can_perform_unison_attack?(skill_id)
		# Set up temporary array
		found = []
		# Get actors
		actors = Data[skill_id][0]
		# If any actor is not in party or dead: return false
		for j in 0...4
			actor = $game_party.actors[j]
			next unless actor
			for i in 0...actors.size
				return false if actor.dead?
				found << actor.id if actor.id == actors[i]
			end
		end
		# Return
		return found.size == actors.size
	end
	#--------------------------------------------------------------------------
	# * Make Unison Attack Action
	#--------------------------------------------------------------------------
	def make_unison_attack_action(skill_id)
		# Get data
		data = Data[skill_id]
		# Get actors
		actors = data[0]
		# Get skills
		skills = data[1]
		# Set battler actions
		for i in 0...actors.size
			# Get battler for actor
			battler = get_actor_battler(actors[i])
			# Set up action
			battler.current_action.kind = 1
			battler.current_action.skill_id = skills[i]
			# Add battler to action queue
			@action_battlers << battler
		end
	end
end

#==============================================================================
# ** Battle System - Unison Attacks Gauge
#------------------------------------------------------------------------------
#  This class displays unison attack gauge.
#==============================================================================

class UnisonPower_Gauge
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize
		# Create sprites
		@container = Sprite.new
		@bar = Sprite.new
		@center = Sprite.new
		# Add bitmaps
		@container.bitmap = RPG::Cache.gui("Unison Container")
		@bar.bitmap = RPG::Cache.gui("Unison Bar")
		@center.bitmap = RPG::Cache.gui("Unison Arrow")
		# Position sprites
		@container.x = @bar.x = 16
		@container.y = @bar.y = 300
		@center.x = 320 - @center.bitmap.width / 2
		@center.y = 300 - @center.bitmap.height + 4
		# Update once
		update
	end
	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update
		# Get fill percentage
		fill_percentage = $game_temp.unison_power.to_f / 100.0
		# Set to zoom x
		@bar.zoom_x = fill_percentage
	end
	#--------------------------------------------------------------------------
	# * Dispose
	#--------------------------------------------------------------------------
	def dispose
		@container.dispose
		@bar.dispose
		@center.dispose
	end
end

#==============================================================================
# ** Battle System - Unison Attacks List Window
#------------------------------------------------------------------------------
#  This window shows unison attacks and lets the player select them.
#==============================================================================

class Window_UnisonAttacks < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize
		@columns = 2
		super(0, 0, 640, 196)
		refresh
		@fade_in = true
		create_tooltips
		self.visible = false
	end
	#--------------------------------------------------------------------------
	# * Clickable?
	#--------------------------------------------------------------------------
	def clickable?
		false
	end
	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update
		@old_index = @index
		super
		@tooltips.each {|tooltip| tooltip.visible = false}
		unless @index < 0
			@tooltips[@index].visible = true
			@tooltips[@index].x = 320 - @tooltips[@index].width / 2
			@tooltips[@index].y = @y + @height
		end
	end
	#--------------------------------------------------------------------------
	# * Create Tooltips
	#--------------------------------------------------------------------------
	def create_tooltips
		# Set up array
		@tooltips = []
		# Create all tooltips
		for i in 0...@data.size
			@tooltips << Window_SkillTooltip.new(@actor, $data_skills[@data[i]])
		end
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
		@data = get_skills
		for i in 0...@data.size
			draw_item(i, bitmap)
		end
		# Set bitmap
		self.contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Get Skills
	#--------------------------------------------------------------------------
	def get_skills
		arry = []
		Battle_Unison_Attacks::Data.each do |key, value|
			actor_in_party = []
			value[0].size.times {actor_in_party << false}
			for i in 0...value[0].size
				for j in 0...$game_party.actors.size
					actor_in_party[i] = true if $game_party.actors[j].id == value[0][i]
				end
			end
			met = true
			actor_in_party.each do |bool|
				met = false unless bool
			end
			next unless met
			arry << key
		end
		arry
	end
	#--------------------------------------------------------------------------
	# * Visibility Setting
	#--------------------------------------------------------------------------
	def visible=(bool)
		super
		self.objects[0].visible = bool
		self.contents.visible = bool
		@tooltips.each {|tooltip| tooltip.visible = bool unless bool}
	end
	#--------------------------------------------------------------------------
    # * Item Rect
    #--------------------------------------------------------------------------
    def item_rect(index)
      Rect.new(@x + 8 + ((@width - 16) / 2) * (index % @columns), @y + 8 + 36 * (index / @columns), (@width - 16) / 2 - 4, 36)
    end
    #--------------------------------------------------------------------------
    # * Skill
    #--------------------------------------------------------------------------
    def skill
    	@index >= 0 ? $data_skills[@data[@index]] : nil
    end
    #--------------------------------------------------------------------------
    # * Draw Item
    #--------------------------------------------------------------------------
    def draw_item(index, bitmap)
    	# Get Y position
    	x = 8 + ((@width - 16) / 2) * (index % @columns)
    	y = 8 + 36 * (index / @columns)
    	# Get skill
    	skill = $data_skills[@data[index]]
    	# Get icon
    	icon = RPG::Cache.icon(skill.icon_name)
    	# Draw icon
    	bitmap.blt(x + 17 - icon.width / 2, y + 18 - icon.height / 2, 
    		icon, Rect.new(0, 0, icon.width, icon.height))
    	# Draw label
    	bitmap.font.color = Color.new(255, 255, 255)
    	bitmap.draw_text(x + 37, y, item_rect(index).width - 40, 36, skill.name)
    end
    #--------------------------------------------------------------------------
    # * Dispose
    #--------------------------------------------------------------------------
    def dispose
    	super
    	@tooltips.each {|tooltip| tooltip.dispose}
    end
end

#==============================================================================
# ** Game_Temp Update
#------------------------------------------------------------------------------
#  Addition for unison power.
#==============================================================================

class Game_Temp
	#--------------------------------------------------------------------------
	# * Aliasing
	#--------------------------------------------------------------------------
	alias_method(:sarkilas_unison_temp_initialize, :initialize)
	#--------------------------------------------------------------------------
	# * Accessors
	#--------------------------------------------------------------------------
	attr_accessor :unison_power
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize
		sarkilas_unison_temp_initialize
		@unison_power = 0
	end
end