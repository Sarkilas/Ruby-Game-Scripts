#==============================================================================
# ** Scene_Achievements
#------------------------------------------------------------------------------
#  This class performs achievements screen processing.
#==============================================================================

class Scene_Achievements
  #----------------------------------------------------------------------------
  # * Main
  #----------------------------------------------------------------------------
  def main
    # If game has been saved: draw map
    if $game_system.save_count > 0
      # Make map
      @map = Spriteset_Map.new
      # Lightmap sprite
      @light = Sprite.new
      @light.bitmap = RPG::Cache.gui("Light/Default")
      @light.z = 10
      @light.visible = $game_switches[43]
      if @light.visible
        @light.x = $game_player.screen_x - @light.bitmap.width / 2
        @light.y = $game_player.screen_y - @light.bitmap.height / 2
      end
    else
      # Make title graphic
      @sprite = Sprite.new
      @sprite.bitmap = RPG::Cache.title($data_system.title_name)
      # Make quit button
      @quit = []
      btn = Sprite.new
      btn.bitmap = RPG::Cache.gui("Title/Exit")
      btn.x = 320 - btn.bitmap.width / 2
      btn.y = 416
      @quit << btn
      btn = Sprite.new
      btn.bitmap = RPG::Cache.gui("Title/Exit Highlight")
      btn.x = 320 - btn.bitmap.width / 2
      btn.y = 416
      btn.visible = false
      @quit << btn
      # Make mini games button
      @minigames = []
      btn = Sprite.new
      btn.bitmap = RPG::Cache.gui("Title/Mini Games")
      btn.x = 216
      btn.y = 364
      @minigames << btn
      btn = Sprite.new
      btn.bitmap = RPG::Cache.gui("Title/Mini Games Highlight")
      btn.x = 216
      btn.y = 364
      btn.visible = false
      @minigames << btn
      # Make achievements button
      @achievement = []
      btn = Sprite.new
      btn.bitmap = RPG::Cache.gui("Map/Achievements")
      btn.x = 324
      btn.y = 364
      @achievement << btn
      btn = Sprite.new
      btn.bitmap = RPG::Cache.gui("Map/Achievements Highlight")
      btn.x = 324
      btn.y = 364
      btn.visible = false
      @achievement << btn
      # Make play button
      @play = []
      btn = Sprite.new
      btn.bitmap = RPG::Cache.gui("Title/Play")
      btn.x = 162
      btn.y = 312
      btn.opacity = 0
      @play << btn
      btn = Sprite.new
      btn.bitmap = RPG::Cache.gui("Title/Play Highlight")
      btn.x = 162
      btn.y = 312
      btn.visible = false
      @play << btn
      # Make copy button
      @copy = []
      btn = Sprite.new
      btn.bitmap = RPG::Cache.gui("Title/Copy")
      btn.x = 270
      btn.y = 312
      btn.opacity = 0
      @copy << btn
      btn = Sprite.new
      btn.bitmap = RPG::Cache.gui("Title/Copy Highlight")
      btn.x = 270
      btn.y = 312
      btn.visible = false
      @copy << btn
      # Make erase button
      @erase = []
      btn = Sprite.new
      btn.bitmap = RPG::Cache.gui("Title/Erase")
      btn.x = 378
      btn.y = 312
      btn.opacity = 0
      @erase << btn
      btn = Sprite.new
      btn.bitmap = RPG::Cache.gui("Title/Erase Highlight")
      btn.x = 378
      btn.y = 312
      btn.visible = false
      @erase << btn
      # Make file sprites
      @file_sprites = []
      for i in 0..3
        sprite = Sprite.new
        sprite.bitmap = RPG::Cache.gui("Parchment")
        sprite.x = i * 160
        @file_sprites << sprite
      end
      # File window contents
      @files = [false,false,false,false]
      @file_windows = []
      for i in 0..3
        if FileTest.exist?("Stories/Save#{i+1}.rxdata")
          # Do file operations
          file = File.open("Stories/Save#{i+1}.rxdata", "r")
          time_stamp = file.mtime
          characters = Marshal.load(file)
          frame_count = Marshal.load(file)
          system = Marshal.load(file)
          game_switches = Marshal.load(file)
          game_variables = Marshal.load(file)
          total_sec = frame_count / Graphics.frame_rate
          file.close
          hour = total_sec / 60 / 60
          min = total_sec / 60 % 60
          sec = total_sec % 60
          time_string = sprintf("%02d:%02d:%02d", hour, min, sec)
          # Create window
          window = Window_File.new(i+1, system.tag, time_string, time_stamp)
          @files[i] = true
        else
          window = Window_File.new(i+1)
        end
        window.x = @file_sprites[i].x
        @file_windows << window
      end
    end
    # Make categories
    @categories = Window_AchievementCategories.new
    # Make achievements
    @achievements = Window_AchievementList.new
    # Make info windows
    @infos = {}
    GameData::Achievements.each_key do |key|
      @infos[key] = Window_Achievement.new(key)
    end
    # Add empty window
    @infos['empty'] = Window_Achievement.new("")
    @infos['empty'].visible = true
    # Make help windows
    @help = []
    ["General","Combat","Lore","Boss","Mini Game","Special"].each do |key|
      window = Window_Help.new
      window.opacity = 0
      window.x = @categories.x + @categories.width - window.width
      window.y = @categories.y
      window.z = 10500
      window.set_text(key, 2)
      window.visible = false
      @help << window
    end
    # Add achievement points help window
    window = Window_Help.new
    window.opacity = 0
    window.x = @categories.x + @categories.width - window.width
    window.y = @categories.y
    window.z = 10500
    window.set_text("#{$game_data.achievement_points} Points", 2)
    window.visible = true
    @help << window
    # Transition
    Graphics.transition
    # Make mouse visible
    Mouse.show_cursor(true)
    # Main loop
    while $scene == self
      # Update mouse, graphics and input
      Input.update
      Graphics.update
      # Update scene
      update
    end
    # Prepare for transition
    Graphics.freeze
    # Dispose
    if $game_system.save_count > 0
      @map.dispose
      @light.dispose
    end
    # Dispose core sprites
    @categories.dispose
    @achievements.dispose
    @infos.keys.each {|key| @infos[key].dispose}
    @help.each {|window| window.dispose}
    # Dispose title
    if $game_system.save_count == 0
      # Dispose of title graphic
      @sprite.bitmap.dispose
      @sprite.dispose
      # Dispose sprites and windows
      @file_sprites.each {|sprite| sprite.dispose}
      @file_windows.each {|window| window.dispose}
      @quit.each {|sprite| sprite.dispose}
      @play.each {|sprite| sprite.dispose}
      @copy.each {|sprite| sprite.dispose}
      @erase.each {|sprite| sprite.dispose}
      @minigames.each {|sprite| sprite.dispose}
      @achievement.each {|sprite| sprite.dispose}
    end
  end
  #----------------------------------------------------------------------------
  # * Update
  #----------------------------------------------------------------------------
  def update
    # If escape or right-click: return to map
    if Input.trigger?(Keys::ESC) or Input.trigger?(Keys::MOUSE_RIGHT)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Return to map
      if $game_system.save_count > 0
        $scene = Scene_Map.new
      else
        $scene = Scene_Title.new
      end
      return
    end
    # Update menus
    @categories.update
    @achievements.update
    # Make all information windows hidden
    @infos.keys.each {|key| @infos[key].refresh}
    @infos.keys.each {|key| @infos[key].visible = false}
    # Make all help windows hidden
    @help.each {|window| window.visible = false}
    @help[@categories.index].visible = true if @categories.index >= 0
    @help[@help.size - 1].visible = true unless @categories.index >= 0
    # Make active achievement info visible
    if @achievements.id.nil?
      @infos['empty'].visible = true
    else
      @infos[@achievements.id].visible = true
    end
    # If in bounds of categories and index is 0 or above
    if Mouse.in_bounds?(@categories) and @categories.index >= 0 and
      Input.trigger?(Keys::MOUSE_LEFT)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Set new category
      @achievements.set_category(@categories.index)
      @categories.set_category(@categories.index)
      return
    end
  end
end
