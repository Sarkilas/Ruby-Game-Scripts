#==============================================================================
# ** Scene_Title
#------------------------------------------------------------------------------
#  This class performs title screen processing.
#==============================================================================

class Scene_Title
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    # Load game data if existant
    if FileTest.exist?("GameData.rxdata")
      # Load data
      $game_data = load_data("GameData.rxdata")
    else
      # Create new game data object
      $game_data = GameData.new
      # Open file
      file = File.open("GameData.rxdata", "wb")
      # Dump object to file
      Marshal.dump($game_data, file)
      # Close file
      file.close
    end
    # Load database
    $data_actors        = load_data("Data/Actors.rxdata")
    $data_classes       = load_data("Data/Classes.rxdata")
    $data_skills        = load_data("Data/Skills.rxdata")
    $data_items         = load_data("Data/Items.rxdata")
    $data_weapons       = load_data("Data/Weapons.rxdata")
    $data_armors        = load_data("Data/Armors.rxdata")
    $data_enemies       = load_data("Data/Enemies.rxdata")
    $data_troops        = load_data("Data/Troops.rxdata")
    $data_states        = load_data("Data/States.rxdata")
    $data_animations    = load_data("Data/Animations.rxdata")
    $data_tilesets      = load_data("Data/Tilesets.rxdata")
    $data_common_events = load_data("Data/CommonEvents.rxdata")
    $data_system        = load_data("Data/System.rxdata")
    # Make system object
    $game_system = Game_System.new
    # If battle test
    if $BTEST
      battle_test
      return
    end
    # Set index
    @index = -1
    @fading = false
    @active = false
    # Make title graphic
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.title($data_system.title_name)
    # Make title text graphic
    @text = Sprite.new
    @text.bitmap = RPG::Cache.title("GameTitle")
    # Make copy window
    @copy_window = Interface::Dialog.new(240, 96, 
      "There are no empty files. Please erase one to copy.", "OK")
    @copy_window.bind(0, Proc.new {
      Graphics.freeze
      @copy_window.opacity = 0
      @copy_window.visible = false
      Graphics.transition
    })
    # Set up button array
    @buttons = []
    # Create all buttons
    play = Interface::Button.new(162, 312, 100, "Play")
    play.bind(Proc.new {command_play})
    play.opacity = 0
    play.visible = false
    @buttons << play
    copy = Interface::Button.new(270, 312, 100, "Copy")
    copy.bind(Proc.new {command_copy})
    copy.opacity = 0
    copy.visible = false
    @buttons << copy
    erase = Interface::Button.new(378, 312, 100, "Erase")
    erase.bind(Proc.new {command_erase})
    erase.opacity = 0
    erase.visible = false
    @buttons << erase
    mgames = Interface::Button.new(270, 364, 100, "Mini Games")
    mgames.bind(Proc.new {
      command_mini_games if $game_data.mini_games.size > 0
      })
    @buttons << mgames
    exit = Interface::Button.new(270, 416, 100, "Exit")
    exit.bind(Proc.new {command_shutdown})
    @buttons << exit
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
      window.x = i * 160
      @file_windows << window
    end
    # Make file sprites
    @file_sprites = []
    for i in 0..3
      sprite = Interface::Container.new(12 + @file_windows[i].x, 92 + @file_windows[i].y, 
        @file_windows[i].width - 24, @file_windows[i].height - 24, nil, true)
      @file_sprites << sprite
      @file_windows[i].y = @file_sprites[i].y - 12
    end
    # Make mouse visible
    Mouse.show_cursor(true)
    # Play title BGM
    $game_system.bgm_play($data_system.title_bgm)
    # Stop playing ME and BGS
    Audio.me_stop
    Audio.bgs_stop
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepare for transition
    Graphics.freeze
    # Dispose of title graphic
    @sprite.bitmap.dispose
    @sprite.dispose
    @text.bitmap.dispose
    @text.dispose
    # Dispose copy window
    @copy_window.dispose
    # Dispose sprites and windows
    @file_sprites.each {|sprite| sprite.dispose}
    @file_windows.each {|window| window.dispose}
    @buttons.each {|button| button.dispose}
  end
  #--------------------------------------------------------------------------
  # * Redraw Files
  #--------------------------------------------------------------------------
  def redraw_files
    # Dispose all files
    @file_windows.each {|window| window.dispose}
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
        # Set window y if index match
        window.y = 65 if i == @index
      else
        window = Window_File.new(i+1)
      end
      window.x = i * 160
      @file_windows << window
    end
    # Set all positions
    for i in 0..3
      @file_sprites[i].y = @file_windows[i].y + 92
      @file_windows[i].y = @file_sprites[i].y - 12
    end
  end
  #--------------------------------------------------------------------------
  # * Mouse In Bounds?
  #--------------------------------------------------------------------------
  def in_bounds?(object)
    if object.is_a?(Sprite)
      width = object.bitmap.width
      height = object.bitmap.height
    elsif object.is_a?(Window)
      width = object.width
      height = object.height
    end
    x = Mouse.x ; y = Mouse.y
    if x >= object.x and x <= object.x + width and
      y >= object.y and y <= object.y + height
      return true
    else
      return false
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # Update all buttons
    unless @copy_window.visible
      @buttons.each {|button| button.update}
      @file_sprites.each {|sprite| sprite.update} 
    end
    @copy_window.update
    # Update dialogs if fading
    if @copy_window.visible and @copy_window.opacity < 255
      @copy_window.fade_in
    end
    # If index is active: update files
    update_files if @index >= 0
    update_fading if @fading
    # If left click: check for bounds
    if Input.trigger?(Keys::MOUSE_LEFT)
      # File windows
      for i in 0..3
        if in_bounds?(@file_sprites[i].bounds)
          # Play SE
          $game_system.se_play($data_system.load_se)
          # If index is -1: start fading buttons
          @fading = true if @index == -1
          # Set index
          @index = i
          return
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Fading Update
  #--------------------------------------------------------------------------
  def update_fading
    # Make sure all are visible
    @buttons[0].visible = true
    @buttons[1].visible = true
    @buttons[2].visible = true
    # Fade in
    @buttons[0].fade_in
    @buttons[1].fade_in
    @buttons[2].fade_in
    # Set variable if fully opaque
    if @buttons[0].opacity >= 255
      @active = true
      @fading = false
    end
  end
  #--------------------------------------------------------------------------
  # * Files Update
  #--------------------------------------------------------------------------
  def update_files
    # Check all file windowsets
    for i in 0..3
      if @index == i and @file_sprites[i].y < 157
        @file_sprites[i].y += 3
        if @file_sprites[i].y > 157
          @file_sprites[i].y = 157
        end
      elsif @index != i and @file_sprites[i].y > 92
        @file_sprites[i].y -= 3
        if @file_sprites[i].y < 92
          @file_sprites[i].y = 92
        end
      end
      @file_windows[i].y = @file_sprites[i].y - 12
    end
  end
  #--------------------------------------------------------------------------
  # * Command: Copy
  #--------------------------------------------------------------------------
  def command_copy
    # If file doesn't exist: play buzzer and return
    unless @files[@index]
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # Check all files
    copied = false
    for i in 0...4
      next if i == @index
      unless FileTest.exist?("Stories/Save#{i+1}.rxdata")
        FileUtils.copy_file "Stories/Save#{@index+1}.rxdata","Stories/Save#{i+1}.rxdata"
        copied = true
        break
      end
    end
    # Play SE
    $game_system.se_play($data_system.load_se)
    # Show copy window if not copied
    @copy_window.visible = !copied
    # Redraw files if copied
    redraw_files if copied
  end
  #--------------------------------------------------------------------------
  # * Command: Erase
  #--------------------------------------------------------------------------
  def command_erase
    # If file doesn't exist: play buzzer and return
    unless @files[@index]
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # Play SE
    Audio.se_play("Audio/SE/Quest Fail")
    # Prepare for transition
    Graphics.freeze
    # Delete file
    File.delete("Stories/Save#{@index+1}.rxdata")
    # Set index
    @index = -1
    # Redraw files
    redraw_files
    # Set all buttons to hidden
    @buttons[0].opacity = 0
    @buttons[1].opacity = 0
    @buttons[2].opacity = 0
    @buttons[0].visible = false
    @buttons[1].visible = false
    @buttons[2].visible = false
    # Set active
    @active = false
    # Transit
    Graphics.transition
  end
  #--------------------------------------------------------------------------
  # * Command: Play
  #--------------------------------------------------------------------------
  def command_play
    # Play sound
    $game_system.se_play($data_system.save_se)
    # If file doesn't exist: create it and start a new game
    unless @files[@index]
      command_new_game
      return
    end
    # Load file
    file = File.open("Stories/Save#{@index+1}.rxdata", "rb")
    # Load contents
    # Read character data for drawing save file
    characters = Marshal.load(file)
    # Read frame count for measuring play time
    Graphics.frame_count = Marshal.load(file)
    # Read each type of game object
    $game_system        = Marshal.load(file)
    $game_switches      = Marshal.load(file)
    $game_variables     = Marshal.load(file)
    $game_self_switches = Marshal.load(file)
    $game_screen        = Marshal.load(file)
    $game_actors        = Marshal.load(file)
    $game_party         = Marshal.load(file)
    $game_troop         = Marshal.load(file)
    $game_map           = Marshal.load(file)
    $game_player        = Marshal.load(file)
    # Set new filename (in case it changed through copying)
    $game_system.file = "Stories/Save#{@index+1}.rxdata"
    # If magic number is different from when saving
    # (if editing was added with editor)
    if $game_system.magic_number != $data_system.magic_number
      # Load map
      $game_map.setup($game_map.map_id)
      $game_player.center($game_player.x, $game_player.y)
    end
    # Refresh party members
    $game_party.refresh
    # Restore BGM and BGS
    $game_system.bgm_play($game_system.playing_bgm)
    $game_system.bgs_play($game_system.playing_bgs)
    # Create temp
    $game_temp = Game_Temp.new
    $game_switches[1] = false
    # Update map (run parallel process event)
    $game_map.update
    # Erase save picture
    $game_screen.pictures[50].erase
    # Send the player to the map
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # * Command: New Game
  #--------------------------------------------------------------------------
  def command_new_game
    # Make each type of game object
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    # Stop BGM
    Audio.bgm_stop
    # Reset frame count for measuring play time
    Graphics.frame_count = 0
    # Set up initial party
    $game_party.setup_starting_members
    # Set up initial map position
    $game_map.setup($data_system.start_map_id)
    # Move player to initial position
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    # Refresh player
    $game_player.refresh
    # Run automatic change for BGM and BGS set with map
    $game_map.autoplay
    # Update map (run parallel process event)
    $game_map.update
    # Set file name
    $game_system.file = "Stories/Save#{@index+1}.rxdata"
    # Autosave
    $game_system.autosave
    # Switch to map screen
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # * Command: Mini Games
  #--------------------------------------------------------------------------
  def command_mini_games
    print "In development."
  end
  #--------------------------------------------------------------------------
  # * Command: Shutdown
  #--------------------------------------------------------------------------
  def command_shutdown
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    # Fade out BGM, BGS, and ME
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # Shutdown
    $scene = nil
  end
end