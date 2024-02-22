#==============================================================================
# ** Battle System
#------------------------------------------------------------------------------
#  This section contains scripts for altering battle system and its interface.
#==============================================================================

class Scene_Battle
	#--------------------------------------------------------------------------
	# * Module Inclusion
	#--------------------------------------------------------------------------
	include Battle_Unison_Attacks
	include Battle_Defiance
	#--------------------------------------------------------------------------
	# * Alias Methods
	#--------------------------------------------------------------------------
	alias_method(:sarkilas_battle_end, :battle_end)
	alias_method(:sarkilas_turn_ending, :turn_ending)
	alias_method(:sarkilas_create_viewport, :create_viewport)
	alias_method(:sarkilas_start_enemy_select, :start_enemy_select)
	alias_method(:sarkilas_end_enemy_select, :end_enemy_select)
	alias_method(:sarkilas_terminate, :terminate)
	#--------------------------------------------------------------------------
	# * Create Viewport
	#--------------------------------------------------------------------------
	def create_viewport
		# Create viewport calls
		sarkilas_create_viewport
		initialize_unison_attacks
		# Create defiance gauge
		create_defiance_gauge
		# Create loot window
		@loot = Loot.new
		# Create enemy select
		@enemy_window = Window_EnemySelect.new($game_troop.enemies)
	end
	#--------------------------------------------------------------------------
	# * End of Turn Effects
	#--------------------------------------------------------------------------
	def perform_turn_effects
		# Mana regeneration
		@active_battler.sp += @active_battler.mana_regen
		# Update passives
		@active_battler.update_passives({:phase => :turn_end, :user => @active_battler})
		# Life regeneration
		regen = @active_battler.get_stat(:regen)
		if regen > 0
			@active_battler.hp += ((@active_battler.maxhp.to_f * regen) / 100).ceil
		end
		# Call to talents
		@active_battler.update_talents({:phase => :turn_end, :user => @active_battler})
		# Update cooldowns
		@active_battler.update_cooldowns
		# Update unison
		if $game_switches[System_Switch_ID]
			$game_temp.unison_power = [[100, $game_temp.unison_power + 2].min, 0].max
			@unison_gauge.update
		end
		# Refresh status
		@status_window.refresh
		# Refresh defiance gauge
		@defiance_gauge.refresh
	end
	#--------------------------------------------------------------------------
	# * Guard Effects
	#--------------------------------------------------------------------------
	def perform_guard_effects
		# Call to talents
		@active_battler.update_talents({:phase => :guard, :user => @active_battler})
	end
	#--------------------------------------------------------------------------
	# * Start Enemy Select
	#--------------------------------------------------------------------------
	def start_enemy_select
		sarkilas_start_enemy_select
		@enemy_window.refresh
		@enemy_window.visible = true
	end
	#--------------------------------------------------------------------------
	# * Update Enemy Select
	#--------------------------------------------------------------------------
	def update_enemy_select
		# Update and show enemy select
		@enemy_window.update
		# If an item is selected: set index
		if @enemy_window.item
			if @enemy_window.item.index != @enemy_arrow.index
				@enemy_arrow.index = @enemy_window.item.index
			end
			return
		end
	end
	#--------------------------------------------------------------------------
	# * Update Actor Select
	#--------------------------------------------------------------------------
	def update_actor_select
		# Iterate all enemies
		for i in 0...$game_party.actors.size
			# Get battler
			battler = $game_party.actors[i]
			# Update actor status
			@status_window.update(true)
			# Get the actor sprite
			sprite = @spriteset.actor_sprites[battler.index]
			# If in bounds
			if Mouse.in_bounds?(sprite) && @status_window.index < 0
				@actor_arrow.index = battler.index
			end
			# If actor selected from window: set arrow index
			@actor_arrow.index = battler.index if @status_window.index == i
		end
	end
	#--------------------------------------------------------------------------
	# * Turn Ending
	#--------------------------------------------------------------------------
	def turn_ending
		# Call base method
		sarkilas_turn_ending
		# Search all battle event pages
		for index in 0...$data_troops[@troop_id].pages.size
			# Get event page
			page = $data_troops[@troop_id].pages[index]
			# If this page span is [turn]
			if page.span == 1
				# Clear action completed flags
				$game_temp.battle_event_flags[index] = false
			end
		end
		# Iterate all actors
		for member in $game_party.actors + $game_troop.enemies
			next unless member.exist?
			for state in member.battler_states
				next unless Skills::State_FX.has_key?(state.id)
				Skills.process_effect({:battler => member, :user => state.user}, &Skills::State_FX[state.id])
			end
		end
	end
	#--------------------------------------------------------------------------
	# * End Enemy Select
	#--------------------------------------------------------------------------
	def end_enemy_select
		sarkilas_end_enemy_select
		@enemy_window.visible = false
	end
	#--------------------------------------------------------------------------
	# * Battle Ends
	#     result : results (0:win 1:lose 2:escape)
	#--------------------------------------------------------------------------
	def battle_end(result)
		# Reset all actor class resources
		$game_party.actors.each {|actor| actor.clr = 0 ; actor.reset_stats}
		# Dispose of levelup
		@levelup.dispose if @levelup
		# Call aliased method
		sarkilas_battle_end(result)
	end
	#--------------------------------------------------------------------------
	# * Target Decision
	#--------------------------------------------------------------------------
	def target_decision(obj = nil)
		# Collect targets
		if obj != nil
			set_target_battlers(obj.scope)
			if obj.extension.include?("TARGETALL")
				@target_battlers = []
				if obj.scope != 5 or obj.scope != 6
					for target in $game_troop.enemies + $game_party.actors
						@target_battlers.push(target) if target.exist?
					end
				else
					for target in $game_troop.enemies + $game_party.actors
						@target_battlers.push(target) if target != nil && target.hp0?
					end
				end
			end
			@target_battlers.delete(@active_battler) if obj.extension.include?("OTHERS")
			if obj.extension.include?("RANDOMTARGET")
				randum_targets = @target_battlers.dup
				@target_battlers = [randum_targets[rand(randum_targets.size)]]
			end
		else
			@target_battlers = make_attack_targets
		end
		# If user is taunted: check for taunt
		if @active_battler.taunted?
			target = @active_battler.check_taunt
			if obj
				target = @target_battlers if obj.scope == 2
			end
			@target_battlers = [target] if @target_battlers.include?(target)
		end
		# Finish decisions
		if @target_battlers.size == 0
			action = @active_battler.recover_action
			@spriteset.set_action(@active_battler.actor?, @active_battler.index, action)
		end
		@spriteset.set_target(@active_battler.actor?, @active_battler.index, @target_battlers)
	end
	#--------------------------------------------------------------------------
	# * Start Phase 5 (loot)
	#--------------------------------------------------------------------------
	def start_phase5
		# Set phase
		@phase = 5
		# Gain experience
		@levelup = Window_LevelUp.new(exp_gained)
		# Generate treasure
		@loot.generate_treasure
		# Show loot window
		@loot.visible = true
		# Set phase wait count
		@phase5_wait_count = 100
	end
	#--------------------------------------------------------------------------
	# * Terminate
	#--------------------------------------------------------------------------
	def terminate
		sarkilas_terminate
		dispose_defiance_gauge
		@unison_window.dispose
		@unison_gauge.dispose if $game_switches[Battle_Unison_Attacks::System_Switch_ID]
	end
