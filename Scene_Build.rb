#==============================================================================
# ** Scene_Build
#------------------------------------------------------------------------------
#  This class performs build screen processing.
#==============================================================================

class Scene_Build
	#--------------------------------------------------------------------------
	# * Main
	#--------------------------------------------------------------------------
	def main
		# Create map spriteset
		@map = Spriteset_Map.new
		# Create framework
		create_framework
		# Set start phase
		@phase = :skills
		@actor = $game_party.actors[0]
		@windows[:stats].set_actor(@actor)
		@windows[:select].set_actor(@actor)
		@windows[:talents].set_actor(@actor)
		@windows[:skills].set_actor(@actor)
		# Transition
		Graphics.transition
		# Main loop
		while $scene == self
			# Update core modules
			Graphics.update
			Input.update
			Mouse.show_cursor(true)
			# Update scene
			update
		end
		# Freeze graphics
		Graphics.freeze
		# Dispose
		@map.dispose
		dispose_framework
	end
	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update
		# Update windows
		@windows[:actors].update
		@windows[:select].update(@phase != :actor)
		# Update core elements
		update_actor_phase
		update_tooltips
		# Phase case
		case @phase
		when :skills
			update_skill_phase
		when :stats
			update_stats_phase
		when :talents
			update_talents_phase
		end
	end
	#--------------------------------------------------------------------------
	# * Update Actor Phase
	#--------------------------------------------------------------------------
	def update_actor_phase
		# Update cancel
		if Input.trigger?(Keys::ESC) or
			Input.trigger?(Keys::MOUSE_RIGHT)
			# Play SE
			$game_system.se_play($data_system.cancel_se)
			# Return to menu
			$scene = Scene_Menu.new
			return
		end
	end
	#--------------------------------------------------------------------------
	# * Update Skill Phase
	#--------------------------------------------------------------------------
	def update_skill_phase
		# Set visibility state
		@windows[:skills].visible = true
		@windows[:skills].update
	end
	#--------------------------------------------------------------------------
	# * Update Stats Phase
	#--------------------------------------------------------------------------
	def update_stats_phase
		# Set visibility state of respective windows
		@windows[:stats].visible = true
		# Update buttons
		keys = [:str, :cun, :wis]
		keys.each do |key|
			if @buttons[key].opacity < 255
				@buttons[key].fade_in
			else
				@buttons[key].update
			end
		end
	end
	#--------------------------------------------------------------------------
	# * Update Talents Phase
	#--------------------------------------------------------------------------
	def update_talents_phase
		# Set visibility state of respective windows
		@windows[:talents].visible = true
		@windows[:talents].update
	end
	#--------------------------------------------------------------------------
	# * Update Tooltips
	#--------------------------------------------------------------------------
	def update_tooltips
		# Hide all tooltips first
		Tooltips.hide
		# Show required tooltips (talents)
		if @windows[:talents].item
			show_tooltip(:talent, @actor, @windows[:talents].item)
		end
		# Show required tooltips (skills)
		if @windows[:skills].item
			show_tooltip(:skill, @actor, @windows[:skills].item)
		end
	end
	#--------------------------------------------------------------------------
	# * Set Phase
	#--------------------------------------------------------------------------
	def set_phase(phase)
		# Freeze graphics
		Graphics.freeze
		# Set phase
		@phase = phase
		# Hide windows
		@windows[:stats].visible = false
		@windows[:talents].visible = false
		@windows[:skills].visible = false
		# Hide buttons
		if @buttons[:str].opacity > 0 and @phase != :stats
			keys = [:str, :cun, :wis]
			keys.each {|key| @buttons[key].opacity = 0}
		end
		# Perform transition
		Graphics.transition(10)
	end
	#--------------------------------------------------------------------------
	# * Use Talent
	#--------------------------------------------------------------------------
	def use_talent
		# If no talent selected: return
		unless @windows[:talents].item
			# Play buzzer SE
			$game_system.se_play($data_system.buzzer_se)
			return
		end
		# Get selected talent
		talent = Talents::Data[@windows[:talents].item]
		# Get point type index
		index = talent[:points] > 1 ? 1 : 0
		# If no available points or capped points: return
		if @actor.talent_points[index] <= 0 ||
			@actor.talents(@windows[:talents].item, true) == talent[:points]
			# Play buzzer SE
			$game_system.se_play($data_system.buzzer_se)
			return
		end
		# Check requirement
		if talent[:require]
			# Get required talent
			req = Talents::Data[talent[:require]]
			# If points don't match: return
			unless req[:points] == @actor.talents(talent[:require], true)
				# Play buzzer SE
				$game_system.se_play($data_system.buzzer_se)
				return
			end
		end
		# Learn talent
		@actor.learn_talent(@windows[:talents].item)
		# Refresh talent window
		@windows[:select].refresh
		@windows[:stats].refresh
		@windows[:talents].refresh
		# Refresh tooltip
		Tooltips[@windows[:talents].item].refresh
		# Play sound
		Audio.se_play("Audio/SE/Talent")
	end
	#--------------------------------------------------------------------------
	# * Command Add Stat
	#--------------------------------------------------------------------------
	def command_add_stat(key)
		# If no actor: return
		unless @actor
			$game_system.se_play($data_system.buzzer_se)
			return
		end
		# If no stat points: return
		if @actor.stat_points <= 0
			$game_system.se_play($data_system.buzzer_se)
			return
		end
		# Get value to add
		value = Input.press?(Keys::SHIFT) ? @actor.stat_points >= 5 ? 5 : @actor.stat_points : 1
		# Add stat
		@actor.add_stat(key, value)
		# Refresh windows
		@windows[:actors].refresh
		@windows[:stats].refresh
		@windows[:select].refresh
	end
	#--------------------------------------------------------------------------
	# * Create Framework
	#--------------------------------------------------------------------------
	def create_framework
		create_windows
		create_buttons
	end
	#--------------------------------------------------------------------------
	# * Create Windows
	#--------------------------------------------------------------------------
	def create_windows
		# Set up map
		@windows = {}
		# Get shove value
		shove = 17 * [$game_party.actors.size - 4, 0].max
		# Add windows
		@windows[:actors] = Window_ActorSelectSmall.new(64 - shove, 64)
		@windows[:actors].bind(Proc.new {
			@actor = @windows[:actors].item
			@windows[:stats].set_actor(@actor)
			@windows[:select].set_actor(@actor)
			@windows[:talents].set_actor(@actor)
			@windows[:skills].set_actor(@actor)
			# Transition graphics
			if @buttons[:str].opacity > 0
				Graphics.freeze
				keys = [:str, :cun, :wis]
				keys.each {|key| @buttons[key].opacity = 0}
				Graphics.transition
			end
		})
		@windows[:select] = Window_BuildSelect.new(64 - shove, 120, 136 + 34 * [$game_party.actors.size - 4, 0].max, 116)
		@windows[:select].bind(Proc.new {set_phase(@windows[:select].symbol)})
		@windows[:stats] = Window_ActorStats.new(200 + shove, 64)
		@windows[:talents] = Window_Talents.new(200 + shove, 64)
		@windows[:talents].bind(Proc.new {use_talent})
		@windows[:skills] = Window_Skills.new(200 + shove, 64)
	end
	#--------------------------------------------------------------------------
	# * Create Buttons
	#--------------------------------------------------------------------------
	def create_buttons
		# Set up map
		@buttons = {}
		# Get shove value
		shove = 17 * [$game_party.actors.size - 4, 0].max
		# Create stat buttons
		@buttons[:str] = Interface::Button.new(64 - shove, 236, 136 + [$game_party.actors.size - 4, 0].max, "+1 Strength")
		@buttons[:str].bind(Proc.new {command_add_stat(:str)})
		@buttons[:str].opacity = 0
		@buttons[:cun] = Interface::Button.new(64 - shove, 266, 136 + [$game_party.actors.size - 4, 0].max, "+1 Cunning")
		@buttons[:cun].bind(Proc.new {command_add_stat(:cun)})
		@buttons[:cun].opacity = 0
		@buttons[:wis] = Interface::Button.new(64 - shove, 296, 136 + [$game_party.actors.size - 4, 0].max, "+1 Wisdom")
		@buttons[:wis].bind(Proc.new {command_add_stat(:wis)})
		@buttons[:wis].opacity = 0
	end
	#--------------------------------------------------------------------------
	# * Show Tooltip
	#--------------------------------------------------------------------------
	def show_tooltip(type, actor, item)
		unless Tooltips.exists?(item)
			create_tooltip(type, actor, item)
		end
		Tooltips.show(item)
	end
	#--------------------------------------------------------------------------
	# * Create Tooltip
	#--------------------------------------------------------------------------
	def create_tooltip(type, actor, item)
		case type
		when :skill
			Tooltips.add(item, Window_SkillTooltip.new(actor, $data_skills[item]))
		when :talent
			Tooltips.add(item, Window_TalentTooltip.new(actor, Talents::Data[item]))
		end
	end
	#--------------------------------------------------------------------------
	# * Dispose Framework
	#--------------------------------------------------------------------------
	def dispose_framework
		@windows.each_value {|window| window.dispose}
		@buttons.each_value {|button| button.dispose}
		Tooltips.hide
	end
