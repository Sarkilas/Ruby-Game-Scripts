#==============================================================================
# ** Talents Data Module
#------------------------------------------------------------------------------
#  This module contains data for talents.
#==============================================================================

module Talents
	#--------------------------------------------------------------------------
	# * Talent Base Data
	#--------------------------------------------------------------------------
	Data = {
		# Swordfighter Talents
		# Row 1
		:ambidex => {
			:class => 1, :name => "Ambidexterity", :row => 1, 
			:description => "Normal attacks hit an additional time.",
			:points => 1
		},
		:taunt => {
			:class => 1, :name => "Taunt", :row => 1,
			:description => "When you hit an enemy, they are 25% more likely to attack you on their next turn. " +
			"This effect stacks and is removed when you take damage from this enemy.", 
			:points => 1
		},
		:haste => {
			:class => 1, :name => "Haste", :row => 1,
			:description => "Your Speed is increased by 10.",
			:points => 1
		},
		:leech => {
			:class => 1, :name => "Leeching Dynamo", :row => 1,
			:description => "Your critical strikes leech 10% of the damage dealt back to you as Life.",
			:points => 1
		},
		# Row 2
		:dualstrikes => {
			:class => 1, :name => "Dual Strikes", :row => 2,
			:description => "Normal attacks deal {value}% more damage and restores {mana_val} Mana.",
			:points => 10, :require => :ambidex, :vars => :dualstrikes
		},
		:forcefield => {
			:class => 1, :name => "Force Field", :row => 2,
			:description => "You take {value}% reduced damage from all sources. This effect is doubled for taunted enemies.",
			:points => 10, :require => :taunt, :vars => :forcefield
		},
		:flurry => {
			:class => 1, :name => "Improved Flurry", :row => 2,
			:description => "The cooldown on Flurry is reduced by {value} turns.",
			:points => 10, :require => :haste, :vars => :flurry
		},
		:lifeforce => {
			:class => 1, :name => "Life Force", :row => 2,
			:description => "Normal attacks restore {value}% of your maximum Life on Hit.",
			:points => 10, :require => :leech, :vars => :lifeforce
		},
		# Row 3
		:duality => {
			:class => 1, :name => "Forceful Duality", :row => 3,
			:description => "All attacks perform an additional attack with your off-hand weapon, " +
			"dealing 100% of Attack Damage to the target, and has a 30% chance to instead hit with " +
			"both weapons for 250% of Attack Damage.",
			:points => 1, :require => :dualstrikes
		},
		:defender => {
			:class => 1, :name => "Relentless Defender", :row => 3,
			:description => "Defend now also restores 4% of your Life and applies one stack of Taunt to all enemies. " + 
			"In addition, you counter attack taunted enemies, dealing 100% of Attack Damage.",
			:points => 1, :require => :forcefield
		},
		:drifting => {
			:class => 1, :name => "Drifting Swordsman", :row => 3,
			:description => "Your normal attacks has a 20% chance to reduce the cooldown of Flurry by 1 turn.",
			:points => 1, :require => :flurry
		},
		:resort => {
			:class => 1, :name => "Last Resort", :row => 3,
			:description => "When you take fatal damage, you instead gain a beneficial effect for the next 2 turns " +
			"that absorbs up to 100% of your maximum Life. This effect has a 10 turn cooldown.",
			:points => 1, :require => :lifeforce
		},

		# Wind Mage Talents
		# Row 1
		:healwinds => {
			:class => 2, :name => "Healing Winds", :row => 1, 
			:description => "Every third Wind spell cast generates Healing Winds around allies, healing them " +
			"for 6% of their maximum Life per turn for 2 turns.",
			:points => 1
		},
		:gusts => {
			:class => 2, :name => "Violent Gusts", :row => 1,
			:description => "Your damaging single target Wind spells engulfs the target in Violent Gusts for 2 turns, " +
			"reducing their Speed by 15% and inflicts 30% of Spell Damage per turn while active.", 
			:points => 1
		},
		:manaair => {
			:class => 2, :name => "Air of Mana", :row => 1,
			:description => "Targets healed by Soothing Mist or Mending Gale recover 10 Mana.",
			:points => 1
		},
		:knowledge => {
			:class => 2, :name => "Knowledge", :row => 1,
			:description => "Base Mana regeneration increased by 2.",
			:points => 1
		},
		# Row 2
		:empwinds => {
			:class => 2, :name => "Empowered Winds", :row => 2,
			:description => "You deal {value}% more Spell Damage while under the effects of Healing Winds.",
			:points => 10, :require => :healwinds, :vars => :empwinds
		},
		:strgusts => {
			:class => 2, :name => "Strengthened Gusts", :row => 2,
			:description => "Violent Gusts deal {value}% increased damage. Successfully applying Violent Gusts to " +
			"a target not already affected by Violent Gusts restores {mana} Mana.",
			:points => 10, :require => :gusts, :vars => :strgusts
		},
		:convalescence => {
			:class => 2, :name => "Convalescence", :row => 2,
			:description => "Whenever you expel Wind Strength, you recover {mana}% of your maximum Mana per " +
			"Wind Strength expelled.",
			:points => 10, :require => :manaair, :vars => :convalescence
		},
		:scholar => {
			:class => 2, :name => "Wise Scholar", :row => 2,
			:description => "Whenever you generate Wind Strength, you have a {value}% chance to generate one additional Wind Strength.",
			:points => 10, :require => :knowledge, :vars => :scholar
		},
		# Row 3
		:envelop => {
			:class => 2, :name => "Enveloping Mists", :row => 3,
			:description => "Soothing Mists restores 100% more Life on targets affected by Healing Winds, but " +
			"consumes Healing Winds in the process. Reduces the cooldown of Soothing Mist by 1 turn.",
			:points => 1, :require => :empwinds
		},
		:hungerstorm => {
			:class => 2, :name => "Hungering Storm", :row => 3,
			:description => "Your damaging spells deal increased damage based on your current Mana, up to " +
			"100% more damage at full Mana, but your spells cost 75% more Mana.",
			:points => 1, :require => :strgusts
		},
		:mistral => {
			:class => 2, :name => "Renewing Mistral", :row => 3,
			:description => "Expelling Wind Strength increases the effect of your next Wind spell that consumes Mana " +
			"by 25% per Wind Strength expelled.",
			:points => 1, :require => :convalescence
		},
		:mindfulness => {
			:class => 2, :name => "Mindfulness", :row => 3,
			:description => "While at full Mana your Normal Attacks deal 100% more damage and reduce active cooldowns by 1 turn.",
			:points => 1, :require => :scholar
		},

		# Ice Mage Talents
		# Row 1
		:frostbite => {
			:class => 3, :name => "Frostbite", :row => 1, 
			:description => "Every third Ice spell cast on enemies will Freeze that enemy, making it unable to act " +
				"for 1 turn. If an enemy is immune to Freeze, you instead deal an additional 100% of Spell Damage as Ice.",
			:points => 1
		},
		:icebarrier => {
			:class => 3, :name => "Ice Barrier", :row => 1,
			:description => "Frozen Shell reduces damage taken by 25% while active.", 
			:points => 1
		},
		:permafrost => {
			:class => 3, :name => "Permafrost", :row => 1,
			:description => "Icicle and Glacial Spikes make affected targets vulnerable, increasing their damage taken by 30% for 2 turns.",
			:points => 1
		},
		:arcticfrenzy => {
			:class => 3, :name => "Arctic Frenzy", :row => 1,
			:description => "When you reach 100% Frost Power, your next Ice spell also unleashes an Arctic Frenzy, dealing " +
				"160% of Spell Damage as Ice 8 times to random enemies, but resets your Frost Power back to 0%.",
			:points => 1
		},
		# Row 2
		:iceborn => {
			:class => 3, :name => "Iceborn", :row => 2,
			:description => "Triggering Frostbite restores {mana} Mana.",
			:points => 10, :require => :frostbite, :vars => :iceborn
		},
		:bitingcold => {
			:class => 3, :name => "Biting Cold", :row => 2,
			:description => "Frozen Shell causes normal attacks to deal {value}% of Spell Damage as Ice as additional damage while active.",
			:points => 10, :require => :icebarrier, :vars => :bitingcold
		},
		:penetratingice => {
			:class => 3, :name => "Penetrating Ice", :row => 2,
			:description => "The vulnerability applied by Permafrost increases damage taken by an additional {value}%.",
			:points => 10, :require => :permafrost, :vars => :penetratingice
		},
		:frozenheart => {
			:class => 3, :name => "Frozen Heart", :row => 2,
			:description => "When you trigger Arctic Frenzy, you recover {mana} Mana and recover {life}% of your maximum Life.",
			:points => 10, :require => :arcticfrenzy, :vars => :frozenheart
		},
		# Row 3
		:shatter => {
			:class => 3, :name => "Shatter", :row => 3,
			:description => "When Frostbite triggers, you have a 25% chance to immediately shatter the Freeze, " +
				"dealing 350% of Spell Damage as Ice, but removing Freeze from the target. If Shatter kills an enemy, " +
				"you heal for 15% of your maximum Life.",
			:points => 1, :require => :iceborn
		},
		:everlastingwinter => {
			:class => 3, :name => "Everlasting Winter", :row => 3,
			:description => "Frozen Shell lasts forever, but drains 25 Mana per turn while active. In addition, " +
				"Biting Cold now also applies to spells. If your Mana reaches 0, Frozen Shell is deactivated.",
			:points => 1, :require => :bitingcold
		},
		:exposeweakness => {
			:class => 3, :name => "Expose Weakness", :row => 3,
			:description => "Targets made vulnerable by Permafrost has a 20% increased chance to be critically hit by you. " +
			"Your critical hits increase Frost Power by an additional 5%.",
			:points => 1, :require => :penetratingice
		},
		:stablecold => {
			:class => 3, :name => "Stable Cold", :row => 3,
			:description => "You generate 100% more Frost Power. Triggering Arctic Frenzy reduces all active cooldowns by 1 turn.",
			:points => 1, :require => :frozenheart
		},

		# Alchemist Talents
		# Row 1
		:tolerance => {
			:class => 4, :name => "High Tolerance", :row => 1,
			:description => "Toxicity decays 50% faster.", 
			:points => 1
		},
		:capacity => {
			:class => 4, :name => "Energy Capacity", :row => 1,
			:description => "You can now store up to two charges of Alchemical Energy.",
			:points => 1
		},
		:alchemy => {
			:class => 4, :name => "Pure Alchemy", :row => 1,
			:description => "Your offensive spells deal 30% more damage while below 50 Toxicity.",
			:points => 1
		},
		:strongmind => {
			:class => 4, :name => "Strong Mind", :row => 1,
			:description => "While below 50 Toxicity, your base Mana regeneration is increased by 2.\n" +
				"While above 50 Toxicity, you recover 2% Life per turn.",
			:points => 1
		},

		# Row 2
		:resilience => {
			:class => 4, :name => "Toxic Resilience", :row => 2,
			:description => "Toxicity gains reduced by {value}%.",
			:points => 10, :require => :tolerance, :vars => :resilience
		},
		:brawling => {
			:class => 4, :name => "Toxic Brawling", :row => 2,
			:description => "Your Normal Attacks deal {value}% more damage per current Toxicity.",
			:points => 10, :require => :capacity, :vars => :brawling
		},
		:cleanmind => {
			:class => 4, :name => "Clean Mind", :row => 2,
			:description => "Your offensive spells deal {value}% more damage for each Toxicity below 100.",
			:points => 10, :require => :alchemy, :vars => :cleanmind
		},
		:bodysoul => {
			:class => 4, :name => "Body and Soul", :row => 2,
			:description => "Every time your Toxicity drops below 50, you recover {mana}% of your maximum Mana.\n" +
				"Every time your Toxicity rises above 50, you recover {life}% of your maximum Life.",
			:points => 10, :require => :strongmind, :vars => :bodysoul
		},

		# Row 3
		:vigor => {
			:class => 4, :name => "Evolved Vigor", :row => 3,
			:description => "Elixirs last 50% longer, rounded up.",
			:points => 1, :require => :resilience
		},
		:infusion => {
			:class => 4, :name => "Alchemy Infusion", :row => 3,
			:description => "Your Normal Attacks deal an additional 2% of Spell Damage per current Toxicity.",
			:points => 1, :require => :brawling
		},
		:rawpower => {
			:class => 4, :name => "Raw Power", :row => 3,
			:description => "While you have no Toxicity, Mana costs and Spell Damage is increased by 100%.",
			:points => 1, :require => :cleanmind
		},
		:truespirit => {
			:class => 4, :name => "True Spirit", :row => 3,
			:description => "You gain Defense and Resistance equal to your current Toxicity. " +
				"If you take more than 10% of your maximum Life in one hit, you reduce your Toxicity by 5.",
			:points => 1, :require => :bodysoul
		},
	}
	#--------------------------------------------------------------------------
	# * Dynamic Variables
	#--------------------------------------------------------------------------
	Variables = {
		:dualstrikes => {:value => Proc.new {|actor| next 10 * actor.talents(:dualstrikes)},
			:mana_val => Proc.new {|actor| next (1 + (0.5 * actor.talents(:dualstrikes))).floor}
		},
		:forcefield => {:value => Proc.new {|actor| next 2 * actor.talents(:forcefield)}},
		:flurry => {:value => Proc.new {|actor| next 1 + (0.5 * actor.talents(:flurry).to_f).floor}},
		:lifeforce => {:value => Proc.new {|actor| next 0.2 * actor.talents(:lifeforce).to_f}},

		:empwinds => {:value => Proc.new {|actor| next 2 * actor.talents(:empwinds)}},
		:strgusts => {:value => Proc.new {|actor| next 10 * actor.talents(:strgusts)},
			:mana => Proc.new {|actor| next (1 * actor.talents(:strgusts)).floor}
		},
		:convalescence => {:mana => Proc.new {|actor| next 0.5 * actor.talents(:convalescence)}},
		:scholar => {:value => Proc.new {|actor| next 3 * actor.talents(:scholar)}},

		:iceborn => {:mana => Proc.new {|actor| next 2 * actor.talents(:iceborn)}},
		:bitingcold => {:value => Proc.new {|actor| next 10 * actor.talents(:bitingcold)}},
		:penetratingice => {:value => Proc.new {|actor| next actor.talents(:penetratingice)}},
		:frozenheart => {:mana => Proc.new {|actor| next 5 * actor.talents(:frozenheart)},
			:life => Proc.new {|actor| next actor.talents(:frozenheart)}
		},

		:resilience => {:value => Proc.new {|actor| next 2 * actor.talents(:resilience)}},
		:brawling => {:value => Proc.new {|actor| next 0.3 * actor.talents(:brawling)}},
		:cleanmind => {:value => Proc.new {|actor| next 0.2 * actor.talents(:cleanmind)}},
		:bodysoul => {:mana => Proc.new {|actor| next 1 * actor.talents(:bodysoul)},
			:life => Proc.new {|actor| next 0.6 * actor.talents(:bodysoul)}}
	}
	#--------------------------------------------------------------------------
	# * Talent Processes
	#--------------------------------------------------------------------------
	Procs = {
		:leech => Proc.new {|vars|
			next if vars[:phase] != :attack || !vars[:user].actor?
			if vars[:critical]
				vars[:user].hp += (vars[:damage] * 0.1).round
			end
		},
		:taunt => Proc.new {|vars|
			next if vars[:phase] != :attack && vars[:phase] != :skill
			vars[:target].taunt(vars[:user]) unless vars[:target].actor?
		},
		:defender => Proc.new {|vars|
			if vars[:phase] == :guard
				vars[:user].hp += (vars[:user].maxhp * 0.04).round
				$game_troop.enemies.each {|enemy| enemy.taunt(vars[:user])}
			elsif vars[:phase] == :defend
				
			end
		},

		:healwinds => Proc.new {|vars|
			next if vars[:phase] != :skill || !vars[:user].actor?
			if vars[:user].get_stat(:healwinds) == 3
				$game_party.actors.each {|actor| actor.add_state(36)}
				vars[:user].add_stat(:healwinds, -vars[:user].get_stat(:healwinds))
			else
				vars[:user].add_stat(:healwinds, 1)
			end
		},

		:arcticfrenzy => Proc.new {|vars|
			next unless vars[:user].actor?
			next unless vars[:user].clr >= 100
			battler = vars[:user]
			battler.current_action.kind = 1
			battler.current_action.skill_id = 33
			battler.current_action.decide_random_target_for_actor
			battler.current_action.forcing = true
			$game_temp.forcing_battler = battler
			battler.clr = 0
		},
		:frostbite => Proc.new {|vars|
			next if vars[:phase] != :skill || !vars[:user].actor? || vars[:target].actor?
			if vars[:user].get_stat(:frostbite) == 3
				vars[:target].add_state(37)
				unless vars[:target].states.include?(37)
					vars[:target].damage += vars[:user].spell_attack
				end
				vars[:user].add_stat(:frostbite, -vars[:user].get_stat(:frostbite))
			else
				vars[:user].add_stat(:frostbite, 1)
			end
		},
		:permafrost => Proc.new {|vars|
			next unless vars[:user].actor?
			next unless vars[:phase] == :skill
			next unless [23,24].include?(vars[:id])
			vars[:target].add_state(44)
		}
	}
	#--------------------------------------------------------------------------
	# * Value Modifier Talents
	#--------------------------------------------------------------------------
	Mods = {
		:dualstrikes => Proc.new {|vars|
				next 0 if vars[:user].is_a?(Game_Enemy)
				next 0 if vars[:phase] != :attack && vars[:user].talents(:dualstrikes, true) > 0
				next (vars[:damage] * (vars[:user].talents(:dualstrikes) * 0.1)).round
			},
	}
	#--------------------------------------------------------------------------
	# * Learn Effects
	#--------------------------------------------------------------------------
	Learn = {
		:haste => {:plus => Proc.new {|actor| actor.add_stat(:speed, 10)}, 
			:minus => Proc.new {|actor| actor.add_stat(:speed, -10)}},
		:knowledge => {:plus => Proc.new {|actor| actor.add_stat(:mregen, 2)},
			:minus => Proc.new {|actor| actor.add_stat(:mregen, -2)}},
	}
	#--------------------------------------------------------------------------
	# * Get Talents Map
	#--------------------------------------------------------------------------
	def self.get(class_id, row=0)
		map = {}
		Data.each_key {|key| 
			if Data[key][:class] == class_id
				if row > 0
					if Data[key][:row] == row
						map[key] = Data[key]
					end
				else
					map[key] = Data[key]
				end
			end
		}
		map
	end
	#--------------------------------------------------------------------------
	# * Parse Description
	#--------------------------------------------------------------------------
	def self.parse(talent, actor)
		# Get the description
		d = talent[:description].clone
		# Return if no variables
		return d unless talent[:vars]
		# Get variables
		vars = Variables[talent[:vars]]
		# Iterate all variables
		vars.each_key do |var|
			value = self.process_effect(actor, &vars[var])
			d.gsub!("{#{var.to_s}}", value.to_s)
		end
		# Return the final description
		d
	end
	#--------------------------------------------------------------------------
	# * Process Effect
	#--------------------------------------------------------------------------
	def self.process_effect(var, &block)
		yield var
	end
end