end

class RPG::State
	#--------------------------------------------------------------------------
	# * User (the user that applied the state to target)
	#--------------------------------------------------------------------------
	def user ; @user ; end
	#--------------------------------------------------------------------------
	# * Set User
	#--------------------------------------------------------------------------
	def user=(battler)
		@user = battler
	end
end

class Game_Battler
	#--------------------------------------------------------------------------
	# * Constants
	#--------------------------------------------------------------------------
	Trigger_Element_ID = 28
	#--------------------------------------------------------------------------
	# * Attr Readers
	#--------------------------------------------------------------------------
	attr_reader :skill_power
	#--------------------------------------------------------------------------
	# * Alias Methods
	#--------------------------------------------------------------------------
	alias_method(:sarkilas_add_state, :add_state)
	alias_method(:sarkilas_remove_state, :remove_state)
	#--------------------------------------------------------------------------
	# * Add State
	#--------------------------------------------------------------------------
	def add_state(state_id, force = false)
		# Check if state is already affecting the actor
		exists = @states.include?(state_id)
		# Perform base method
		sarkilas_add_state(state_id, force)
		# Return if nothing has changed
		return if exists or !@states.include?(state_id)
		# Add stats from data
		if Skills::State_Attributes.has_key?(state_id)
			Skills::State_Attributes[state_id].each do |stat, value|
				if value.is_a?(Proc)
					n = Skills.process_effect(self, &value)
					add_stat(stat, n)
				else
					add_stat(stat, value)
				end
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Remove State
	#--------------------------------------------------------------------------
	def remove_state(state_id, force = false)
		# Check if the state is already not affecting the actor
		exists = !@states.include?(state_id)
		# Perform base method
		sarkilas_remove_state(state_id, force)
		# Return if nothing has changed
		return if exists or @states.include?(state_id)
		# Remove stats from data
		if Skills::State_Attributes.has_key?(state_id)
			Skills::State_Attributes[state_id].each do |stat, value|
				if value.is_a?(Proc)
					n = Skills.process_effect(self, &value)
					add_stat(stat, -n)
				else
					add_stat(stat, -value)
				end
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Hit Effects
	#--------------------------------------------------------------------------
	def hit_effects(other, vars)
		# Affix effects for actors
		if actor?
			Skills::Effects.each do |key, effect|
				# Ignore if not a symbol
				next unless key.is_a?(Symbol)
				# Check if stat value is not 0
				next if self.get_stat(key) == 0
				# Execute block
				Skills.process_effect({:user => self, :other => other, 
					:skill => vars[:skill], :type => vars[:type]}, &Skills::Effects[key])
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Skill Effect
	#--------------------------------------------------------------------------
	def skill_effect(user, skill)
		# Set all pre-values to false
		self.critical = @evaded = @missed = false
		# Ensure scopes match before performing effects
		if ((skill.scope == 3 or skill.scope == 4) and self.hp == 0) or
			((skill.scope == 5 or skill.scope == 6) and self.hp >= 1)
			return false
		end
		# Set base values first
		effective = false
		effective |= skill.common_event_id > 0
		# Calculate skill hit
		hit = skill.hit
		hit *= set_skill_hit(user, skill)
		hit_result = (rand(100) < hit)
		effective |= hit < 100
		# Get skill result if hit
		effective |= set_skill_result(user, skill, effective) if hit_result
		# Process states only if skill hit
		if hit_result
			effective |= set_skill_state_change(user, skill, effective)
		else
			@missed = true unless @evaded
		end
		# Fix miss/evade
		self.damage = nil unless $game_temp.in_battle
		self.damage = POP_EVA if @evaded
		self.damage = POP_MISS if @missed
		# Process skill specific hit effects if necessary
		if Skills::Effects[skill.id]
			Skills.process_effect({:user => user, :target => self}, &Skills::Effects[skill.id])
		end
		# Process general hit effects
		user.hit_effects(self, {:skill => skill.id, :type => :attack}) 
		hit_effects(user, {:skill => skill.id, :type => :defend}) 
		# Process passives
		user.process_passives(self, self.critical, skill)
		# Update talents if actor
		if user.actor?
			user.update_talents({:phase => :skill, :id => skill.id, 
				:damage => self.damage, :hit => !(@evaded || @missed), 
				:target => self, :critical => self.critical, :user => user})
		end
		if actor?
			update_talents({:phase => :skill, :id => skill.id, 
				:damage => self.damage, :hit => !(@evaded || @missed), 
				:target => self, :critical => self.critical, :user => user, :guarding => self.guarding?})
		end
		# If not evaded or missed: gain secondary resource where applicable and deal defiance damage
		unless @evaded || @missed
			if user.actor? && Skills::Secondary.include?(skill.id)
				user.clr = user.clr + Skills::Secondary[skill.id]
			end
			if Defiance_Damage_Skills.has_key?(skill.id) && @defiance
				defiance_damage(Defiance_Damage_Skills[skill.id])
			end
		end
		# Return effective state
		return effective
	end
	#--------------------------------------------------------------------------
	# * Set Skill Damage Value
	#--------------------------------------------------------------------------
	def set_skill_damage_value(user, skill)
    	power = set_skill_power(user, skill)
		if power > 0
			power -= (self.pdef * skill.pdef_f) / 100
			power -= (self.mdef * skill.mdef_f) / 100
			power = [power, 1].max
		end
		rate = set_skill_rate(user, skill)
		rate = [rate, 0].max
		self.damage = power * rate / 20
		self.damage += state_hit_effects(user, false)
		self.damage *= elements_correct(skill.element_set)
		self.damage /= 100
		vars = {:phase => :skill, :user => user, :target => self, :damage => self.damage}
		self.damage += talent_modifiers(vars)
	end
	#--------------------------------------------------------------------------
	# * Set Skill Power
	#--------------------------------------------------------------------------
	def set_skill_power(user, skill)
		# Get base power
		skill_power = skill.power.to_f
		if skill.element_set.include?(9) && skill.sp_cost == 0
    		skill_power *= user.skill_power
    	end
    	# Calculate actual skill power
		power = skill.pdef_f > skill.mdef_f ? user.atk : user.spell_atk
		power = (power.to_f * (skill_power.to_f / 100.0)).round
		return power
	end
	#--------------------------------------------------------------------------
	# * Process Passives
	#--------------------------------------------------------------------------
	def process_passives(target, critical, skill=nil)
		update_passives({:user => self, :target => target, 
				:skill => skill, :critical => critical})
	end
	#--------------------------------------------------------------------------
	# * Process Passives
	#--------------------------------------------------------------------------
	def update_passives(vars)
		# Return if not an actor
		return unless actor?
		# Iterate all learned skills
		self.skills.each do |sk|
			# Ignore if not a passive skill
			next unless Skills::Passives.has_key?(sk)
			# Process the effect
			Skills.process_effect(vars, &Skills::Passives[sk])
		end
	end
	#--------------------------------------------------------------------------
	# * Attack Effect
	#--------------------------------------------------------------------------
	def attack_effect(attacker)
		self.critical = @evaded = @missed = false
		hit_result = (rand(100) < attacker.hit)
		set_attack_result(attacker) if hit_result
		weapon = attacker.actor? ? $data_weapons[attacker.weapon_id] : nil
		if hit_result
			set_attack_state_change(attacker)
		else
			self.critical = false
			@missed = true
		end
		# Update talents if actor
		if attacker.actor?
			attacker.update_talents({:phase => :attack, 
				:damage => self.damage, :hit => !(@evaded || @missed), 
				:target => self, :critical => self.critical, :user => attacker})
		end
		# Process general hit effects
		attacker.hit_effects(self, {:skill => 0, :type => :attack})
		hit_effects(attacker, {:skill => 0, :type => :defend})
		# Process passives
		attacker.process_passives(self, self.critical)
		self.damage = POP_EVA if @evaded
		self.damage = POP_MISS if @missed
		return true
	end
	#--------------------------------------------------------------------------
	# * Set Attack Damage Value
	#--------------------------------------------------------------------------
	def set_attack_damage_value(attacker)
		atk = [attacker.atk - self.pdef, 1].max
		atk = (attacker.atk * 0.1).to_i if atk < attacker.atk * 0.1
		self.damage = [atk, 1].max
		self.damage += state_hit_effects(attacker)
		self.damage = [self.damage, 1].max
		self.damage *= elements_correct(attacker.element_set)
		self.damage /= 100
		vars = {:phase => :attack, :user => attacker, :target => self, :damage => self.damage}
		self.damage += talent_modifiers(vars)
	end
	#--------------------------------------------------------------------------
	# * Talent Modifiers
	#--------------------------------------------------------------------------
	def talent_modifiers(vars)
		# Set value
		n = 0
		# Check self talents if actor
		n += talent_mods(vars) if actor?
		# Check attacker talents if actor
		n += vars[:user].talent_mods(vars) if vars[:user].actor?
		# Return value
		n
	end
	#--------------------------------------------------------------------------
	# * Hit Effects
	#--------------------------------------------------------------------------
	def state_hit_effects(attacker, basic=true)
		# Set start value
		value = 0
		# User state effects
		for state_id in attacker.states
			# Run only if an available process
			next unless Skills::State_FX_Hit.has_key?(state_id)
			# Process the hit effect
			value += Skills.process_effect({:owner => :user, :user => attacker, 
				:target => self, :basic => basic}, &Skills::State_FX_Hit[state_id])
		end
		# Target state effects
		for state_id in self.states
			# Run only if an available process
			next unless Skills::State_FX_Hit.has_key?(state_id)
			# Process the hit effect
			value += Skills.process_effect({:owner => :target, :user => attacker, 
				:target => self, :basic => basic}, &Skills::State_FX_Hit[state_id])
		end
		# Return the value
		value
	end
	#--------------------------------------------------------------------------
	# * Consume Skill Cost
	#--------------------------------------------------------------------------
	def consum_skill_cost(skill)
		return false unless skill_can_use?(skill.id)
		if Skills::Cooldowns.has_key?(skill.id)
			set_cooldown(skill.id)
		end
		cost = calc_sp_cost(self, skill)
		return self.hp -= cost if skill.extension.include?("CONSUMEHP")
		if actor? && skill.element_set.include?(9)
			@skill_power = self.clr
			if cost > 0
				return self.clr = self.clr - cost
			else
				return self.clr = 0
			end
		else
			return self.sp -= cost
		end
	end 
	#--------------------------------------------------------------------------
	# * Skill Can Use
	#--------------------------------------------------------------------------
	def skill_can_use?(skill_id)
		# Get skill data
		skill = $data_skills[skill_id]
		# Always true if skill is a trigger skill
		return true if skill.element_set.include?(Trigger_Element_ID)
		# Cannot be used if on cooldown
		return false if cooldown?(skill_id)
		# If user is an actor: check for secondary costs
		if actor?
			if skill.element_set.include?(9)
				return false if skill.sp_cost > self.clr
				return false if skill.sp_cost == 0 && self.clr == 0
			end
		end
		# Life cost extension
		if skill.extension.include?("CONSUMEHP")
			return false if calc_sp_cost(self, skill) >= self.hp
		elsif !skill.element_set.include?(9)
			return false if calc_sp_cost(self, skill) > self.sp
		end
		# Cannot use if dead or silenced
		return false if dead?
		return false if self.restriction == 1
		# Ensure occasion matches timing
		occasion = skill.occasion
		return (occasion == 0 or occasion == 1) if $game_temp.in_battle
		return (occasion == 0 or occasion == 2)
	end  
