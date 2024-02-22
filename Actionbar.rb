#==============================================================================
# ** Actionbar
#------------------------------------------------------------------------------
#  This class handles and displays the actionbar.
#==============================================================================

class Actionbar
  #----------------------------------------------------------------------------
  # * Constants
  #----------------------------------------------------------------------------
  Switch_ID = 143
  #----------------------------------------------------------------------------
  # * Object Initialization
  #----------------------------------------------------------------------------
  def initialize
    # Setup hotkeys (security)
    $game_system.setup_hotkeys
    # Set visible state
    @visible = $game_switches[Switch_ID]
    # Set keys
    @keys = [Keys::N1, Keys::N2, Keys::N3, Keys::N4, Keys::Q, Keys::E]
    @key_strings = ["1","2","3","4","Q","E"]
    # Set cooldowns
    @cooldowns = [0,0,0,0,0,0]
    # Set rendered flag
    @rendered = false
    # Set hotkeys
    @hotkeys = $game_system.hotkeys
    # Set index map
    @index_map = []
    for key in @keys
      @index_map << @hotkeys[key]
    end
    # Create cooldown skins
    @cd_skins = []
    for i in 0...6
      skin = Sprite.new
      skin.bitmap = Bitmap.new(32,32)
      skin.x = 218 + (i * 34)
      skin.y = 427 - 38
      skin.z = 9999
      skin.visible = @visible
      @cd_skins << skin
    end
    # Create hotkey skins
    @key_skins = []
    for i in 0...6
      skin = Sprite.new
      skin.bitmap = Bitmap.new(32,32)
      skin.x = 218 + (i * 34)
      skin.y = 427 - 50
      skin.z = 9999
      skin.visible = @visible
      @key_skins << skin
    end
    # Create slots
    @slots = []
    for i in 0...6
      slot = Sprite.new
      slot.bitmap = RPG::Cache.gui("Slot")
      slot.x = 218 + (i * 34)
      slot.y = 427 - 38
      slot.z = 9000
      slot.visible = @visible
      @slots << slot
    end
    # Create icons
    @icons = [] ; i = 0
    for key in @keys
      icon = Sprite.new
      unless @hotkeys[key].nil?
        icon.bitmap = RPG::Cache.icon($data_skills[@hotkeys[key]].icon_name)
      end
      icon.x = 222 + (i * 34)
      icon.y = 427 - 34
      icon.z = 9500
      icon.visible = @visible
      @icons << icon
      i += 1
    end
    # Render
    self.render
  end
  #----------------------------------------------------------------------------
  # * Render
  #----------------------------------------------------------------------------
  def render
    # If hotkeys don't match: re-render
    if @hotkeys != $game_system.hotkeys
      # Set new hotkeys
      @hotkeys = $game_system.hotkeys
      # Setup index map
      @index_map.clear
      for key in @keys
        @index_map << @hotkeys[key]
      end
      # Refresh all icons
      i = 0
      for key in @binds
        @icons[i].dispose unless @icons[i].bitmap.nil?
        @icons[i].bitmap = RPG::Cache.icon($data_skills[@hotkeys[key]].icon_name)
        i += 1
      end
    end
    # For each key: check if cd has changed
    for i in 0...6
      if @cooldowns[i] != $game_system.cooldowns.get(@index_map[i])
        @cooldowns[i] = $game_system.cooldowns.get(@index_map[i])
        @cd_skins[i].bitmap.clear
        if @cooldowns[i] > 0
          @cd_skins[i].bitmap.font.color = Color.new(100, 230, 255, 255)
          @cd_skins[i].bitmap.draw_text(0,8,32,32,@cooldowns[i].to_s,1)
        end
      end
      # If no actor: always active
      if $game_party.actors.size > 0
        # Get the skill data
        skill = $data_skills[@index_map[i]] unless @index_map[i].nil?
        # Next if nil
        next if skill.nil?
        # Check for required opacity level
        opacity = 255
        if skill.element_set.include?(45)
          if $game_system.action_meter < skill.sp_cost
            opacity = 160
          end
        elsif $game_party.actors[0].sp < skill.sp_cost
          opacity = 160
        elsif @cooldowns[i] > 0
          opacity = 160
        end
        # Set opacity
        @icons[i].opacity = opacity
      end
    end
    # Unless rendered: make premanent changes
    unless @rendered
      for i in 0...@key_strings.size
        @key_skins[i].bitmap.draw_text(0,0,32,32,@key_strings[i],2)
      end
    end
    # Set rendered flag
    @rendered = true
  end
  #----------------------------------------------------------------------------
  # * Update
  #----------------------------------------------------------------------------
  def update
    # Set visible state
    self.visible = $game_switches[Switch_ID]
    # Render
    self.render
  end
  #----------------------------------------------------------------------------
  # * Visible=
  #----------------------------------------------------------------------------
  def visible=(bool)
    # Set visible state
    @visible = bool
    # Set everything to the new state
    @cd_skins.each {|skin| skin.visible = @visible}
    @key_skins.each {|skin| skin.visible = @visible}
    @slots.each {|skin| skin.visible = @visible}
    @icons.each {|skin| skin.visible = @visible}
  end
  #----------------------------------------------------------------------------
  # * Dispose
  #----------------------------------------------------------------------------
  def dispose
    # Set everything to the new state
    @cd_skins.each {|skin| skin.dispose}
    @key_skins.each {|skin| skin.dispose}
    @slots.each {|skin| skin.dispose}
    @icons.each {|skin| skin.dispose}
  end
end