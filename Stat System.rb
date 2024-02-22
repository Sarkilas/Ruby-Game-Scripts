#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class modification deals with the overhauled stat system for battlers.
#==============================================================================

class Game_Battler
	#--------------------------------------------------------------------------
	# * Aliasing
	#--------------------------------------------------------------------------
	alias_method(:sarkilas_battler_init, :initialize)
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize
		sarkilas_battler_init
		@stats = {}
		@taunts = {}
	end
	#--------------------------------------------------------------------------
	# * Get Attack Power
	#--------------------------------------------------------------------------
	def attack_power
		self.str
	end
	#--------------------------------------------------------------------------
	# * Get Spell Power
	#--------------------------------------------------------------------------
	def spell_power
		self.int
	end
	#--------------------------------------------------------------------------
	# * Mana Regeneration
	#--------------------------------------------------------------------------
	def mana_regen
		2 + (2.0 * (self.int.to_f / 50.0)).to_i
	end
	#--------------------------------------------------------------------------
	# * Critical Hit Chance
	#--------------------------------------------------------------------------
	def crit_chance
		0
	end
	#--------------------------------------------------------------------------
	# * Critical Hit Damage Bonus
	#--------------------------------------------------------------------------
	def crit_damage
		1.25 + (self.str.to_f / 100.0)
	end
	#--------------------------------------------------------------------------
	# * Reset Cooldowns
	#--------------------------------------------------------------------------
	def reset_cooldowns
		@cooldowns = {} unless @cooldowns
		@cooldowns.clear
	end
	#--------------------------------------------------------------------------
	# * Cooldown?
	#--------------------------------------------------------------------------
	def cooldown?(skill_id)
		@cooldowns = {} unless @cooldowns
		@cooldowns.has_key?(skill_id) ? @cooldowns[skill_id] > 0 : false
	end
	#--------------------------------------------------------------------------
	# * Get Cooldown
	#--------------------------------------------------------------------------
	def cooldown(skill_id)
    	@cooldowns = {} unless @cooldowns
		@cooldowns[skill_id]
	end
	#--------------------------------------------------------------------------
	# * Update Cooldowns
	#--------------------------------------------------------------------------
	def update_cooldowns
		@cooldowns = {} unless @cooldowns
		@cooldowns.each_key {|key| @cooldowns[key] -= 1 if @cooldowns[key] > 0}
	end
	#--------------------------------------------------------------------------
	# * Set Cooldown
	#--------------------------------------------------------------------------
	def set_cooldown(skill_id)
		@cooldowns = {} unless @cooldowns
		@cooldowns[skill_id] = Skills::Cooldowns[skill_id]
	end
	#--------------------------------------------------------------------------
	# * Taunt
	#--------------------------------------------------------------------------
	def taunt(user)
		@taunts[user] = 0 unless @taunts[user]
		@taunts[user] += 1
	end
	#--------------------------------------------------------------------------
	# * Taunted?
	#--------------------------------------------------------------------------
	def taunted?
		@taunts.size > 0
	end
	#--------------------------------------------------------------------------
	# * Check Force Target
	#--------------------------------------------------------------------------
	def check_taunt
		@taunts.each do |user, stacks|
			if rand(100) < stacks * 25
				@taunts[user] = 0
				return user
			end 
		end
		return nil
	end
end

class Game_Enemy < Game_Battler
	#--------------------------------------------------------------------------
	# * Aliasing
	#--------------------------------------------------------------------------
	alias_method(:sarkilas_enemy_exp, :exp)
	alias_method(:sarkilas_enemy_base_maxhp, :base_maxhp)
	alias_method(:sarkilas_enemy_atk, :atk)
	#--------------------------------------------------------------------------
	# * Get Attack Damage
	#--------------------------------------------------------------------------
	def atk
		a = super
		a = (Monsters::Damage[$game_party.actors[0].level] * (a.to_f / 100.0)).round
		a
	end
	#--------------------------------------------------------------------------
	# * Get Spell Damage
	#--------------------------------------------------------------------------
	def spell_atk
		s = sarkilas_enemy_atk
		s = (Monsters::Damage[$game_party.actors[0].level] * (s.to_f / 100.0)).round
		s
	end
	#--------------------------------------------------------------------------
	# * Exp
	#--------------------------------------------------------------------------
	def exp
		e = sarkilas_enemy_exp
		e = (Monsters::Exp[$game_party.actors[0].level] * (e.to_f / 100.0)).round
		e
	end
	#--------------------------------------------------------------------------
	# * Base MaxHP
	#--------------------------------------------------------------------------
	def base_maxhp
		maxhp = sarkilas_enemy_base_maxhp
		maxhp = (Monsters::Life[$game_party.actors[0].level] * (maxhp.to_f / 100.0)).round
		maxhp
	end
end