end

class Window_BattleSkills < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(actor)
		@columns = 2
		super(0, 0, 640, 196)
		@actor = actor
		refresh
		@fade_in = true
		create_tooltips
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
		# Only draw if actor
		if @actor
			# Draw all options
			@data = @actor.skills.clone
			for i in 0...@data.size
				next unless @data[i]
				if $data_skills[@data[i]].element_set.include?(26)
					@data.delete_at(i)
				end
				i -= 1
			end
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
    	# Draw cooldown
    	if @actor.cooldown?(skill.id)
	    	bitmap.font.color = Color.new(255, 120, 255)
	    	bitmap.draw_text(x + 4, y, item_rect(index).width - 16, 36, @actor.cooldown(skill.id).to_s, 2)
    	# Draw cost
    	elsif skill.sp_cost > 0
	    	color = skill.element_set.include?(9) ? Game_Actor::Resources[@actor.class_id][:color] : Color.new(66, 134, 255)
	    	bitmap.font.color = color
	    	bitmap.draw_text(x + 4, y, item_rect(index).width - 16, 36, skill.sp_cost.to_s, 2)
	    end
    end
    #--------------------------------------------------------------------------
    # * Dispose
    #--------------------------------------------------------------------------
    def dispose
    	super
    	@tooltips.each {|tooltip| tooltip.dispose}
    end