end

#==============================================================================
# ** Window_SkillTooltip
#------------------------------------------------------------------------------
#  This class displays the window for tooltips for skills.
#==============================================================================

class Window_SkillTooltip < Interface::Tooltip
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(actor, skill)
		@actor = actor
		@skill = skill
		calculate_dimensions
		super(0, 0, @width, @height)
		refresh
		self.visible = false
		self.z = 99999
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
		# Draw talent name
		bitmap.font.color = Color.new(255, 180, 180)
		bitmap.draw_text(4, 4, @width, @dim.height, @skill.name)
		# Draw cost
		i = 1
		if @skill.sp_cost > 0
			color = Color.new(66, 134, 255)
			text = "#{@skill.sp_cost} Mana"
			if @skill.element_set.include?(9) && @actor
				color = Game_Actor::Resources[@actor.class_id][:color] 
				text = Game_Actor::Resources[@actor.class_id][:cost].gsub("{x}", 
					@skill.sp_cost.to_s)
			elsif @skill.element_set.include?(9)
				color = Color.new(255, 135, 255)
				text = "#{@skill.sp_cost} Unison Power"
			end
			bitmap.font.color = color
			bitmap.draw_text(4, 4 + @dim.height, @width, @dim.height, text)
			i += 1
		elsif @skill.element_set.include?(9)
			color = Game_Actor::Resources[@actor.class_id][:color] 
			text = Game_Actor::Resources[@actor.class_id][:all]
			bitmap.font.color = color
			bitmap.draw_text(4, 4 + @dim.height, @width, @dim.height, text)
			i += 1
		end
		# Draw secondary resource gain
		if Skills::Secondary[@skill.id]
			color = Game_Actor::Resources[@actor.class_id][:color] 
			text = Game_Actor::Resources[@actor.class_id][:label].gsub("{x}", 
				Skills::Secondary[@skill.id].to_s)
			bitmap.font.color = color
			bitmap.draw_text(4, 4 + @dim.height * i, @width, @dim.height, text)
			i += 1
		end
		# Draw passive state
		if @skill.element_set.include?(26)
			bitmap.font.color = Color.new(200, 200, 255)
			bitmap.draw_text(4, 4 + @dim.height * i, @width, @dim.height, "Passive Skill")
			i += 1
		end
		# Draw all description lines
		bitmap.font.color = Color.new(255, 255, 255)
		@lines = wrap_text(Skills::Descriptions[@skill.id], 33)
		@lines.each_line do |line|
			bitmap.draw_text(4, 4 + @dim.height * i, @width, @dim.height, line)
			i += 1
		end
		# Draw cooldown
		if Skills::Cooldowns[@skill.id]
			bitmap.font.color = Color.new(150, 150, 255)
			bitmap.draw_text(4, 4 + @dim.height * i, @width, @dim.height, "#{Skills::Cooldowns[@skill.id]} turn cooldown")
		end
		# Set bitmap
		@contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update
		super
		self.x = Mouse.x - @width
		self.y = Mouse.y - @height
		self.x = 0 if self.x < 0
		self.y = 0 if self.y < 0
	end
	#--------------------------------------------------------------------------
	# * Calculate Dimensions
	#--------------------------------------------------------------------------
	def calculate_dimensions
		# Create temporary bitmap for size calculations
		bitmap = Bitmap.new(640, 480)
		# Get base dimensions
		@dim = bitmap.text_size(@skill.name)
		# Get width of talent name
		@width = @dim.width
		@height = @dim.height + 8
		# Add line for passive skill
		@height += @dim.height if @skill.element_set.include?(26)
		# Add line for cost if any
		@height += @dim.height if @skill.sp_cost > 0 || @skill.element_set.include?(9)
		# Add line for secondary resource gain if any
		@height += @dim.height if Skills::Secondary[@skill.id]
		# Add line for cooldown if any
		@height += @dim.height if Skills::Cooldowns[@skill.id]
		# Get description lines
		@lines = wrap_text(Skills::Descriptions[@skill.id], 33)
		# Add all lines
		@lines.each_line do |line| 
			@height += @dim.height
			width = bitmap.text_size(line).width
			@width = width if width > @width
		end
		# Add to width
		@width += 8
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
	# * Visibility Setting
	#--------------------------------------------------------------------------
	def visible=(bool)
		super
		self.objects[0].visible = bool
		@contents.visible = bool
	end
