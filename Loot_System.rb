#==============================================================================
# ** Loot System
#------------------------------------------------------------------------------
#  This section deals with treasure generation and displaying loot after battle.
#==============================================================================

module LootWindow
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize
		super(64, 64, 512, 352)
		@treasure = nil
		refresh
		self.visible = false
		self.z = 999999
	end
	#--------------------------------------------------------------------------
	# * Refresh
	#--------------------------------------------------------------------------
	def refresh
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
		# Return if no treasure
		return unless @treasure
		# Draw all treasure
		for i in 0...@treasure[:items].size
			draw_treasure(i, @treasure[:items][i], bitmap)
		end
		# Draw no treasure indicator if necessary
		if @treasure[:items].size == 0
			bitmap.draw_text(8, 8, @width, 34, "No loot")
		end
		# Draw gold and experience
		bitmap.font.color = Color.new(255, 255, 255)
		bitmap.draw_text(8, @height - 34, @width, 34, "#{@treasure[:gold]} #{$data_system.words.gold}")
		bitmap.draw_text(8, @height - 34, @width - 16, 34, "#{@treasure[:exp]} Exp", 2)
		# Set bitmap
		@contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Draw Treasure
	#--------------------------------------------------------------------------
	def draw_treasure(row, item, bitmap)
		# Get coordinates
		y = 8 + row * 34
		# Get item color
		bitmap.font.color = item.is_a?(RPG::Item) ? Color.new(255, 255, 255) : item.color
		# Get icon
		icon = RPG::Cache.icon(item.icon_name)
		# Draw icon
		bitmap.blt(8 + 17 - icon.width / 2, y + 17 - icon.height / 2,
			icon, Rect.new(0, 0, icon.width, icon.height))
		# Draw item name
		bitmap.draw_text(44, y, @width, 34, item.name)
	end
	#--------------------------------------------------------------------------
	# * Visibility Setting
	#--------------------------------------------------------------------------
	def visible=(bool)
		super
		self.objects[0].visible = bool
		@contents.visible = bool
		Audio.se_play("Audio/SE/Open Bag") if bool
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