end

class Window_EnemySelect < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(enemies)
		@enemies = enemies
		super(320, 320 - 20 - enemies.size * 34, 256, 16 + enemies.size * 34)
		@fade_in = false
		self.visible = false
	end
	#--------------------------------------------------------------------------
	# * Refresh
	#--------------------------------------------------------------------------
	def refresh
		# Call superclass
		super
		# Create bitmap
		bitmap = Bitmap.new(@width, @height)
		# Draw all enemies
		@data = existing_battlers
		for i in 0...@data.size
			draw_enemy(i, bitmap)
		end
		# Add bitmap to contents
		@contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Existing Battlers
	#--------------------------------------------------------------------------
	def existing_battlers
		arry = []
		@enemies.each {|enemy| arry << enemy if enemy.exist?}
		arry
	end
	#--------------------------------------------------------------------------
	# * Clickable?
	#--------------------------------------------------------------------------
	def clickable? ; false ; end
	#--------------------------------------------------------------------------
    # * Item Rect
    #--------------------------------------------------------------------------
    def item_rect(index)
      Rect.new(@x, @y + 8 + 34 * index, @width, 32)
    end
	#--------------------------------------------------------------------------
	# * Draw Enemy
	#--------------------------------------------------------------------------
	def draw_enemy(index, bitmap)
		# Get enemy
		enemy = @data[index]
		# Get X
		y = 8 + 34 * index
		# Draw enemy name
		bitmap.draw_text(8, y, @width, 32, enemy.name)
		# Draw health bar
		bitmap.fill_rect(8, y + 26, @width - 16, 4, Color.new(0, 0, 0))
		perc = enemy.hp.to_f / enemy.maxhp.to_f
		bitmap.fill_rect(9, y + 27, (@width - 18) * perc, 2, Color.new(255, 0, 0))
		# Draw states
		for i in 0...enemy.states.size
			state_id = enemy.states[i]
			state = $data_states[state_id]
			icon = RPG::Cache.gui("States/#{state.name}")
			bitmap.blt(252 - 26 - (26 * i), y + 16 - icon.height / 2, icon, Rect.new(0, 0, icon.width, icon.height))
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