end

#==============================================================================
# ** Window_Skills
#------------------------------------------------------------------------------
#  This class displays the window for selecting skills.
#==============================================================================

class Window_Skills < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y)
		super(x, y, 376, 376)
		@actor = nil
		refresh
		@fade_in = true
	end
	#--------------------------------------------------------------------------
	# * Clickable?
	#--------------------------------------------------------------------------
	def clickable?
		false
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
				if $data_skills[@data[i]].element_set.include?(26)
					@data.insert(0, @data.delete_at(i))
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
	end
	#--------------------------------------------------------------------------
    # * Item Rect
    #--------------------------------------------------------------------------
    def item_rect(index)
      Rect.new(@x, @y + 8 + 36 * index, @width, 36)
    end
    #--------------------------------------------------------------------------
    # * Draw Item
    #--------------------------------------------------------------------------
    def draw_item(index, bitmap)
    	# Get Y position
    	y = 8 + 36 * index
    	# Get skill
    	skill = $data_skills[@data[index]]
    	# Get icon
    	icon = RPG::Cache.icon(skill.icon_name)
    	# Draw icon
    	bitmap.blt(24 - icon.width / 2, y + 18 - icon.height / 2, 
    		icon, Rect.new(0, 0, icon.width, icon.height))
    	# Draw label
    	bitmap.font.color = Color.new(255, 255, 255)
    	bitmap.draw_text(44, y, item_rect(index).width - 40, 36, skill.name)
    	# Draw cost
    	if skill.sp_cost > 0
	    	color = skill.element_set.include?(9) ? Game_Actor::Resources[@actor.class_id][:color] : Color.new(66, 134, 255)
	    	bitmap.font.color = color
	    	bitmap.draw_text(4, y, item_rect(index).width - 16, 36, skill.sp_cost.to_s, 2)
	    end
    end