class Loot < Interface::Container
	#--------------------------------------------------------------------------
	# * Constants
	#--------------------------------------------------------------------------
	DefaultLootRange = [0,0,1,1,1,1,1,2]
	LootRange = {
		2 => [0],			# Morikan Soldier
		3 => [3],			# Morikan Officer
		8 => [5],			# Nightmare Vinewrath
		9 => [0],			# Vine Amalgam
	}
	LootBonus = {
		3 => 2.0,			# Morikan Officer
		8 => 4.0,			# Nightmare Vinewrath
	}
	OrbRate = {
		2 => 100,
		3 => 80,
		4 => 33,
		5 => 33,
		6 => 26,
		7 => 20,
		8 => 6,
		9 => 4,
		10 => 3
	}
	#--------------------------------------------------------------------------
	# * Module Inclusions
	#--------------------------------------------------------------------------
	include LootWindow
	#--------------------------------------------------------------------------
	# * Generate Treasure
	#--------------------------------------------------------------------------
	def generate_treasure
		# Set up treasure map
		@treasure = {:exp => 0, :gold => 0, :items => []}
		# Iterate all enemies in troop
		$game_troop.enemies.each do |enemy|
			# Generate items
			@treasure[:items].concat(generate_items(enemy))
			# Add exp and gold to treasure
			@treasure[:exp] += enemy.exp
			@treasure[:gold] += enemy.gold
		end
		# Gain loot and refresh
		gain_loot
		refresh
	end
	#--------------------------------------------------------------------------
	# * Gain Loot
	#--------------------------------------------------------------------------
	def gain_loot
		# Return if no treasure
		return unless @treasure
		# Add all items
		@treasure[:items].each do |item|
			case item
			when Weapon, Armor
				$game_party.equipment << item
			when RPG::Item
				$game_party.gain_item(item.id, 1)
			end
		end
		# Gain gold
		$game_party.gain_gold(@treasure[:gold])
	end
	#--------------------------------------------------------------------------
	# * Generate Items
	#--------------------------------------------------------------------------
	def generate_items(enemy)
		# Set up item array
		items = []
		# Get loot range
		range = LootRange.has_key?(enemy.id) ? LootRange[enemy.id] : DefaultLootRange
		# Get the number of items this enemy dropped
		num = range[rand(range.size)]
		# For each item, roll that item and add to list
		num.times {items << roll_item(LootBonus[enemy.id] ? LootBonus[enemy.id] : 1.0)}
		# If loot bonus is 4 or greater: guarantee mythical item
		if LootBonus[enemy.id] && LootBonus[enemy.id] >= 4.0
			if rand(100) < 50
				weapon_id = get_item_id($data_weapons)
				items << Weapon.new($data_weapons[weapon_id], 3)
			else
				armor_id = get_item_id($data_armors)
				items << Armor.new($data_armors[armor_id], 3)
			end
		end
		# Return items
		items
	end
	#--------------------------------------------------------------------------
	# * Roll Item
	#--------------------------------------------------------------------------
	def roll_item(multiplier)
		# Roll for item type
		roll = rand(100)
		# Check what item type rolled
		if roll < 25
			return roll_orb
		elsif roll < 50
			return roll_weapon(multiplier)
		else
			return roll_armor(multiplier)
		end
	end
	#--------------------------------------------------------------------------
	# * Roll Orb
	#--------------------------------------------------------------------------
	def roll_orb
		# Roll first
		roll = rand(100)
		# Check in descending order
		for i in 0...9
			# Get index descending
			index = 10 - i
			# Check if orb rolled successfully
			if roll < OrbRate[index]
				return $data_items[index]
			end
		end
		# Return error
		print "Something went wrong."
	end
	#--------------------------------------------------------------------------
	# * Roll Weapon
	#--------------------------------------------------------------------------
	def roll_weapon(multiplier)
		# Get the weapon ID
		weapon_id = get_item_id($data_weapons)
		# Return the weapon
		Weapon.new($data_weapons[weapon_id], roll_rarity(multiplier))
	end
	#--------------------------------------------------------------------------
	# * Roll Armor
	#--------------------------------------------------------------------------
	def roll_armor(multiplier)
		# Get the armor ID
		armor_id = get_item_id($data_armors)
		# Return the armor
		Armor.new($data_armors[armor_id], roll_rarity(multiplier))
	end
	#--------------------------------------------------------------------------
	# * Roll Rarity
	#--------------------------------------------------------------------------
	def roll_rarity(multiplier)
		# Roll first
		roll = rand(100)
		# Return respective rarity
		if roll < 2 * multiplier
			return 3
		elsif roll < 20 * multiplier
			return 2
		elsif roll < 50 * multiplier
			return 1
		else
			return 0
		end
	end
	#--------------------------------------------------------------------------
	# * Get Dropped Item ID
	#--------------------------------------------------------------------------
	def get_item_id(data)
		# Get level of main actor
		level = $game_party.actors[0].level
		# Get array of all droppable weapons
		table = get_drop_table(data, level)
		# Return a random item ID
		table[rand(table.size)]
	end
	#--------------------------------------------------------------------------
	# * Get Drop Table
	#--------------------------------------------------------------------------
	def get_drop_table(data, level)
		# Set up array
		table = []
		# Iterate all data provided
		data.each do |item|
			next unless item
			next if item.description.empty?
			ilvl = Integer(item.description)
			if ilvl <= level
				if item.is_a?(RPG::Weapon)
					can_drop = true
					for i in 5..6
						break if $game_actors[i].level > 1
						class_data = $data_classes[$game_actors[i].class_id]
						if class_data.weapon_set.include?(item.id)
							can_drop = false
							break
						end
					end
					next unless can_drop
				end
				table << item.id 
			end
		end
		# Return the table
		table
	end
end