class Window_BattleStatus < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Module Inclusion
	#--------------------------------------------------------------------------
	include GFX_Tools
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize
		super(0, 320, 640, 160)
		@level_flags = [false, false, false, false]
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
		# Add bitmap to contents
		@contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Clickable?
	#--------------------------------------------------------------------------
	def clickable? ; false ; end
	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update(active=false)
		# Reset index if inactive
		unless active
			@highlight.visible = false
			@index = -1
			return
		end
		# Update superclass
		super()
	end
	#--------------------------------------------------------------------------
    # * Item Rect
    #--------------------------------------------------------------------------
    def item_rect(index)
      Rect.new(@x, @y + 8 + 34 * index, @width, 32)
    end
	#--------------------------------------------------------------------------
	# * Draw Actor
	#--------------------------------------------------------------------------
	def draw_actor(index, bitmap)
		# Get actor
		actor = @data[index]
		# Get X
		y = 8 + 34 * index
		# Draw actor name
		bitmap.draw_text(8, y, @width, 32, actor.name)
		# Draw states
		for i in 0...actor.states.size
			state_id = actor.states[i]
			state = $data_states[state_id]
			icon = RPG::Cache.gui("States/#{state.name}")
			bitmap.blt(208 - 26 - (26 * i), y + 12 - icon.height / 2, icon, Rect.new(0, 0, icon.width, icon.height))
		end
		# Draw bars
		width = ((@width - 222) / 3).ceil
		draw_bar(208, y + 8, actor.hp, actor.maxhp, RPG::Cache.gui("Health Bar"), bitmap, width)
		draw_bar(210 + width, y + 8, actor.sp, actor.maxsp, RPG::Cache.gui("Mana Bar"), bitmap, width)
		draw_bar(212 + width * 2, y + 8, actor.clr, actor.clr_max, RPG::Cache.gui("#{actor.class_resource} Bar"), bitmap, width)
		# Draw numbers
		draw_bar_numbers(208, y + 8, "", actor.hp, actor.maxhp, bitmap, width)
		draw_bar_numbers(210 + width, y + 8, "", actor.sp, actor.maxsp, bitmap, width)
		draw_bar_numbers(212 + width * 2, y + 8, "", actor.clr, actor.clr_max, bitmap, width)
	end
	#--------------------------------------------------------------------------
	# * Level up flag
	#--------------------------------------------------------------------------
	def level_up(index)
		@level_flags[index] = true
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