end

#==============================================================================
# ** Window_TalentTooltip
#------------------------------------------------------------------------------
#  This class displays the window for tooltips for talents.
#==============================================================================

class Window_TalentTooltip < Interface::Tooltip
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(actor, talent)
		@talent = talent
		@actor = actor
		calculate_dimensions
		super(0, 0, @width, @height)
		refresh
		self.visible = false
		self.z = 99999
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
		# Draw talent name
		bitmap.font.color = Color.new(255, 180, 180)
		bitmap.draw_text(4, 4, @width, @dim.height, @talent[:name])
		# Draw talent type
		bitmap.font.color = Color.new(180, 180, 255)
		bitmap.draw_text(4, 4 + @dim.height, @width, @dim.height, 
			@talent[:points] > 1 ? "Minor Talent" : "Major Talent")
		# Draw all description lines
		i = 2
		bitmap.font.color = Color.new(255, 255, 255)
		@lines = wrap_text(Talents.parse(@talent, @actor), 33)
		@lines.each_line do |line|
			bitmap.draw_text(4, 4 + @dim.height * i, @width, @dim.height, line)
			i += 1
		end
		# Set bitmap
		@contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update
		super
		self.x = Mouse.x - @width
		self.y = Mouse.y - @height
		self.x = 0 if self.x < 0
		self.y = 0 if self.y < 0
	end
	#--------------------------------------------------------------------------
	# * Calculate Dimensions
	#--------------------------------------------------------------------------
	def calculate_dimensions
		# Create temporary bitmap for size calculations
		bitmap = Bitmap.new(640, 480)
		# Get base dimensions
		@dim = bitmap.text_size(@talent[:name])
		# Get width of talent name
		@width = @dim.width
		@height = @dim.height + 8
		# Add line for talent type
		@height += @dim.height
		# Get description lines
		@lines = wrap_text(Talents.parse(@talent, @actor), 33)
		# Add all lines
		@lines.each_line do |line| 
			@height += @dim.height
			width = bitmap.text_size(line).width
			@width = width if width > @width
		end
		# Add to width
		@width += 8
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
	# * Visibility Setting
	#--------------------------------------------------------------------------
	def visible=(bool)
		super
		self.objects[0].visible = bool
		@contents.visible = bool
	end
