#==============================================================================
# ** Skills Data Module
#------------------------------------------------------------------------------
#  This module contains data for skills.
#==============================================================================

module Skills
	#--------------------------------------------------------------------------
	# * Descriptions
	#--------------------------------------------------------------------------
	Descriptions = {
		1 => "Strike with both weapons, dealing 180% of Attack Damage to a single target. " + 
			"Critically hitting with this skill triggers Energize.",
		2 => "Strike all enemies, dealing 300% of Attack Damage.",
		3 => "Performs 10 quick strikes in succession, each strike counting as a Normal Attack.",
		4 => "Deflects attacks for the next 2 turns, blocking damage equal to 20% of your maximum Life. " +
			"If an attack is completely negated, you deal 100% of Attack Damage back to the attacker. " +
			"You cannot perform other actions while Deflect is active.",
		5 => "Impales a target with both weapons, dealing 140% of Attack Damage to a single target " +
			"and stuns them for 2 turns. Deals 35 Defiance Damage.",
		6 => "Increases the damage dealt of all allies by 20% for 3 turns.",
		7 => "Cleaves all enemies for 220% of Attack Damage and causes them to Bleed for 3 turns, " +
			"dealing 70% of Attack Damage per turn to affected targets.",
		8 => "Brutally strike a single enemy for 710% of Attack Damage. Vicious Slash restores 10% of your missing Life.",
		9 => "Deals 140% of Attack Damage to a single enemy and Silences them for 3 turns, making " +
			"them unable to use skills. Deals 35 Defiance Damage.",
		10 => "When you critically hit with Normal Attacks you become Energized, generating 10 Energy per " +
			"turn for 3 turns.",

		12 => "Deals 180% of Spell Damage to a single enemy.",
		13 => "Deals 94% of Spell Damage per Wind Strength expelled to a single enemy.",
		14 => "Deals 60% of Spell Damage per Wind Strength expelled to all enemies.",
		15 => "Heals an ally for 400% of Spell Power.",
		16 => "Heals all allies for 200% of Spell Power.",
		17 => "Cleanses 1 Detrimental effect from an ally.",
		18 => "Causes a storm to stir, automatically dealing 120% of Spell Damage to a random enemy " +
			"after your turn for 6 turns. While the storm stirs, Wind Strength increases by 1 per turn.",
		19 => "Deals 120% of Spell Damage to an enemy and applies Blind, causing their next attack to Miss. Deals 35 Defiance Damage.",
		20 => "Critical hits with Wind spells increases Wind Strength by 1.",

		23 => "Deals 240% of Spell Damage to a single enemy. When used below 50% Frost Power, you gain Frozen Haste until your next " +
			"turn, increasing your Speed by 100% until your next turn.",
		24 => "Deals 300% of Spell Damage to all enemies.",
		25 => "You gain Resistance equal to double your level for 8 turns. While Frozen Shell remains active, " +
			"your Frost Power does not decay when you take damage. Taking damage reduces the duration by 1 turn.",
		26 => "Deals 180% of Spell Damage to a single enemy and Purges 1 Beneficial effect from them. " +
			"In addition, you Cleanse 1 Detrimental effect from yourself.",
		27 => "Deals 280% of Spell Damage to a single enemy. If your Frost Power is above 70%, this spell deals " +
			"double damage and reduces the target's Speed by 15% for 2 turns.",
		28 => "Frost Power increases your Ice damage dealt by an amount equal to your Frost Power.\n" +
			"Your Frost Power decays by 5% per turn, and by 5% whenever you take damage.\n" +
			"All Ice Spells increase Frost Power by 10%.\n" +
			"Critical hits increase Frost Power by an additional 5%.",
		29 => "Deals 440% of Spell Damage to a single enemy. Only usable while Frost Power is 70% or higher. " +
			"Using Ice Blast grants you one additional action during your turn.",
		30 => "Puts a spell ward on an ally, increasing their Resistance by 30% for 4 turns. Whenever a target with " +
			"Spell Ward active takes damage, you gain 5% Frost Power.",
		31 => "Puts a single enemy in an ice block for 3 turns. While in this state, the enemy cannot act, but is immune " +
			"to all incoming damage. Counts as a Beneficial effect. If Frozen Stasis is purged from the enemy, it shatters, " +
			"dealing 360% of Spell Damage to all enemies. Deals 35 Defiance Damage.",

		35 => "Some skills and effects generate Alchemical Energy. You can have up to one charge of Alchemical Energy at a time. " +
			"Alchemical Energy can be consumed by some skills to empower them.",
		36 => "Deals 450% of Attack Damage to a single enemy, Purges 1 Beneficial effect from them and imbues your " +
			"weapon with energy for the next 3 turns, causing your Normal Attacks to deal an additional 100% of Spell Damage.",
		37 => "Deals 260% of Spell Damage to all enemies. If Aden has Alchemical Energy stored, this spell deals 100% more damage.",
		38 => "Drains the alchemical force from a single enemy, dealing 260% of Spell Damage and stores Alchemical Energy.",
		39 => "Increases your Speed by 100% for 4 turns. Toxicity does not decay while this effect is active.",
		40 => "While active, all spells that can consume Alchemical Energy will be used as if you have Alchemical Energy. Lasts 3 turns.",
		41 => "While active, consuming Alchemical Energy heals other allies for an amount equal to 10% of your maximum Life. Lasts 5 turns.",
		42 => "While active, your Normal Attacks deal an additional 100% of Spell Damage and generate Alchemical Energy. Lasts 5 turns.",
		43 => "Deals 380% of Attack Damage to a single enemy. If you have Alchemical Energy stored, this skill deals an additional " +
			"440% of Spell Damage to all enemies.",
		44 => "You deal 100% more damage. Normal Attacks gain triple effectiveness. For each point of Toxicity, this bonus is reduced by 1%.",

		56 => "Edward channels a powerful cyclone around Vincent as he strikes all enemies for 540% of Attack Damage. " +
			"Edward’s Cyclone deals 340% of Spell Damage to all enemies and Purges 1 Beneficial effect from them. "
	}
	#--------------------------------------------------------------------------
	# * Cooldowns (in turns)
	#--------------------------------------------------------------------------
	Cooldowns = {
		2 => 2, 		# Whirlwind Slash
		3 => 20, 		# Flurry
		4 => 5, 		# Deflect
		5 => 3,			# Impale
		6 => 6,			# Battle Cry
		9 => 3,			# Throat Cut
		15 => 2,		# Soothing Mist
		16 => 3,		# Mending Gale
		18 => 20,		# Stir Storm
		19 => 6,		# Dust Devils
		24 => 2, 		# Glacial Spikes
		25 => 10,		# Frozen Shell
		26 => 3,		# Cold Snap
		27 => 3,		# Arctic Breath
		29 => 3,		# Ice Blast
		30 => 4,		# Spell Ward
		31 => 10,		# Frozen Stasis
		36 => 3,		# Alchemical Charge
		37 => 2,		# Expel Alchemy
		38 => 5,		# Alchemical Drain
		39 => 10,		# Haste Decoction
		40 => 8,		# Energy Elixir
		41 => 5,		# Life Force Brew
		42 => 8,		# Virtue Potion
		43 => 3			# Charged Strike		
	}
	#--------------------------------------------------------------------------
	# * Hit Effects
	#--------------------------------------------------------------------------
	Effects = {
		# Skill effects
		8 => Proc.new {|vars| vars[:user].hp += ((vars[:user].maxhp - vars[:user].hp) * 0.1).round},
		17 => Proc.new {|vars| Skills.state_removal(vars, Detrimental)},
		23 => Proc.new {|vars| 
				next unless vars[:user].actor?
				if vars[:user].clr < 50
					vars[:user].add_state(50)
				end
		},
		26 => Proc.new {|vars|
			next unless vars[:user].actor?
			Skills.state_removal(vars, Beneficial)
			Skills.state_removal(vars, Detrimental, true)
		},
		36 => Proc.new {|vars| 
				Skills.state_removal(vars, Beneficial)
				vars[:user].add_state(31)
			},
		37 => Proc.new {|vars|
				next unless (vars[:user].states.include?(38) || 
					vars[:user].states.include?(40) || vars[:user].states.include?(42))
				vars[:target].damage *= 2
				Scripts[:alchemical_energy_remove].call(vars[:user])
			},
		53 => Proc.new {|vars| $game_switches[10] = false},
		79 => Proc.new {|vars|
				d = (vars[:target].hp * 0.25).round
				min = (vars[:target].maxhp * 0.02).round 
				d = [d, min].max
				vars[:target].damage = d
				vars[:target].damage_pop = true
				vars[:target].hp -= d
			},

		# Affix effects
		:energy => Proc.new {|vars|
				if vars[:type] == :attack && vars[:skill] == 0
					next unless vars[:user].actor? && vars[:user].class_id == 1
					vars[:user].clr = vars[:user].clr + vars[:user].get_stat(:energy)
				end
			},
		:squall => Proc.new {|vars| 
				if vars[:type] == :attack && vars[:skill] == 12
					vars[:user].clr = vars[:user].clr + 1
				end
			},
	}
	#--------------------------------------------------------------------------
	# * Detrimental and Beneficial States Array
	#--------------------------------------------------------------------------
	Detrimental = [3,8,11,30,33,45,46,48]
	Beneficial 	= [39,49]
	#--------------------------------------------------------------------------
	# * Temporary Stats (reset after battle)
	#--------------------------------------------------------------------------
	Temp_Stats = [:alchemical_energy_exhaustion, :frostbite, :healwinds]
	#--------------------------------------------------------------------------
	# * Secondary Resource Gains
	#--------------------------------------------------------------------------
	Secondary = {
		1 => 9,			# Mighty Strike
		2 => 5,			# Whirlwind Slash
		6 => 50,		# Battle Cry
		12 => 1,		# Squall
		17 => 1,		# Zephyr
		18 => 5,		# Stir Storm
		19 => 1,		# Dust Devils
		39 => 40,		# Haste Decoction
		40 => 50,		# Energy Elixir
		41 => 40,		# Life Force Brew
		42 => 40,		# Virtue Potion
	}
	#--------------------------------------------------------------------------
	# * Script Calls
	#--------------------------------------------------------------------------
	Scripts = {
		:alchemical_energy => ->(actor) { 
				if actor.get_stat(:alchemical_energy_exhaustion) == 1
					actor.set_stat(:alchemical_energy_exhaustion, 0)
					next
				end
				if actor.states.include?(38) && actor.talents(:capacity, true) > 0
					actor.add_state(40)
				else
					actor.add_state(38)
					actor.set_stat(:alchemical_energy_exhaustion, 1)
				end
			},
		:alchemical_energy_remove => ->(actor) { 
				if actor.states.include?(42)
					Scripts[:life_force_brew].call(actor)
					next
				elsif actor.states.include?(40)
					actor.remove_state(40)
				else
					actor.remove_state(38)
				end
				Scripts[:life_force_brew].call(actor)
			},
		:life_force_brew => ->(actor) {
				next unless actor.states.include?(43)
				healing = (actor.maxhp * 0.1).to_i
				for a in $game_party.actors
					next unless a || a == actor
					a.damage = -healing
					a.damage_pop = true
					a.hp += healing
				end
			},
	}
	#--------------------------------------------------------------------------
	# * Passive Effects
	# 		if skill is learned, execute on attack
	#--------------------------------------------------------------------------
	Passives = {
		10 => Proc.new {|vars| vars[:user].add_state(32) if vars[:critical]},
		20 => Proc.new {|vars| 
				next unless vars[:skill]
				if Array(12..19).include?(vars[:skill].id) && vars[:critical]
					vars[:user].clr = vars[:user].clr + 1
				end
			},
		28 => Proc.new {|vars|
				next unless vars[:skill] || vars[:phase] == :turn_end
				if vars[:skill]
					vars[:user].clr = vars[:user].clr + 
						(vars[:critical] ? 15 : 10) unless vars[:skill].id == 33
				elsif vars[:phase] == :turn_end
					vars[:user].clr = vars[:user].clr - 5 unless vars[:user].states.include?(34)
				end
			},
		35 => Proc.new {|vars|
				next unless vars[:phase] == :turn_end
				next if vars[:user].states.include?(39)
				vars[:user].clr = vars[:user].clr - 10
			},
		44 => Proc.new {|vars|
				next unless vars[:target] 
				next if vars[:target] == vars[:user]
				multiplier = 1.0 + (100.0 - vars[:user].clr) / 100.0
				multiplier *= 3 unless vars[:skill]
				vars[:target].damage = (vars[:target].damage * multiplier).round
			}
	}
	#--------------------------------------------------------------------------
	# * State Attributes
	#--------------------------------------------------------------------------
	State_Attributes = {
		34 => {:mdef => Proc.new {|battler| next battler.actor? ? battler.level * 2 : 0}}
	}
	#--------------------------------------------------------------------------
	# * State Effects (per turn)
	#--------------------------------------------------------------------------
	State_FX = {
		32 => Proc.new {|vars| 
				next unless vars[:battler].actor?
				vars[:battler].clr = vars[:battler].clr + 10
			},
		35 => Proc.new {|vars|
				next unless vars[:battler].actor?
				vars[:battler].clr = vars[:battler].clr + 1
				if $game_troop.enemies.size > 0
					enemy = $game_troop.enemies[rand($game_troop.enemies.size)]
					enemy.damage = (vars[:battler].spell_atk * 1.2).to_i
					enemy.hp -= enemy.damage
					enemy.damage_pop = true
					enemy.animation_id = 44
				end
		},
	}
	#--------------------------------------------------------------------------
	# * State Effects (on hit)
	#--------------------------------------------------------------------------
	State_FX_Hit = {
		31 => Proc.new {|vars|
				next 0 if vars[:owner] == :target || !vars[:basic]
				damage = [vars[:user].spell_atk - vars[:target].mdef, 1].max
				next damage
			},
		34 => Proc.new {|vars|
				next 0 if vars[:owner] == :user
				next 0 if vars[:target].talents(:icebarrier, true) == 0
				damage = -(vars[:target].damage * 0.25).round
				next damage
			},
		41 => Proc.new {|vars|
				next 0 if vars[:owner] == :target || !vars[:basic]
				damage = [vars[:user].spell_atk - vars[:target].mdef, 1].max
				Scripts[:alchemical_energy].call(vars[:user])
				next damage
			},
		44 => Proc.new {|vars|
				next 0 if vars[:owner] == :user
				next 0 unless vars[:target].damage.is_a?(Numeric)
				damage = (vars[:target].damage * 0.3).round
				next damage
			},

		# Rising Horror
		47 => Proc.new {|vars|
			next 0 if vars[:owner] == :target
			damage = (vars[:target].damage * 0.5).round
			next damage
		},
	}
	#--------------------------------------------------------------------------
	# * State Removal Method (for Purge and Cleanse)
	#--------------------------------------------------------------------------
	def self.state_removal(vars, data, user=false)
		sym = user ? :user : :target
		for i in 0...vars[sym].states.size
			if data.include?(vars[sym].states[i])
				vars[sym].states.delete_at(i)
				break
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Process Effect
	#--------------------------------------------------------------------------
	def self.process_effect(var, &block)
		yield var
	end
end