class Window_BattleCommand < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize
		@columns = 1
		super(0, 0, 160, 196)
		@fade_in = false
	end
	#--------------------------------------------------------------------------
	# * Refresh
	#--------------------------------------------------------------------------
	def refresh
		super
		# Create bitmap
		bitmap = Bitmap.new(@width, @height)
		# Set data
		@data = ["Attack", "Skill", "Defend", "Item", "Escape"]
		# Draw all items
		for i in 0...@data.size
			draw_item(i, bitmap)
		end
		# Set bitmap
		self.contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Draw Item
	#--------------------------------------------------------------------------
	def draw_item(index, bitmap)
		# Get rect
		rect = Rect.new(0, 8 + index * 36, @width, 34)
		# Get text
		text = @data[index]
		# Get icon
		icon = RPG::Cache.gui("Battle/#{text}")
		# Draw icon
		bitmap.blt(rect.x + 21 - icon.width / 2, rect.y + 17 - icon.height / 2, 
			icon, Rect.new(0, 0, icon.width, icon.height))
		# Draw text
		if text == "Escape"
			bitmap.font.color = Color.new(160, 160, 160) unless $game_temp.battle_can_escape
		end
		bitmap.draw_text(rect.x + 40, rect.y, rect.width, rect.height, text)
	end
	#--------------------------------------------------------------------------
	# * Item Rect
	#--------------------------------------------------------------------------
	def item_rect(index)
		Rect.new(@x, @y + 8 + index * 36, @width, 34)
	end
	#--------------------------------------------------------------------------
	# * Set Z
	#--------------------------------------------------------------------------
	def z=(value) 
		self.objects.each {|obj| obj.z = value}
		self.contents.z += 500
	end
	#--------------------------------------------------------------------------
	# * Set visible state
	#--------------------------------------------------------------------------
	def visible=(bool)
		self.objects.each {|obj| obj.visible = bool}
		self.contents.visible = bool
		self.objects[1].visible = false
		@visible = bool
	end
end