end

#==============================================================================
# ** Window_Talents
#------------------------------------------------------------------------------
#  This class displays the window for an actor's talents.
#==============================================================================

class Window_Talents < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y)
		@columns = 4
		super(x, y, 376, 352)
		@actor = nil
		refresh
		self.visible = false
	end
	#--------------------------------------------------------------------------
	# * Set Actor
	#--------------------------------------------------------------------------
	def set_actor(actor)
		@actor = actor
		refresh
	end
	#--------------------------------------------------------------------------
	# * Refresh
	#--------------------------------------------------------------------------
	def refresh
		super
		# Create bitmap
		bitmap = Bitmap.new(@width, @height)
		# Only draw if actor
		if @actor
			# Get talent points
			points = @actor.talent_points
			# Draw points
			bitmap.font.color = points[0] > 0 ? Color.new(180, 255, 180) : Color.new(255, 255, 255)
			w = bitmap.text_size("#{points[0]} Major").width
			bitmap.draw_text(@width / 2 - w - 4, 0, w + 16, 24, "#{points[0]} Major")
			bitmap.font.color = points[1] > 0 ? Color.new(180, 255, 180) : Color.new(255, 255, 255)
			w = bitmap.text_size("#{points[1]} Minor").width
			bitmap.draw_text(@width / 2 + 4, 0, w + 16, 24, "#{points[1]} Minor")
			bitmap.font.color = Color.new(255, 255, 255)
			# Get talents
			@talents = Talents.get(@actor.class_id)
			@data = []
			@i = 0
			row = Talents.get(@actor.class_id, 1)
			keys = row.keys
			keys.each {|key|
				draw_talent(key, bitmap, 1)
			}
			for i in 2..3
				row = Talents.get(@actor.class_id, i)
				temp = []
				for k in keys
					row.each_key {|key|
						if row[key][:require] == k
							draw_talent(key, bitmap, i)
							temp << key
						end
					}
				end
				keys = temp
			end
		end
		# Set bitmap
		self.contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Item Rect
	#--------------------------------------------------------------------------
	def item_rect(index)
		Rect.new(@x + 60 + 64 * (index % @columns), @y + 24 + 101 * (index / @columns), 64, 64)
	end
	#--------------------------------------------------------------------------
	# * Visibility Setting
	#--------------------------------------------------------------------------
	def visible=(bool)
		super
		self.objects[0].visible = bool
		self.contents.visible = bool
	end
	#--------------------------------------------------------------------------
	# * Draw Talent
	#--------------------------------------------------------------------------
	def draw_talent(key, bitmap, row)
		# Add to data
		@data << key
		# Get rect
		rect = item_rect(@i)
		# Get talent data
		talent = @talents[key]
		# Get icon
		icon = RPG::Cache.gui("Talents/#{talent[:name]}")
		# Draw icon
		bitmap.blt(rect.x - @x + 32 - icon.width/2, rect.y - @y + 24 - icon.height/2, 
			icon, Rect.new(0, 0, icon.width, icon.height))
		# Draw points
		bitmap.font.size = 24
		bitmap.draw_text(rect.x - @x + 4, rect.y - @y + 36, rect.width - 8, 32, 
			"#{@actor.talents(key, true)}/#{talent[:points]}", 1)
		# If row is less than 3: draw arrow
		if row < 3
			arrow = RPG::Cache.gui("Talents/Arrow")
			bitmap.blt(rect.x - @x + 32 - arrow.width/2, rect.y - @y + rect.height + 4,
				arrow, Rect.new(0, 0, arrow.width, arrow.height), 180)
		end
		# Increase index
		@i += 1
	end
