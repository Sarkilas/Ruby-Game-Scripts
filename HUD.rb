#==============================================================================
# ** HUD
#------------------------------------------------------------------------------
#  This class handles and displays the HUD.
#==============================================================================

class HUD
  #----------------------------------------------------------------------------
  # * Constants
  #----------------------------------------------------------------------------
  Switch_ID = 143 ; Out = 0 ; In = 1
  #----------------------------------------------------------------------------
  # * Object Initialization
  #----------------------------------------------------------------------------
  def initialize
    # Set flags
    @visible = $game_switches[Switch_ID]
    @combo = $game_temp.combo_hit
    @combo_index = (@combo - (@combo % 10))/10
    @warn_fade = Out
    @special_proc = false
    @combo_log = []
    # Create bar containers
    @containers = []
    for i in 0...3
      # Make container sprite
      sprite = Sprite.new
      sprite.bitmap = RPG::Cache.gui("Container")
      sprite.x = 320 - sprite.bitmap.width / 2
      sprite.y = 427 + 17 * i
      sprite.z = 9500
      sprite.visible = @visible
      # Add to container array
      @containers << sprite
    end
    # Create weapon slots
    @main_slot = Sprite.new
    @main_slot.bitmap = RPG::Cache.gui("Slot")
    @main_slot.x = @containers[0].x - 36
    @main_slot.y = 427 + 25 - @main_slot.bitmap.height / 2
    @main_slot.z = 9000
    @off_slot = Sprite.new
    @off_slot.bitmap = RPG::Cache.gui("Slot")
    @off_slot.x = @containers[0].x + @containers[0].bitmap.width + 4
    @off_slot.y = 427 + 25 - @off_slot.bitmap.height / 2
    @off_slot.z = 9000
    # Create weapon icons
    @main_icon = Sprite.new
    @main_icon.z = 9999
    @mainhand = $game_party.hands[0]
    if $game_party.hands[0] != nil
      @main_icon.bitmap = RPG::Cache.icon(
        $data_weapons[$game_party.hands[0]].icon_name)
      @main_icon.x = @main_slot.x + 16 - @main_icon.bitmap.width / 2
      @main_icon.y = @main_slot.y + 16 - @main_icon.bitmap.height / 2
    end
    @off_icon = Sprite.new
    @off_icon.z = 9999
    @offhand = $game_party.hands[1]
    if $game_party.hands[1] != nil
      @off_icon.bitmap = RPG::Cache.icon(
        $data_weapons[$game_party.hands[1]].icon_name)
      @off_icon.x = @off_slot.x + 16 - @off_icon.bitmap.width / 2
      @off_icon.y = @off_slot.y + 16 - @off_icon.bitmap.height / 2
    end
    # Create health bar
    @health_bar = Sprite.new
    @health_bar.bitmap = RPG::Cache.gui("Health Bar")
    @health_bar.x = 320 - @health_bar.bitmap.width / 2
    @health_bar.y = 427
    @health_bar.z = 9999
    @health_bar.visible = @visible
    # Create crisis bar
    @crisis_bar = Sprite.new
    @crisis_bar.bitmap = RPG::Cache.gui("Crisis Bar")
    @crisis_bar.x = 320 - @crisis_bar.bitmap.width / 2
    @crisis_bar.y = 427
    @crisis_bar.z = 9999
    @crisis_bar.visible = false
    # Create mind bar
    @mind_bar = Sprite.new
    @mind_bar.bitmap = RPG::Cache.gui("Mind Bar")
    @mind_bar.x = 320 - @mind_bar.bitmap.width / 2
    @mind_bar.y = 444
    @mind_bar.z = 9999
    @mind_bar.visible = @visible
    # Create energy bar
    @energy_bar = Sprite.new
    @energy_bar.bitmap = RPG::Cache.gui("Energy Bar")
    @energy_bar.x = 320 - @energy_bar.bitmap.width / 2
    @energy_bar.y = 461
    @energy_bar.z = 9999
    @energy_bar.visible = @visible
    # Create charge meter
    @charge_meter = Sprite.new
    @charge_meter.bitmap = RPG::Cache.gui("Charger")
    @charge_meter.y = 382 - @charge_meter.bitmap.height
    @charge_meter.z = 9500
    @charge_meter.visible = @visible
    # Create charge arrow
    @charge_arrow = Sprite.new
    @charge_arrow.bitmap = RPG::Cache.gui("Arrow")
    @charge_arrow.x = 20
    @charge_arrow.y = (@charge_meter.y + @charge_meter.bitmap.height) - 6
    @charge_arrow.z = 9999
    @charge_arrow.visible = @visible
    # Special attack text
    @special = Sprite.new
    @special.bitmap = RPG::Cache.gui("Special")
    @special.x = 96
    @special.y = @charge_meter.y - 8 - @special.bitmap.height
    @special.z = 9999
    @special.visible = false
    # Health indicators (full screen)
    @health_warnings = []
    @health_warnings << Sprite.new
    @health_warnings[0].bitmap = RPG::Cache.gui("Low Health")
    @health_warnings[0].z = 9000
    @health_warnings[0].visible = false
    @health_warnings << Sprite.new
    @health_warnings[1].bitmap = RPG::Cache.gui("Dire Health")
    @health_warnings[1].z = 9000
    @health_warnings[1].visible = false
    # Create burst sprites
    @burst_sprites = []
    for i in 0...5
      sprite = Sprite.new
      sprite.bitmap = RPG::Cache.gui("Burst Sprite")
      sprite.x = 80 + (32 * i)
      sprite.y = 427 - 32
      sprite.z = 9999
      sprite.visible = false
      @burst_sprites << sprite
    end
    # Add filled sprite
    sprite = Sprite.new
    sprite.bitmap = RPG::Cache.gui("Burst Sprite Full")
    sprite.x = 80
    sprite.y = 427 - 32
    sprite.z = 9999
    sprite.visible = false 
    @burst_sprites << sprite
    # Create combo sprites
    @combo_sprites = []
    for i in 1..8
      sprite = Sprite.new
      sprite.bitmap = RPG::Cache.gui("Combo Text #{i}")
      sprite.x = 196
      sprite.y = @special.y - sprite.bitmap.height + 8
      sprite.z = 9999
      sprite.opacity = 0
      @combo_sprites << sprite
    end
    # Set extra flags
    @combo_text_flag = nil
    @fade_in = true
    # Do a pre-screen render
    self.render
  end
  #----------------------------------------------------------------------------
  # * Render
  #----------------------------------------------------------------------------
  def render
    # Return if not visible
    return unless @visible
    # Return if battler is nil
    if $game_party.actors.size == 0
      @health_warnings.each {|sprite| sprite.visible = false}
      return
    end
    # Check for weapon icon changes
    if @mainhand != $game_party.hands[0]
      if $game_party.hands[0] != nil
        @main_icon.bitmap = RPG::Cache.icon(
          $data_weapons[$game_party.hands[0]].icon_name)
        @main_icon.x = @main_slot.x + 16 - @main_icon.bitmap.width / 2
        @main_icon.y = @main_slot.y + 16 - @main_icon.bitmap.height / 2
      end
      @mainhand = $game_party.hands[0]
    end
    if @offhand != $game_party.hands[1]
      if $game_party.hands[1] != nil
        @off_icon.bitmap = RPG::Cache.icon(
          $data_weapons[$game_party.hands[1]].icon_name)
        @off_icon.x = @off_slot.x + 16 - @off_icon.bitmap.width / 2
        @off_icon.y = @off_slot.y + 16 - @off_icon.bitmap.height / 2
      end
      @offhand = $game_party.hands[1]
    end
    @main_icon.visible = !@mainhand.nil?
    @off_icon.visible = !@offhand.nil?
    # Get actor for references
    actor = $game_party.actors[0]
    # Fix HP values
    if actor.hp > actor.maxhp
      actor.hp = actor.maxhp
    end
    # Get health percentage
    hp_perc = actor.hp.to_f / actor.maxhp.to_f
    # Check which bar to show, then zoom it on the X-axis
    if hp_perc <= 0.30
      # Fix bars
      @crisis_bar.visible = true
      @health_bar.visible = false
      if @crisis_bar.zoom_x != hp_perc
        $game_temp.update_burst(true)
      end
      @crisis_bar.zoom_x = hp_perc
      # Update health indicators
      if $game_system.health_warning
        if hp_perc <= 0.15
          @health_warnings[1].visible = true
          @health_warnings[0].visible = false
        else
          @health_warnings[0].visible = true
          @health_warnings[1].visible = false
        end
      else
        @health_warnings.each {|sprite| sprite.visible = false}
      end
    else
      # Fix bars
      @crisis_bar.visible = false
      @health_bar.visible = true
      if @health_bar.zoom_x != hp_perc
        $game_temp.update_burst(true)
      end
      @health_bar.zoom_x = hp_perc
      @health_warnings.each {|sprite| sprite.visible = false}
    end
    # Set all burst sprites to hidden
    @burst_sprites.each {|sprite| sprite.visible = false}
    # Update burst sprites
    if $game_temp.burst > 0
      for i in 0...$game_temp.burst
        @burst_sprites[i].visible = true
      end
    end
    if $game_temp.burst == 5
      @burst_sprites[5].visible = true
    end
    # Set mind bar zoom x
    sp_perc = actor.sp.to_f / actor.maxsp.to_f
    @mind_bar.zoom_x = sp_perc
    # Set energy bar zoom x
    energy_perc = $game_system.action_meter.to_f / 100
    @energy_bar.zoom_x = energy_perc
  end
  #----------------------------------------------------------------------------
  # * Update
  #----------------------------------------------------------------------------
  def update
    # Return if not visible
    return unless @visible
    # Update burst
    if @combo > 0
      $game_temp.update_burst(true)
    else
      $game_temp.update_burst
    end
    # Render the HUD
    self.render
    # Update health warnings
    update_warnings if $game_system.health_warning
    # Update charge meter
    update_charge_meter
    # Update combo text
    update_combo_text
    # Update special
    update_special if @special_proc
  end
  #----------------------------------------------------------------------------
  # * Update Combo Text
  #----------------------------------------------------------------------------
  def update_combo_text
    # Set combo flag
    if @combo / 5 > 0 and @combo / 5 < 8
      @combo_text_flag = (@combo / 5) - 1
    elsif @combo / 5 >= 8
      @combo_text_flag = 7
    else
      @combo_text_flag = nil
    end
    # If combo flag is not nil: update combo text core
    unless @combo_text_flag.nil?
      # If fade in
      if @fade_in
        @combo_sprites[@combo_text_flag].opacity += 50
        if @combo_sprites[@combo_text_flag].opacity >= 255
          @combo_sprites[@combo_text_flag].opacity = 255
          @fade_in = false
        end
      else
        @combo_sprites[@combo_text_flag].opacity -= 50
        if @combo_sprites[@combo_text_flag].opacity <= 100
          @fade_in = true
        end
      end
      # Movement
      if @combo_sprites[@combo_text_flag].x > 150
        @combo_sprites[@combo_text_flag].x -= 5
      end
    end
    # Make sure all inactive texts are faded out
    for i in 0...@combo_sprites.size
      next if i == @combo_text_flag
      if @combo_sprites[i].opacity > 0
        @combo_sprites[i].opacity -= 25
        if @combo_sprites[i].x > 120
          @combo_sprites[i].x -= 5
        end
      else
        @combo_sprites[i].opacity = 0
        @combo_sprites[i].x = 196
      end
    end
  end
  #----------------------------------------------------------------------------
  # * Update Charge Meter
  #----------------------------------------------------------------------------
  def update_charge_meter
    # Check if combo has changed
    if @combo != $game_temp.combo_hit
      # Set new combo
      @combo = $game_temp.combo_hit
      # Set combo index
      @combo_index = (@combo - (@combo % 10))/10
      # If index is 0: proc special
      if @combo_index >= 1 and @combo > 0 and 
        !@combo_log.include?(@combo - (@combo % 10))
        @special.visible = true
        @special_proc = true
        $game_temp.add_burst
        @combo_log.push(@combo - (@combo % 10))
      end
    end
    # Move arrow accordingly
    if @charge_arrow.y > (@charge_meter.y + 
        @charge_meter.bitmap.height) - (@combo_index * 15)
      @charge_arrow.y -= 5
    elsif @combo == 0
      @combo_log.clear
      @charge_arrow.y += 5
    end
    # If arrow is out of bounds: snap it
    if @charge_arrow.y < (@charge_meter.y + 4)
      @charge_arrow.y = (@charge_meter.y + 4)
    elsif @charge_arrow.y > (@charge_meter.y + @charge_meter.bitmap.height) - 6
      @charge_arrow.y = (@charge_meter.y + @charge_meter.bitmap.height) - 6
    end
  end
  #----------------------------------------------------------------------------
  # * Update Special
  #----------------------------------------------------------------------------
  def update_special
    # Reduce opacity and move to the left
    @special.opacity -= 3
    @special.x -= 10 unless @special.x <= 0
    # If opacity is 0: reset
    if @special.opacity <= 0
      @special.visible = false
      @special.opacity = 255
      @special.x = 96
      @special_proc = false
    end
  end
  #----------------------------------------------------------------------------
  # * Update Health Warnings
  #----------------------------------------------------------------------------
  def update_warnings
    # Find what index to update
    if @health_warnings[0].visible
      index = 0
    elsif @health_warnings[1].visible
      index = 1
    end
    # Return if index is nil
    return if index.nil?
    # Update
    case @warn_fade
    when Out
      @health_warnings[index].opacity -= 5
      if @health_warnings[index].opacity <= 0
        @warn_fade = In
        @health_warnings[index].opacity = 0
      end
    when In
      @health_warnings[index].opacity += 5
      if @health_warnings[index].opacity >= 255
        @warn_fade = Out
        @health_warnings[index].opacity = 255
      end
    end
  end
  #----------------------------------------------------------------------------
  # * Dispose
  #----------------------------------------------------------------------------
  def dispose
    # Dispose containers
    @containers.each {|sprite| sprite.dispose}
    # Dispose bars
    @health_bar.dispose
    @mind_bar.dispose
    @energy_bar.dispose
    @crisis_bar.dispose
    # Dispose equipment sprites
    @main_slot.dispose
    @off_slot.dispose
    @main_icon.dispose
    @off_icon.dispose
    # Dispose charge meter and arrow
    @charge_meter.dispose
    @charge_arrow.dispose
    # Dispose special text
    @special.dispose
    # Dispose health indicators
    @health_warnings.each {|sprite| sprite.dispose}
    # Dispose combo sprites
    @combo_sprites.each {|sprite| sprite.dispose}
    # Dispose burst sprites
    @burst_sprites.each {|sprite| sprite.dispose}
  end
  #----------------------------------------------------------------------------
  # * Visible=
  #----------------------------------------------------------------------------
  def visible=(bool)
    # Set visible flag
    @visible = bool
    # Set visibilities
    @containers.each {|sprite| sprite.visible = @visible}
    unless @visible
      @health_bar.visible = false
      @crisis_bar.visible = false
    end
    @main_slot.visible = @visible
    @off_slot.visible = @visible
    unless @visible
      @main_icon.visible = @visible
      @off_icon.visible = @visible
    end
    @mind_bar.visible = @visible
    @energy_bar.visible = @visible
    @charge_meter.visible = @visible
    @charge_arrow.visible = @visible
    @special.visible = @visible ? @special.visible : @visible
    @burst_sprites.each {|sprite| sprite.visible = @visible}
    @health_warnings.each {|sprite| sprite.visible = @visible}
    @combo_sprites.each {|sprite| sprite.visible = @visible}
    # Pre-update render
    self.render
  end
end