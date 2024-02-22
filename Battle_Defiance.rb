#==============================================================================
# ** Battle System - Defiance Module
#------------------------------------------------------------------------------
#  This module is for defiance methods to be included.
#==============================================================================

module Battle_Defiance
	#--------------------------------------------------------------------------
	# * Defiance Data
	# => A => [B,C]
	# => A : the skill ID
	# => B : the amount of turns until skill is performed
	# => C : the amount of defiance damage required to interrupt
	#--------------------------------------------------------------------------
	Defiance_Data = {
		80 => [4,35]		# Rising Horror
	}
	#--------------------------------------------------------------------------
	# * Create Defiance Gauge
	#--------------------------------------------------------------------------
	def create_defiance_gauge
		@defiance_gauge = Defiance_Gauge.new
	end
	#--------------------------------------------------------------------------
	# * Dispose Defiance Gauge
	#--------------------------------------------------------------------------
	def dispose_defiance_gauge
		@defiance_gauge.dispose
	end
	#--------------------------------------------------------------------------
	# * Start Defiance
	#--------------------------------------------------------------------------
	def start_defiance(user, skill_id)
		# Get skill data
		skill = $data_skills[skill_id]
		# Get defiance data
		data = Defiance_Data[skill_id]
		# Add defiance to user
		user.add_defiance(skill_id, *data)
		# Set up defiance gauge
		@defiance_gauge.set(user)
		@defiance_gauge.visible = true
	end
	#--------------------------------------------------------------------------
	# * Check Defiance Skills
	#--------------------------------------------------------------------------
	def check_defiance_skills(battler)
		if battler.has_defiance?
			perform_defiance_skill(battler)
			return true
		end
		false
	end
	#--------------------------------------------------------------------------
	# * Perform Defiance Skill
	#--------------------------------------------------------------------------
	def perform_defiance_skill(battler)
		# Set up action
		battler.current_action.kind = 1
		battler.current_action.skill_id = battler.defiance_skill
		# Add battler to action queue
		@action_battlers << battler
		# Disable gauge
		@defiance_gauge.visible = false
	end
end

class Game_Battler
	#--------------------------------------------------------------------------
	# * Attributes
	#--------------------------------------------------------------------------
	attr_reader 	:defiance
	attr_accessor 	:gauge
	#--------------------------------------------------------------------------
	# * Constants
	#--------------------------------------------------------------------------
	Defiance_Damage_Skills = {
		9 => 35
	}
	#--------------------------------------------------------------------------
	# * Add Defiance
	#--------------------------------------------------------------------------
	def add_defiance(skill_id, turns, damage)
		@defiance = [skill_id, turns, damage]
	end
	#--------------------------------------------------------------------------
	# * Defiance Damage
	#--------------------------------------------------------------------------
	def defiance_damage(damage)
		@defiance[2] -= damage
		@defiance = nil if @defiance[2] <= 0
		@gauge.refresh if @gauge
	end
	#--------------------------------------------------------------------------
	# * Has Defiance?
	#--------------------------------------------------------------------------
	def has_defiance?
		return false unless @defiance 
		@defiance[1] -= 1
		return @defiance[1] == 0
	end
	#--------------------------------------------------------------------------
	# * Get Defiance Skill
	#--------------------------------------------------------------------------
	def defiance_skill
		skill_id = @defiance[0]
		@defiance = nil
		skill_id
	end
end

class Game_Enemy < Game_Battler
	#--------------------------------------------------------------------------
	# * Aliasing
	#--------------------------------------------------------------------------
	alias_method(:sarkilas_make_action, :make_action)
end

class Defiance_Gauge
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize
		# Initialize sprites
		@container = Sprite.new
		@container.bitmap = RPG::Cache.gui("Unison Container")
		@bar = Sprite.new
		@bar.bitmap = RPG::Cache.gui("Defiance Bar")
		# Set positions of bitmaps
		@container.x = @bar.x = 16
		@container.y = @bar.y = 32
		# Hide gauge immediately
		self.visible = false
	end
	#--------------------------------------------------------------------------
	# * Set
	#--------------------------------------------------------------------------
	def set(user)
		@user = user
		@user.gauge = self
		@max = user.defiance[2]
		refresh
	end
	#--------------------------------------------------------------------------
	# * Refresh
	#--------------------------------------------------------------------------
	def refresh
		# Return if there is no user
		unless @user
			self.visible = false
			return
		end
		# Return if no defiance for user
		unless @user.defiance
			self.visible = false
			return
		end
		# Get current defiance value
		n = @user.defiance[2]
		# Change fill percentage
		percentage = n.to_f / @max.to_f
		@bar.zoom_x = percentage
	end
	#--------------------------------------------------------------------------
	# * Visible Set
	#--------------------------------------------------------------------------
	def visible=(bool)
		@container.visible = bool
		@bar.visible = bool
	end
	#--------------------------------------------------------------------------
	# * Dispose
	#--------------------------------------------------------------------------
	def dispose
		@container.dispose
		@bar.dispose
	end
end
