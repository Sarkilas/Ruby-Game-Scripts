#==============================================================================
# ** Random Equipment
#------------------------------------------------------------------------------
#  This contains classes for randomized equipment.
#==============================================================================

module Equipment
	#--------------------------------------------------------------------------
	# * Affix Data
	#--------------------------------------------------------------------------
	Prefixes = {
		# Weapon power bonus affixes (weapon and hands only)
		:atk => [
			{:name => "Heavy", :level => 1, :range => [2,4], :require => :weapon},
			{:name => "Powerful", :level => 5, :range => [5,7], :require => :weapon},
			{:name => "Potent", :level => 9, :range => [8,10], :require => :weapon},
			{:name => "Forceful", :level => 15, :range => [11,13], :require => :weapon},
			{:name => "Brutal", :level => 24, :range => [14,17], :require => :weapon},
			{:name => "Ferocious", :level => 32, :range => [18,20], :require => :weapon},
			{:name => "Vicious", :level => 40, :range => [21,25], :require => :weapon},
			{:name => "Savage", :level => 50, :range => [26,30], :require => :weapon},

			{:name => "Heavy", :level => 1, :range => [2,4], :require => :hands},
			{:name => "Powerful", :level => 5, :range => [5,7], :require => :hands},
			{:name => "Potent", :level => 9, :range => [8,10], :require => :hands},
			{:name => "Forceful", :level => 15, :range => [11,13], :require => :hands},
			{:name => "Brutal", :level => 24, :range => [14,17], :require => :hands},
			{:name => "Ferocious", :level => 32, :range => [18,20], :require => :hands},
			{:name => "Vicious", :level => 40, :range => [21,25], :require => :hands},
			{:name => "Savage", :level => 50, :range => [26,30], :require => :hands}
		],

		# Life per turn
		:regen => [
			{:name => "Regenerating", :level => 1, :range => [0.1,0.2]},
			{:name => "Invigorating", :level => 15, :range => [0.3,0.4]},
			{:name => "Refreshing", :level => 35, :range => [0.5,0.8]},
		],

		# Mana per turn (accessories only)
		:mregen => [
			{:name => "Mindful", :level => 1, :range => [1,2], :require => :acc1},
			{:name => "Overflowing", :level => 15, :range => [2,3], :require => :acc1},
		],

		# Defense bonus affixes
		:pdef => [
			{:name => "Sturdy", :level => 1, :range => [2,4], :require => :armor},
			{:name => "Tough", :level => 5, :range => [5,7], :require => :armor},
			{:name => "Hard", :level => 9, :range => [8,10], :require => :armor},
			{:name => "Robust", :level => 15, :range => [11,13], :require => :armor},
			{:name => "Hearty", :level => 24, :range => [14,17], :require => :armor},
			{:name => "Stalwart", :level => 32, :range => [18,20], :require => :armor},
			{:name => "Unyielding", :level => 40, :range => [21,25], :require => :armor},
			{:name => "Resolute", :level => 50, :range => [26,30], :require => :armor}
		],

		# Resistance bonus affixes
		:mdef => [
			{:name => "Arcane", :level => 1, :range => [2,4], :require => :armor},
			{:name => "Esoteric", :level => 5, :range => [5,7], :require => :armor},
			{:name => "Mysterious", :level => 9, :range => [8,10], :require => :armor},
			{:name => "Occult", :level => 15, :range => [11,13], :require => :armor},
			{:name => "Impenetrable", :level => 24, :range => [14,17], :require => :armor},
			{:name => "Mystic", :level => 32, :range => [18,20], :require => :armor},
			{:name => "Cabalistic", :level => 40, :range => [21,25], :require => :armor},
			{:name => "Recondite", :level => 50, :range => [26,30], :require => :armor}
		],

		# Maximum Life bonus affixes
		:maxhp => [
			{:name => "Tenacious", :level => 1, :range => [20,40]},
			{:name => "Healthy", :level => 5, :range => [40,70]},
			{:name => "Vigorous", :level => 9, :range => [70,90]},
			{:name => "Athletic", :level => 15, :range => [90,110]},
			{:name => "Vital", :level => 24, :range => [110,120]},
			{:name => "Zealous", :level => 32, :range => [120,130]},
			{:name => "Hale", :level => 40, :range => [130,150]},
			{:name => "Brisk", :level => 50, :range => [150,180]}
		],

		# Spell damage proc if Attacked recently
		:spell_attack => [
			{:name => "Enhanced", :level => 5, :range => [5,10], :require => :weapon},
			{:name => "Intensified", :level => 12, :range => [10,20], :require => :weapon},
			{:name => "Empowered", :level => 25, :range => [20,35], :require => :weapon},
			{:name => "Tempered", :level => 40, :range => [35,50], :require => :weapon},
		],

		# Attack damage proc if used Spell recently
		:attack_proc => [
			{:name => "Exalted", :level => 5, :range => [5,10], :require => :weapon},
			{:name => "Magnified", :level => 12, :range => [10,20], :require => :weapon},
			{:name => "Aggravated", :level => 25, :range => [20,35], :require => :weapon},
			{:name => "Sharpened", :level => 40, :range => [35,50], :require => :weapon},
		],

		# Maximum mana (accessories only)
		:maxsp => [
			{:name => "Wise", :level => 1, :range => [5,10], :require => :acc1},
			{:name => "Perceptive", :level => 12, :range => [10,20], :require => :acc1},
			{:name => "Lucid", :level => 30, :range => [20,35], :require => :acc1}
		],

		# Thorns (chest armor only)
		:thorns => [
			{:name => "Spiky", :level => 1, :range => [30,40], :require => :chest},
			{:name => "Barbed", :level => 9, :range => [50,60], :require => :chest},
			{:name => "Spiny", :level => 35, :range => [70,90], :require => :chest},
			{:name => "Biting", :level => 35, :range => [100,130], :require => :chest}
		]
	}
	Suffixes = {
		# Strength bonus affixes
		:str => [
			{:name => "of the Strong", :level => 1, :range => [3,5]},
			{:name => "of Power", :level => 5, :range => [6,8]},
			{:name => "of Potency", :level => 9, :range => [9,12]},
			{:name => "of the Brute", :level => 15, :range => [13,16]},
			{:name => "of Brutality", :level => 24, :range => [17,22]},
			{:name => "of the Ogre", :level => 32, :range => [23,30]},
			{:name => "of Giants", :level => 40, :range => [31,40]},
			{:name => "of Striking", :level => 50, :range => [41,55]}
		],

		# Cunning bonus affixes
		:dex => [
			{:name => "of the Clever", :level => 1, :range => [3,5]},
			{:name => "of Acuteness", :level => 5, :range => [6,8]},
			{:name => "of Keenness", :level => 9, :range => [9,12]},
			{:name => "of the Knowing", :level => 15, :range => [13,16]},
			{:name => "of the Sharp", :level => 24, :range => [17,22]},
			{:name => "of the Slick", :level => 32, :range => [23,30]},
			{:name => "of the Crafty", :level => 40, :range => [31,40]},
			{:name => "of the Sly", :level => 50, :range => [41,55]}
		],

		# Wisdom bonus affixes
		:int => [
			{:name => "of the Azure", :level => 1, :range => [3,5]},
			{:name => "of Astuteness", :level => 5, :range => [6,8]},
			{:name => "of Awareness", :level => 9, :range => [9,12]},
			{:name => "of the Sensible", :level => 15, :range => [13,16]},
			{:name => "of the Sophic", :level => 24, :range => [17,22]},
			{:name => "of Reflection", :level => 32, :range => [23,30]},
			{:name => "of Brightness", :level => 40, :range => [31,40]},
			{:name => "of the Insightful", :level => 50, :range => [41,55]}
		],

		# Speed bonus affixes (boots only)
		:agi => [
			{:name => "of Speed", :level => 1, :range => [2,3], :require => :feet},
			{:name => "of Quickness", :level => 5, :range => [4,5], :require => :feet},
			{:name => "of Agility", :level => 9, :range => [6,7], :require => :feet},
		],

		# Proc affixes
		:bleed => [
			{:name => "of Blood", :level => 1, :range => [10,20], :require => :weapon},
			{:name => "of Impaling", :level => 9, :range => [20,30], :require => :weapon},
			{:name => "of Hemoglobin", :level => 20, :range => [30,40], :require => :weapon},
			{:name => "of Gore", :level => 40, :range => [40,50], :require => :weapon}
		],

		:lightning => [
			{:name => "of Shocking", :level => 1, :range => [10,20], :require => :weapon},
			{:name => "of Fulmination", :level => 9, :range => [20,30], :require => :weapon},
			{:name => "of Storms", :level => 20, :range => [30,40], :require => :weapon},
			{:name => "of the Charged", :level => 40, :range => [40,50], :require => :weapon}
		],

		:surge => [
			{:name => "of Growth", :level => 1, :range => [10,20], :require => :weapon},
			{:name => "of Mending", :level => 9, :range => [20,30], :require => :weapon},
			{:name => "of Curing", :level => 20, :range => [30,40], :require => :weapon},
			{:name => "of the Doctor", :level => 40, :range => [40,50], :require => :weapon}
		],
	}
	Mythical = {
		# Cooldown reduction chance on hit
		:cdr => [
			{:level => 1, :range => [5,10], :require => :weapon},
			{:level => 20, :range => [10,20], :require => :weapon},
			{:level => 40, :range => [20,30], :require => :weapon}
		],

		# Bonus stats by percent
		:bonus_str => [
			{:level => 1, :range => [2,5]},
			{:level => 25, :range => [5,8]}
		],
		:bonus_cun => [
			{:level => 1, :range => [2,5]},
			{:level => 25, :range => [5,8]}
		],
		:bonus_wis => [
			{:level => 1, :range => [2,5]},
			{:level => 25, :range => [5,8]}
		],

		# Energy on normal attacks
		:energy => [
			{:level => 1, :range => [1,2], :class => 1},
			{:level => 9, :range => [2,3], :class => 1},
			{:level => 28, :range => [3,4], :class => 1}
		],

		# Deflect can act while active
		:deflect => [
			{:level => 9, :range => [1,1], :require => :armor, :class => 1}
		],

		# Battle cry support
		:battlecry => [
			{:level => 12, :range => [10,20], :require => :armor, :class => 1}
		],

		# Wind Strength on normal attacks
		:windstr => [
			{:level => 1, :range => [5,10], :class => 2},
			{:level => 30, :range => [10,20], :class => 2}
		],

		# Squall wind strength gen
		:squall => [
			{:level => 1, :range => [1,1], :require => :weapon, :class => 2},
			{:level => 28, :range => [2,2], :require => :weapon, :class => 2}
		],

		# Soothing Mist chance to not consume strength
		:mist => [
			{:level => 5, :range => [10,10], :class => 2},
			{:level => 20, :range => [20,20], :class => 2},
			{:level => 40, :range => [30,30], :class => 2}
		],

		# Zephyr heal on cleanse
		:zephyr => [
			{:level => 1, :range => [40,60], :require => :weapon, :class => 2},
			{:level => 15, :range => [60,80], :require => :weapon, :class => 2},
			{:level => 35, :range => [80,100], :require => :weapon, :class => 2}
		],

		# Ice Blast power proc
		:iceblast => [
			{:level => 12, :range => [150,200], :require => :weapon, :class => 3},
			{:level => 28, :range => [200,250], :require => :weapon, :class => 3},
			{:level => 40, :range => [250,300], :require => :weapon, :class => 3}
		],

		# Healing power in Heart Stance
		:heart_healing => [
			{:level => 1, :range => [25,50], :require => :chest},
			{:level => 25, :range => [50,100], :require => :chest},
		],

		# Soul Stance Normal Attack Mana
		:soul_mana => [
			{:level => 1, :range => [10,10], :class => 5, :require => :weapon},
			{:level => 1, :range => [10,20], :class => 5, :require => :weapon}
		],

		# Balance Shift Quick Action
		:balance_quickness => [
			{:level => 20, :range => [1,1], :require => :feet}
		]
	}
	Labels = {
		:str => "+{x} Strength", :dex => "+{x} Cunning", :int => "+{x} Wisdom",
		:atk => "+{x} Weapon Power", :pdef => "+{x} Defense", :mdef => "+{x} Resistance",
		:agi => "+{x} Speed", :maxhp => "+{x} Maximum Life", :regen => "+{x}% Life per turn",
		:mregen => "+{x} Mana per turn",  :maxsp => "+{x} Maximum Mana",
		:thorns => "{x}% of Attack Damage dealt to Attackers",
		:spell_attack => "Attacks increase your Spell Damage by {x}% for 3 turns",
		:attack_proc => "Spells increase your Attack Damage by {x}% for 3 turns",
		:bleed => "{x}% chance for Attacks to cause Bleed for 30% of Attack Power for 3 turns",
		:lightning => "{x}% chance for Spells to trigger Chain Lightning for 50% of Spell Power",
		:surge => "{x}% chance for Heals to trigger Rejuvenating Surge for 30% of Spell Power",

		# Mythical effects
		:cdr => "Normal Attacks have a {x}% chance to reduce all cooldowns by 1 turn",
		:bonus_str => "{x}% increased Strength", :bonus_cun => "{x}% increased Cunning",
		:bonus_wis => "{x}% increased Wisdom",
		:energy => "+{x} Energy gained on Normal Attacks (Vincent only)",
		:deflect => "Deflect no longer prevents actions (Vincent only)",
		:battlecry => "Battle Cry restores {x} Mana to other allies (Vincent only)",
		:windstr => "+{x}% chance on Normal Attack to increase Wind Strength by 1 (Edward only)",
		:squall => "Squall increases Wind Strength by an additional {x} (Edward only)",
		:mist => "+{x}% chance for Soothing Mist to not expel Wind Strength (Edward only)",
		:zephyr => "Zephyr also heals for {x}% of Spell Power if it cleansed (Edward only)",
		:iceblast => "Ice Blast resets Frost Power to deal {x}% more damage (Lavinia only)",
		:heart_healing => "Heart Stance increases Healing Power by {x}% (Demi only)",
		:soul_mana => "Normal Attacks restore {x} Mana while in Soul Stance (Demi only)",
		:balance_quickness => "Balance Shift does not end your turn (Demi only)"
	}
	NamePrefixWeapon = ["Savage","Brutal","Bloodthirsty","Blood","Rune","Power",
		"Powerful","Force","Shredding","Vicious","Accurate","Final","Forbidden",
		"Kraken","Victory","Miracle","Mana","Lunar","Solar","Endless"]
	NameSuffixWeapon = ["Cleave","Wreck","Shredder","Strike","Striker","Smash","Smasher",
		"Beater","Thrust","Pummel","Rush","Element","Destroyer","Solitude","Hunger","Mind"]
	NamePrefix = ["Rune","Dire","Tough","Sturdy","Elegant","True","Forbidden","Victory",
		"Mindful","Miracle","Endless","Lunar","Solar","Majestic","Elder","Vexing","Sturdy"]
	NameSuffix = ["Hide","Shell","Protector","View","Solace","Exposure","Taste",
		"Power","Defender","Guard","Guardian","Flesh","Bulwark","Partisan","Carapace",
		"Scale","Skin","Husk","Pod","Frame"]
	NamePrefixAcc = ["Shiny","Glinting","Ancient","Rune","Tough","Elegant","True","Forbidden",
		"Victory","Mindful","Miracle","Endless","Lunar","Solar","Majestic","Elder","Vexing"]
	NameSuffixAcc = ["View","Solace","Exposure","Taste","Power","Bauble","Trinket","Artifact",
		"Idol","Braid","Rosary","Clasp","Heart","Scarab","Charm"]
	UniqueNames = ["The Ghostly Owl","The Morikan Secret","Blood of the Primal",
		"Thanatos' Decree", "The Ancient Hiss", "Treasure of the Ages", "The Forsaken",
		"Seraphim's Embrace", "The Hungerer", "The Endless Void", "The Consuming Dark",
		"The Rushing Wind", "Strength of the Gods", "The Swallow", "The Feral Lord's Heart",
		"The Flow of Mana", "The Beast Within", "Call of the Storm", "Eye of the Nameless",
		"Artifact of Arzima", "The Malohian Dream", "King of the Desert", "Eldritch Horror",
		"Fear of the Deep", "Sting of the Night", "Veil of Sorrow", "Bane of the Powerful",
		"Shroud of Indignation", "Call to Umbrage", "Eternal Vexation", "Fury of the Ages",
		"The Molten Rage", "The Tempered Wrath", "Frenzy of the Forgotten", "Song of the Siren",
		"Visage of Flames", "Lunar Artifact", "Solar Artifact", "Vestige of the Hunter",
		"The Relic of Arr'nem", "The Terakkian Heirloom", "Vision of the Elements",
		"Elemental Efficacy", "Virtue of Life", "Rise of the Giant", "Hanian Relic",
		"Resonator of the Arcane", "Light of Kokara", "Soul of Ingenia", "The Eroding Soul",
		"The Power of Change", "Conductor of Mana"]

	# Can only have one affix from this array
	Limited = [:bleed, :lightning, :surge, :spell_attack, :attack_proc]
	#--------------------------------------------------------------------------
	# * Constants
	#--------------------------------------------------------------------------
	RarityColor = [Color.new(255, 255, 255), Color.new(66, 179, 255),
		Color.new(255, 255, 66), Color.new(255, 50, 50), Color.new(255, 0, 238)]
	Types = {:weapon1 => 10, :weapon2 => 10, :head => 12, :chest => 13, :hands => 14, :feet => 15, :acc1 => 16, :acc2 => 16}
	#--------------------------------------------------------------------------
	# * Initialize
	#--------------------------------------------------------------------------
	def initialize(item, rarity)
		@base = item
		@rarity = rarity
		roll_affixes
		generate_name
	end
	#--------------------------------------------------------------------------
	# * Base Item
	#--------------------------------------------------------------------------
	def base ; @base ; end
	#--------------------------------------------------------------------------
	# * ID
	#--------------------------------------------------------------------------
	def id ; @base.id ; end
	#--------------------------------------------------------------------------
	# * Get Rarity
	#--------------------------------------------------------------------------
	def rarity
		@rarity
	end
	#--------------------------------------------------------------------------
	# * Get Affixes
	#--------------------------------------------------------------------------
	def affixes
		@affixes
	end
	#--------------------------------------------------------------------------
	# * Get Affix Label
	#--------------------------------------------------------------------------
	def affix_label(key, value, base=false)
		# Get the label
		label = Labels[key].gsub("{x}", value.to_s)
		# If base stats: remove additive indicators
		if base
			label.gsub!("+", "")
			label.gsub!("-", "")
		end
		# Return the label
		label
	end
	#--------------------------------------------------------------------------
	# * Upgrade Item
	#--------------------------------------------------------------------------
	def upgrade(rarity)
		old_rarity = @rarity
		@rarity = rarity
		roll_affixes(old_rarity)
		generate_name
		self
	end
	#--------------------------------------------------------------------------
	# * Roll Affixes
	#--------------------------------------------------------------------------
	def roll_affixes(old_rarity=-1)
		# Create affix array
		@affixes = {} unless old_rarity != -1
		# Set up prefixes and suffixes
		prefixes = (@rarity < 3 ? @rarity : 2)
		suffixes = (@rarity < 3 ? @rarity : 2)
		if old_rarity != -1
			case old_rarity
			when 1 # enchanted
				prefixes -= 1
				suffixes -= 1
			when 2,3 # superior
				prefixes -= 2
				suffixes -= 2
			end
		end
		# If rarity is normal: return
		return unless @rarity > 0 || @rarity == 4
		# Generate prefixes
		prefixes.times do
			affix = generate_affix(0)
			if affix[1][:range][0].is_a?(Float)
				@affixes[affix[0]] = affix[1][:range][rand(2)]
			else
				@affixes[affix[0]] = affix[1][:range][0] + rand(affix[1][:range][1]-affix[1][:range][0])
			end
			@name = "#{affix[1][:name]} #{@base.name} " if @rarity == 1
		end
		# Generate suffixes
		suffixes.times do
			affix = generate_affix(1)
			if affix[1][:range][0].is_a?(Float)
				@affixes[affix[0]] = affix[1][:range][rand(2)]
			else
				@affixes[affix[0]] = affix[1][:range][0] + rand(affix[1][:range][1]-affix[1][:range][0])
			end
			@name += affix[1][:name] if @rarity == 1
		end
		# Generate mythical effect if applicable
		if @rarity == 3
			affix = generate_effect
			if affix[1][:range][0].is_a?(Float)
				@affixes[affix[0]] = affix[1][:range][rand(2)]
			elsif affix[1][:range][0] != affix[1][:range][1]
				@affixes[affix[0]] = affix[1][:range][0] + rand(affix[1][:range][1]-affix[1][:range][0])
			else 
				@affixes[affix[0]] = affix[1][:range][0]
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Generate Affix
	#--------------------------------------------------------------------------
	def generate_affix(type)
		# Get map
		case type
		when 0 # prefix
			map = Prefixes
		when 1 # suffix
			map = Suffixes
		end
		# Get key array
		keys = map.keys
		# Get maximum affix level
		level = $game_party.actors[0].level
		# Finding state
		finding = true
		# Get random value until valid
		while finding
			# Get random key
			key = keys[rand(keys.size)]
			# Next if limited key and already has one
			if Limited.include?(key)
				f = false
				for k in Limited
					f = true if @affixes.keys.include?(k)
				end
				next if f
			end
			# Get random map
			m = map[key][rand(map[key].size)]
			# Check if matching level
			next if m[:level] > level || @affixes.keys.include?(key)
			# If requirement: check
			if m[:require]
				if m[:require] == :armor &&
					@base.is_a?(RPG::Weapon)
					next
				elsif m[:require] == :weapon &&
					@base.is_a?(RPG::Armor)
					next
				end
				if m[:require] != :armor && m[:require] != :weapon
					next if !element_set.include?(Types[m[:require]])
				end
			end
			# Set finding value to false
			finding = false
		end
		# Return value
		[key, m]
	end
	#--------------------------------------------------------------------------
	# * Generate Mythical Effect
	#--------------------------------------------------------------------------
	def generate_effect
		# Set map
		map = Mythical
		# Get key array
		keys = map.keys
		# Get maximum affix level
		level = $game_party.actors[0].level
		# Finding state
		finding = true
		# Get random value until valid
		while finding
			# Get random key
			key = keys[rand(keys.size)]
			# Get random map
			m = map[key][rand(map[key].size)]
			# Check if matching level
			next if m[:level] > level || @affixes.keys.include?(key)
			# Check class requirement
			if m[:class]
				cls = $data_classes[m[:class]]
				if @base.is_a?(RPG::Weapon)
					next unless cls.weapon_set.include?(@base.id)
				else
					next unless cls.armor_set.include?(@base.id)
				end
			end
			# If requirement: check
			if m[:require]
				if m[:require] == :armor && @base.is_a?(RPG::Weapon)
					next
				elsif m[:require] == :weapon && @base.is_a?(RPG::Armor)
					next
				end
				if m[:require] != :armor && m[:require] != :weapon
					next if !element_set.include?(Types[m[:require]])
				end
			end
			# Set finding value to false
			finding = false
		end
		# Return value
		[key, m]
	end
	#--------------------------------------------------------------------------
	# * Generate Name
	#--------------------------------------------------------------------------
	def generate_name
		# Return if not required
		return unless @rarity > 1
		# Get name
		case @rarity
		when 2 # rare
			prefixes = @base.is_a?(RPG::Weapon) ? NamePrefixWeapon : 
				element_set.include?(16) ? NamePrefixAcc : NamePrefix
			suffixes = @base.is_a?(RPG::Weapon) ? NameSuffixWeapon : 
				element_set.include?(16) ? NameSuffixAcc : NameSuffix
			@name = "#{prefixes[rand(prefixes.size)]} #{suffixes[rand(suffixes.size)]}"
		when 3 # mythical
			@name = UniqueNames[rand(UniqueNames.size)]
		end
	end
	#--------------------------------------------------------------------------
	# * Element Set
	#--------------------------------------------------------------------------
	def element_set
		@base.is_a?(RPG::Weapon) ? @base.element_set : @base.guard_element_set
	end
	#--------------------------------------------------------------------------
	# * Get Name
	#--------------------------------------------------------------------------
	def name(short=false)
		case @rarity
		when 0 # Normal
			return @base.name
		when 1 # Enchanted
			return @name
		when 2,3 # Rare, Mythical
			return short ? @name : "#{@name}, #{@base.name}"
		when 4 # Fabled
			return @base.name
		end
	end
	#--------------------------------------------------------------------------
	# * First Prefix
	#--------------------------------------------------------------------------
	def first_prefix
		a = nil
		@affixes.each_key {|key| a = @affixes[key] if Prefixes.keys.include?(key)}
		a
	end
	#--------------------------------------------------------------------------
	# * First Suffix
	#--------------------------------------------------------------------------
	def first_suffix
		a = nil
		@affixes.each_key {|key| a = @affixes[key] if Suffixes.keys.include?(key)}
		a
	end
	#--------------------------------------------------------------------------
	# * Rarity Color
	#--------------------------------------------------------------------------
	def color
		RarityColor[@rarity]
	end
	#--------------------------------------------------------------------------
	# * Icon Name
	#--------------------------------------------------------------------------
	def icon_name
		@base.icon_name
	end
	#--------------------------------------------------------------------------
	# * Get Attribute Value
	#--------------------------------------------------------------------------
	def attr(symbol, base=false)
		# Set zero value first
		n = 0
		# If base value found: set it
		n = @base.send(symbol) if @base.respond_to?(symbol)
		# Add affix values
		n += @affixes[symbol] if @affixes.has_key?(symbol) && !base
		# Return final number
		n
	end