end

#==============================================================================
# ** Window_ActorStats
#------------------------------------------------------------------------------
#  This class displays the window for showing all actor stats.
#==============================================================================

class Window_ActorStats < Interface::Container
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y, width=376)
		super(x, y, width, 352)
		@actor = nil
		refresh
		self.visible = false
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
		# Draw all stats
		if @actor
			draw_stat(0, "Defense", @actor.pdef.to_s, bitmap)
			draw_stat(1, "Resistance", @actor.mdef.to_s, bitmap)
			draw_stat(2, "Attack Power", @actor.atk.to_s, bitmap)
			draw_stat(3, "Attack Power Multiplier", "#{@actor.attack_power}%", bitmap)
			draw_stat(4, "Spell Power", @actor.spell_atk.to_s, bitmap)
			draw_stat(5, "Spell Power Multiplier", "#{@actor.spell_power}%", bitmap)
			draw_stat(6, "Strength", @actor.str.to_s, bitmap)
			draw_stat(7, "Cunning", @actor.dex.to_s, bitmap)
			draw_stat(8, "Wisdom", @actor.int.to_s, bitmap)
			draw_stat(9, "Critical Strike Damage Bonus", "#{((@actor.crit_damage - 1) * 100).to_i}%", bitmap)
			draw_stat(10, "Critical Strike Chance", "#{@actor.crit_chance}%", bitmap)
			draw_stat(11, "Mana Regenerated per Turn", @actor.mana_regen.to_s, bitmap)
			draw_stat(12, "Mana Regeneration Multiplier", "#{@actor.int * 3}%", bitmap)
			draw_stat(13, "Speed", @actor.agi.to_s, bitmap)
		end
		# Set bitmap
		@contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Set Actor
	#--------------------------------------------------------------------------
	def set_actor(actor)
		@actor = actor
		refresh
	end
	#--------------------------------------------------------------------------
	# * Draw Stat
	#--------------------------------------------------------------------------
	def draw_stat(row, name, value, bitmap)
		# Get coordinates
		y = 8 + row * 24
		# Determine if separator is needed
		if row % 2 == 1
			# Get separator color
			color = Color.new(200, 110, 70, 125)
			# Draw separator
			bitmap.fill_rect(1, y, @width - 2, 24, color)
		end
		# Draw label
		bitmap.font.color = Color.new(255, 180, 180)
		bitmap.draw_text(8, y, @width - 16, 24, name)
		# Draw value
		bitmap.font.color = Color.new(255, 255, 255)
		bitmap.draw_text(8, y, @width - 16, 24, value, 2)
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

#==============================================================================
# ** Window_BuildSelect
#------------------------------------------------------------------------------
#  This class displays the window for selecting build commands.
#==============================================================================