class Game_Actor < Game_Battler
	#--------------------------------------------------------------------------
	# * Data Constants
	#--------------------------------------------------------------------------
	Powers = {
		1 => {:ap => [:str, 2], :sp => [:int, 1]}, # Swordsman
		2 => {:ap => [:str, 1], :sp => [:int, 2]}, # Wind Mage
		3 => {:ap => [:str, 1], :sp => [:int, 2]}, # Ice Mage
		4 => {:ap => [:str, 2], :sp => [:int, 2]}, # Alchemist
		5 => {:ap => [[:str, :cun], 1], :sp => [:int, 1]}, # Guardian
	}
	Resources = {
		1 => {:name => "Energy", :start => 0, :max => 100, :cost => "{x} Energy",
			:label => "Generates {x} Energy per hit", :color => Color.new(255, 155, 66)},
		2 => {:name => "Wind Strength", :start => 0, :max => 10, :cost => "Expels {x} Wind Strength",
			:label => "Increases Wind Strength by {x}", :color => Color.new(66, 255, 161),
			:all => "Expels all Wind Strength"},
		3 => {:name => "Frost Power", :start => 0, :max => 100, :cost => "Consumes {x}% Frost Power",
			:label => "Generates {x}% Frost Power", :color => Color.new(66, 212, 255), :mod => 0.01},
		4 => {:name => "Toxicity", :start => 0, :max => 100, :cost => "Clears {x} Toxicity",
			:label => "Adds {x} Toxicity", :color => Color.new(98, 255, 66)},
		5 => {:name => "Spirit", :start => 0, :max => 20, :cost => "{x} Spirit",
			:label => "Gain {x} Spirit", :color => Color.new(255, 200, 200)}
	}
	#--------------------------------------------------------------------------
	# * Aliasing
	#--------------------------------------------------------------------------
	alias_method(:sarkilas_actor_init, :initialize)
	alias_method(:sarkilas_actor_atk, :atk)
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(actor_id)
		sarkilas_actor_init(actor_id)
		@stats = {:str => 0, :cun => 0, :wis => 0, :speed => 0}
		@talents = {}
	end
	#--------------------------------------------------------------------------
	# * Get Talent Points
	#--------------------------------------------------------------------------
	def talent_points
		# Get base points
		lvls = [5, 15, 25, 40]
		major = 0
		lvls.each {|lvl| major += 1 if @level >= lvl}
		minor = [0, [(@level - 5) / 2, 20].min].max
		# Subtract spent points
		@talents.each_key do |key|
			next if @talents[key].nil? or @talents[key] == 0
			talent = Talents::Data[key]
			if talent[:points] > 1
				minor -= @talents[key]
			else
				major -= 1
			end
		end
		# Return the point array
		[major, minor]
	end
	#--------------------------------------------------------------------------
	# * Reset Talents
	#--------------------------------------------------------------------------
	def reset_talents
		# Iterate all talents
		@talents.each_key {|key| unlearn_talent(key)}
	end
	#--------------------------------------------------------------------------
	# * Unlearn Talent
	#--------------------------------------------------------------------------
	def unlearn_talent(key)
		# For each point spent
		self.talents(key, true).times do
			# Process unlearn effect
			if Talents::Learn[key]
				Talents.process_effect(self, &Talents::Learn[key][:minus])
			end
		end
		# Reset points in talent
		@talents[key] = 0
	end
	#--------------------------------------------------------------------------
	# * Learn Talent
	#--------------------------------------------------------------------------
	def learn_talent(key)
		# Process learn effect
		if Talents::Learn[key]
			Talents.process_effect(self, &Talents::Learn[key][:plus])
		end
		# Learn talent
		@talents[key] = 0 if @talents[key].nil?
		@talents[key] += 1
	end
	#--------------------------------------------------------------------------
	# * Get Talent Points in Specific Talent
	#--------------------------------------------------------------------------
	def talents(key, actual = false)
		@talents[key].nil? ? actual ? 0 : 1 : @talents[key]
	end
	#--------------------------------------------------------------------------
	# * Update Talents
	#--------------------------------------------------------------------------
	def update_talents(vars)
		@talents.keys.each do |key| 
			next unless talents(key, true) > 0
			next unless Talents::Procs.has_key?(key)
			Talents.process_effect(vars, &Talents::Procs[key])
		end
	end
	#--------------------------------------------------------------------------
	# * Get Talent Mods
	#--------------------------------------------------------------------------
	def talent_mods(vars)
		n = 0
		@talents.keys.each do |key| 
			next unless Talents::Mods.has_key?(key)
			n += Talents.process_effect(vars, &Talents::Mods[key])
		end
		if Resources[@class_id][:mod]
			n = n + (n * (clr * Resources[@class_id][:mod])).to_i
		end
		n
	end
	#--------------------------------------------------------------------------
	# * Available Stat Points
	#--------------------------------------------------------------------------
	def stat_points
		total = (@level - 1) * 5
		spent = 0
		base = [:str, :cun, :wis]
		base.each {|key| spent += @stats[key]}
		total - spent
	end
	#--------------------------------------------------------------------------
	# * Current Exp
	#--------------------------------------------------------------------------
	def current_exp
		@exp - @exp_list[@level]
	end
	#--------------------------------------------------------------------------
	# * Reset Temporary Stats (post-battle)
	#--------------------------------------------------------------------------
	def reset_stats
		# Iterate all temporary stats
		Skills::Temp_Stats.each {|key| set_stat(key, 0)}
	end
	#--------------------------------------------------------------------------
	# * Add Stat
	#--------------------------------------------------------------------------
	def add_stat(key, value)
		# Set up stat if non-existent
		@stats[key] = 0 if @stats[key].nil?
		# Add stat
		@stats[key] += value
	end
	#--------------------------------------------------------------------------
	# * Set Stat
	#--------------------------------------------------------------------------
	def set_stat(key, value)
		# Set stat value
		@stats[key] = value
	end
	#--------------------------------------------------------------------------
	# * Get Stat
	#--------------------------------------------------------------------------
	def get_stat(key)
		# Get base stat
		n = @stats.has_key?(key) ? @stats[key] : 0
		# Add equipment
		@weapons.each {|weapon| n += weapon.attr(key) if weapon}
		@equips.each_value {|equip| n += equip.attr(key) if equip}
		# Return the value
		n
	end
	#--------------------------------------------------------------------------
	# * Attack
	#--------------------------------------------------------------------------
	def atk
		atk = super
		(atk.to_f * (1.0 + (attack_power.to_f / 100.0))).round
	end
	#--------------------------------------------------------------------------
	# * Spell Attack
	#--------------------------------------------------------------------------
	def spell_atk
		atk = sarkilas_actor_atk
		(atk.to_f * (1.0 + (spell_power.to_f / 100.0))).round
	end
	#--------------------------------------------------------------------------
	# * Max HP
	#--------------------------------------------------------------------------
	def maxhp
		maxhp = super
		maxhp + get_stat(:maxhp)
	end
	#--------------------------------------------------------------------------
	# * Max SP
	#--------------------------------------------------------------------------
	def maxsp
		maxsp = super
		maxsp + get_stat(:maxsp)
	end
	#--------------------------------------------------------------------------
	# * Strength
	#--------------------------------------------------------------------------
	def str
		str = super
		str + @stats[:str]
	end
	#--------------------------------------------------------------------------
	# * Cunning
	#--------------------------------------------------------------------------
	def dex
		dex = super
		dex + @stats[:cun]
	end
	#--------------------------------------------------------------------------
	# * Wisdom
	#--------------------------------------------------------------------------
	def int
		int = super
		int + @stats[:wis]
	end
	#--------------------------------------------------------------------------
	# * Speed
	#--------------------------------------------------------------------------
	def agi
		agi = super
		agi + @stats[:speed]
	end
	#--------------------------------------------------------------------------
	# * Get Power Value From Symbol
	#--------------------------------------------------------------------------
	def get_power(symbol)
		cls = Powers[@class_id][symbol]
		if cls[0].is_a?(Array)
			n = 0
			cls[0].each do |stat|
				n += send(stat) * cls[1]
			end
			return n
		else
			return send(cls[0]) * cls[1]
		end
	end
	#--------------------------------------------------------------------------
	# * Get Attack Power
	#--------------------------------------------------------------------------
	def attack_power
		get_power(:ap)
	end
	#--------------------------------------------------------------------------
	# * Mana Regeneration
	#--------------------------------------------------------------------------
	def mana_regen
		(2 + get_stat(:mregen)) * (1.0 + (int.to_f / 33.3)).round
	end
	#--------------------------------------------------------------------------
	# * Get Spell Power
	#--------------------------------------------------------------------------
	def spell_power
		get_power(:sp)
	end
	#--------------------------------------------------------------------------
	# * Critical Hit Chance
	#--------------------------------------------------------------------------
	def crit_chance
		5.0 + (self.dex.to_f / 10.0)
	end
	#--------------------------------------------------------------------------
	# * Class Resource Name
	#--------------------------------------------------------------------------
	def class_resource
		Resources[@class_id][:name]
	end
	#--------------------------------------------------------------------------
	# * Class Resource Current
	#--------------------------------------------------------------------------
	def clr
		@clr.nil? ? clr_start : @clr
	end
	#--------------------------------------------------------------------------
	# * Set Class Resource
	#--------------------------------------------------------------------------
	def clr=(value)
		@clr = [0, [value, clr_max].min].max
	end 
	#--------------------------------------------------------------------------
	# * Start Resource
	#--------------------------------------------------------------------------
	def clr_start
		Resources[@class_id][:start]
	end
	#--------------------------------------------------------------------------
	# * Max Resource
	#--------------------------------------------------------------------------
	def clr_max
		Resources[@class_id][:max]
	end
end