end

class Game_Party
	#--------------------------------------------------------------------------
	# * Aliasing
	#--------------------------------------------------------------------------
	alias_method(:sarkilas_party_equip_init, :initialize)
	#--------------------------------------------------------------------------
	# * Attr
	#--------------------------------------------------------------------------
	attr_accessor :equipment
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize
		sarkilas_party_equip_init
		@equipment = []
	end
	#--------------------------------------------------------------------------
	# * Get Equipment
	#--------------------------------------------------------------------------
	def get_equipment(slot, actor)
		list = []
		c = $data_classes[actor.class_id]
		@equipment.each do |item| 
			next unless item
			if item.element_set.include?(Equipment::Types[slot])
				if item.is_a?(Weapon) && c.weapon_set.include?(item.id) 
					list << item
				elsif item.is_a?(Armor) && c.armor_set.include?(item.id)
					list << item
				end
			end
		end
		list
	end
end

class Game_Actor
	#--------------------------------------------------------------------------
	# * Aliasing
	#--------------------------------------------------------------------------
	alias_method(:sarkilas_actor_equip_init, :initialize)
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(actor_id)
		@weapons = [nil, nil]
		@equips = {:head => nil, :chest => nil, :feet => nil, :hands => nil, :acc1 => nil, :acc2 => nil}
		sarkilas_actor_equip_init(actor_id)
	end
	#--------------------------------------------------------------------------
	# * Equipped
	#--------------------------------------------------------------------------
	def equipped(slot)
		if slot == :weapon1
			@weapon_id = @weapons[0] ? @weapons[0].id : 0
			return @weapons[0]
		elsif slot == :weapon2
			return @weapons[1]
		else
			return @equips[slot]
		end
		nil
	end
	#--------------------------------------------------------------------------
	# * Equip
	#--------------------------------------------------------------------------
	def equip(slot, armor)
		old = @equips[slot]
		@equips[slot] = armor.is_a?(Armor) ? armor : nil
		armor.is_a?(Armor) ? old : nil
	end
	#--------------------------------------------------------------------------
	# * Equip Weapon
	#--------------------------------------------------------------------------
	def wield(index, weapon)
		old = @weapons[index]
		if weapon.is_a?(Weapon) or weapon.nil?
			@weapons[index] = weapon
			@weapon_id = weapon.id if index == 0 and weapon
			@weapon_id = 0 unless weapon
		end
		weapon.is_a?(Weapon) ? old : nil
	end
	#--------------------------------------------------------------------------
	# * Get Basic Attack Power
	#--------------------------------------------------------------------------
	def base_atk
		n = 0
		@weapons.each {|weapon| n += weapon.attr(:atk) if weapon}
		n /= 2 if @class_id == 1
		[n, 1].max
	end
	#--------------------------------------------------------------------------
	# * Base Strength
	#--------------------------------------------------------------------------
	def base_str
		n = $data_actors[@actor_id].parameters[2, @level]
		@weapons.each {|weapon| n += weapon.attr(:str) if weapon}
		@equips.each_value {|equip| n += equip.attr(:str) if equip}
		n
	end
	#--------------------------------------------------------------------------
	# * Base Cunning
	#--------------------------------------------------------------------------
	def base_dex
		n = $data_actors[@actor_id].parameters[3, @level]
		@weapons.each {|weapon| n += weapon.attr(:dex) if weapon}
		@equips.each_value {|equip| n += equip.attr(:dex) if equip}
		n
	end
	#--------------------------------------------------------------------------
	# * Base Speed
	#--------------------------------------------------------------------------
	def base_agi
		n = $data_actors[@actor_id].parameters[4, @level]
		@weapons.each {|weapon| n += weapon.attr(:agi) if weapon}
		@equips.each_value {|equip| n += equip.attr(:agi) if equip}
		n
	end
	#--------------------------------------------------------------------------
	# * Base Wisdom
	#--------------------------------------------------------------------------
	def base_int
		n = $data_actors[@actor_id].parameters[5, @level]
		@weapons.each {|weapon| n += weapon.attr(:int) if weapon}
		@equips.each_value {|equip| n += equip.attr(:int) if equip}
		n
	end
	#--------------------------------------------------------------------------
	# * Base Defense
	#--------------------------------------------------------------------------
	def base_pdef
		n = 0
		@weapons.each {|weapon| n += weapon.attr(:pdef) if weapon}
		@equips.each_value {|equip| n += equip.attr(:pdef) if equip}
		n
	end
	#--------------------------------------------------------------------------
	# * Base Resistance
	#--------------------------------------------------------------------------
	def base_mdef
		n = 0
		@weapons.each {|weapon| n += weapon.attr(:mdef) if weapon}
		@equips.each_value {|equip| n += equip.attr(:mdef) if equip}
		n
	end
	#--------------------------------------------------------------------------
	# * Animation ID 1
	#--------------------------------------------------------------------------
	def animation1_id
		return @weapons[0] ? @weapons[0].attr(:animation1_id) : 0
	end
	#--------------------------------------------------------------------------
	# * Animation ID 2
	#--------------------------------------------------------------------------
	def animation2_id
		return @weapons[0] ? @weapons[0].attr(:animation1_id) : 0
	end
end

class Weapon
	#--------------------------------------------------------------------------
	# * Module Inclusions
	#--------------------------------------------------------------------------
	include Equipment
end

class Armor
	#--------------------------------------------------------------------------
	# * Module Inclusions
	#--------------------------------------------------------------------------
	include Equipment
end