class Window_BuildSelect < Interface::Selectable
	#--------------------------------------------------------------------------
	# * Object Initialization
	#--------------------------------------------------------------------------
	def initialize(x, y, width, height)
		super(x, y, width, height)
		@actor = nil
		refresh
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
		# Draw all options
		@data = ["Skills", "Stats", "Talents"]
		for i in 0...@data.size
			draw_item(i, bitmap)
		end
		# Set bitmap
		self.contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Get Symbol
	#--------------------------------------------------------------------------
	def symbol
		syms = [:skills, :stats, :talents]
		self.index >= 0 ? syms[self.index] : nil
	end
	#--------------------------------------------------------------------------
	# * Set Actor
	#--------------------------------------------------------------------------
	def set_actor(actor) 
		@actor = actor
		refresh
	end
	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update(active)
		# Set active state
		@active = active
		# Hide highlight if inactive
		unless @active
			@highlight.visible = false
			@index = -1
			return
		end
		# Call superclass
		super()
	end
	#--------------------------------------------------------------------------
    # * Clickable?
    #--------------------------------------------------------------------------
    def clickable?
      @active
    end
	#--------------------------------------------------------------------------
    # * Item Rect
    #--------------------------------------------------------------------------
    def item_rect(index)
      Rect.new(@x, @y + 2 + 36 * index, @width, 36)
    end
    #--------------------------------------------------------------------------
    # * Draw Item
    #--------------------------------------------------------------------------
    def draw_item(index, bitmap)
    	# Get Y position
    	y = 8 + 36 * index
    	# Get text
    	text = @data[index]
    	# Get icon
    	icon = RPG::Cache.gui("Menu/#{text}")
    	# Draw icon
    	bitmap.blt(24 - icon.width / 2, y + 12 - icon.height / 2, 
    		icon, Rect.new(0, 0, icon.width, icon.height))
    	# Draw label
    	bitmap.font.color = Color.new(255, 255, 255)
    	bitmap.draw_text(44, y, item_rect(index).width - 40, 24, text)
    	# Return if no actor
    	return unless @actor
    	# Draw values
    	if text == "Stats" && @actor.stat_points > 0
    		bitmap.font.color = Color.new(180, 255, 180)
    		bitmap.draw_text(8, y, item_rect(index).width - 16, 24, @actor.stat_points.to_s, 2)
    	elsif text == "Talents" && (@actor.talent_points[0] > 0 || @actor.talent_points[1] > 0)
    		bitmap.font.color = Color.new(180, 255, 180)
    		points = @actor.talent_points[0] + @actor.talent_points[1]
    		bitmap.draw_text(8, y, item_rect(index).width - 16, 24, points.to_s, 2)
    	end
    end
end

#==============================================================================
# ** Window_ActorSelectSmall
#------------------------------------------------------------------------------
#  This class contains a minimal window for selecting actors.
#==============================================================================

class Window_ActorSelectSmall < Interface::Selectable
	#----------------------------------------------------------------------------
	# * Object Initialization
	#----------------------------------------------------------------------------
	def initialize(x, y)
		@columns = 4
		super(x, y, 136 + 34 * [$game_party.actors.size - 4, 0].max, 56)
		refresh
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
			draw_actor_graphic((@width / @data.size) * i + (@width / (@data.size * 2)), 4, @data[i], bitmap)
			if @data[i].stat_points > 0
				bitmap.font.color = Color.new(180, 255, 180)
				bitmap.draw_text((@width / @data.size) * i, 32, (@width / @data.size) - 4, 20, @data[i].stat_points.to_s, 2)
			end
		end
		# Set bitmap
		self.contents.bitmap = bitmap
	end
	#--------------------------------------------------------------------------
	# * Update
	#--------------------------------------------------------------------------
	def update(active=true)
		return unless active
		super()
	end
	#--------------------------------------------------------------------------
	# * Item Rect
	#--------------------------------------------------------------------------
	def item_rect(index)
		Rect.new(@x + (@width / @data.size) * index, @y, @width / @data.size, @height)
	end
	#--------------------------------------------------------------------------
	# * Draw Actor Graphic
	#--------------------------------------------------------------------------
	def draw_actor_graphic(x, y, actor, bitmap)
		char = RPG::Cache.character(actor.character_name, actor.character_hue)
		cw = char.width / 4
		ch = char.height / 4
		src_rect = Rect.new(0, 0, cw, ch)
		bitmap.blt(x - cw/2, y, char, src_rect)
	end
end