#==============================================================================
# ** Interface Framework Module
#------------------------------------------------------------------------------
#  This module contains classes for creating interactable interface components.
#
# * Author: Sarkilas
#==============================================================================

module Interface
  #============================================================================
  # * Component (Base class)
  #============================================================================
  class Component
    #--------------------------------------------------------------------------
    # Configuration Constants
    #--------------------------------------------------------------------------
    BorderColor = Color.new(112, 66, 45, 225)
    #--------------------------------------------------------------------------
    # * Bind Event (Event must be a lambda or proc)
    #     If an event is bound, it will be called on click
    #--------------------------------------------------------------------------
    def bind(event)
      @event = event
    end
    #--------------------------------------------------------------------------
    # * Call
    #--------------------------------------------------------------------------
    def call(argument, &block)
      yield argument
    end
    #--------------------------------------------------------------------------
    # * Objects
    #--------------------------------------------------------------------------
    def objects
      []
    end
    #--------------------------------------------------------------------------
    # * Default Bounds (Override if necessary)
    #--------------------------------------------------------------------------
    def bounds
      self.objects[0]
    end
    #--------------------------------------------------------------------------
    # * Clickable?
    #--------------------------------------------------------------------------
    def clickable?
      !@event.nil?
    end
    #--------------------------------------------------------------------------
    # * Clicked?
    #--------------------------------------------------------------------------
    def clicked?
      (Mouse.in_bounds?(*self.bounds) and Input.trigger?(Keys::MOUSE_LEFT))
    end
    #--------------------------------------------------------------------------
    # * Update
    #--------------------------------------------------------------------------
    def update
      # If clicked and there is an event
      if self.clicked? and self.clickable?
        # Play SE
        $game_system.se_play($data_system.decision_se)
        # Call the event
        @event.call
      end
    end
    #--------------------------------------------------------------------------
    # * Draw Background
    #--------------------------------------------------------------------------
    def draw_background(bitmap, src_bitmap)
      rect = Rect.new(0, 1, @width, @height - 2)
      bitmap.stretch_blt(rect, src_bitmap, src_bitmap.rect, 200)
    end
    #--------------------------------------------------------------------------
    # * Draw Borders
    #--------------------------------------------------------------------------
    def draw_borders(bitmap, color = BorderColor)
      # Draw all borders
      bitmap.fill_rect(0, 0, @width, 1, color)
      bitmap.fill_rect(0, 1, 1, @height - 2, color)
      bitmap.fill_rect(0, @height - 1, @width, 1, color)
      bitmap.fill_rect(@width - 1, 1, 1, @height - 2, color)
    end
    #--------------------------------------------------------------------------
    # * Get X
    #--------------------------------------------------------------------------
    def x ; @x ; end
    #--------------------------------------------------------------------------
    # * Get Y
    #--------------------------------------------------------------------------
    def y ; @y ; end
    #--------------------------------------------------------------------------
    # * Set X
    #--------------------------------------------------------------------------
    def x=(value) 
      @x = value
      self.objects.each {|obj| obj.x = @x}
    end
    #--------------------------------------------------------------------------
    # * Set Y
    #--------------------------------------------------------------------------
    def y=(value) 
      @y = value
      self.objects.each {|obj| obj.y = @y}
    end
    #--------------------------------------------------------------------------
    # * Set Z
    #--------------------------------------------------------------------------
    def z=(value) 
      self.objects.each {|obj| obj.z = value}
    end
    #--------------------------------------------------------------------------
    # * Get Opacity
    #--------------------------------------------------------------------------
    def opacity
      self.objects[0].opacity
    end
    #--------------------------------------------------------------------------
    # * Set Opacity
    #--------------------------------------------------------------------------
    def opacity=(value)
      self.objects.each {|obj| obj.opacity = value}
    end
    #--------------------------------------------------------------------------
    # * Fade In
    #--------------------------------------------------------------------------
    def fade_in
      self.objects.each {|obj| obj.opacity += 20}
    end
    #--------------------------------------------------------------------------
    # * Fade Out
    #--------------------------------------------------------------------------
    def fade_out
      self.objects.each {|obj| obj.opacity -= 20}
    end
    #--------------------------------------------------------------------------
    # * Get Visible
    #--------------------------------------------------------------------------
    def visible
      @visible
    end
    #--------------------------------------------------------------------------
    # * Set visible state
    #--------------------------------------------------------------------------
    def visible=(bool)
      @visible = bool
      if @visible
        self.objects.each {|obj| obj.visible = bool if obj.is_a?(Component)}
      elsif not @visible
        self.objects.each {|obj| obj.visible = bool}
      end
    end
    #--------------------------------------------------------------------------
    # * Dispose
    #--------------------------------------------------------------------------
    def dispose
      self.objects.each {|obj| obj.dispose}
    end
  end
  #============================================================================
  # * Container
  #============================================================================
  class Container < Component
    #--------------------------------------------------------------------------
    # * Readers
    #--------------------------------------------------------------------------
    attr_reader :width
    attr_reader :height
    #--------------------------------------------------------------------------
    # * Static Bitmaps
    #--------------------------------------------------------------------------
    Background = RPG::Cache.gui("Framework/Button")
    Highlight  = RPG::Cache.gui("Framework/Button_Highlight")
    Inactive   = RPG::Cache.gui("Framework/Button_Inactive")
    #--------------------------------------------------------------------------
    # * Object Initialization
    #--------------------------------------------------------------------------
    def initialize(x, y, width, height, text = nil, active = false)
      @x = x
      @y = y
      @width = width
      @height = height
      @inactive = !active
      draw(text)
      @visible = true
    end
    #--------------------------------------------------------------------------
    # * Objects
    #--------------------------------------------------------------------------
    def objects
      [@sprite1,@sprite2]
    end
    #--------------------------------------------------------------------------
    # * Create Button Graphic
    #--------------------------------------------------------------------------
    def draw(text, border = BorderColor, inactive = Inactive, 
      background = Background, highlight = Highlight)
      # Create the sprites
      @sprite1 = RPG::Sprite.new
      @sprite2 = RPG::Sprite.new
      # First create the bitmaps
      bmp1 = Bitmap.new(@width, @height)
      bmp2 = Bitmap.new(@width, @height)
      # Draw the background
      self.draw_background(bmp1, @inactive ? inactive : background)
      self.draw_background(bmp2, highlight)   
      # Draw the borders
      self.draw_borders(bmp1, border)
      self.draw_borders(bmp2, border)
      # Draw the text
      if text
        # If text too wide: wrap text
        if bmp1.text_size(text).width > @width - 8
          # Get lines
          lines = Kernel.wrap_text(text, 33)
          # Draw all lines
          y = 0
          lines.each_line do |line|
            bmp1.draw_text(4, y * 20, @width - 8, 30, line)
            bmp2.draw_text(4, y * 20, @width - 8, 30, line)
            y += 1
          end
        else
          bmp1.draw_text(0, 0, @width, 30, text, 1)
          bmp2.draw_text(0, 0, @width, 30, text, 1)
        end
      end
      # Set the bitmaps to the sprites
      @sprite1.bitmap = bmp1
      @sprite2.bitmap = bmp2
      @sprite2.visible = false
      # Set positions
      @sprite1.x = @x
      @sprite1.y = @y
      @sprite1.z = 9999
      @sprite2.x = @x
      @sprite2.y = @y
      @sprite2.z = 9999
    end
    #--------------------------------------------------------------------------
    # * Update
    #--------------------------------------------------------------------------
    def update
      # If hidden: return
      return unless @visible
      # Update both sprites
      self.objects.each {|obj| obj.update unless obj.nil?}
      # Return if inactive
      if @inactive
        @sprite1.visible = true
        @sprite2.visible = false
        return
      end
      # Control hover
      if @control.nil?
        @sprite1.visible = !Mouse.in_bounds?(*self.bounds)
        @sprite2.visible = Mouse.in_bounds?(*self.bounds)
      end
      # Call superclass
      super
    end
  end
  #============================================================================
  # * Tooltip
  #============================================================================
  class Tooltip < Container
    #--------------------------------------------------------------------------
    # * Alias Methods
    #--------------------------------------------------------------------------
    alias_method(:sarkilas_draw, :draw)
    #--------------------------------------------------------------------------
    # * Constants
    #--------------------------------------------------------------------------
    T_Background  = RPG::Cache.gui("Framework/Tooltip")
    T_BorderColor = Color.new(60, 60, 60)
    #--------------------------------------------------------------------------
    # * Object Initialization
    #--------------------------------------------------------------------------
    def initialize(x, y, width, height, normal=false)
      @normal = normal
      super(x, y, width, height)
    end
    #--------------------------------------------------------------------------
    # * Draw Override
    #--------------------------------------------------------------------------
    def draw(text)
      if @normal
        sarkilas_draw(text)
      else
        sarkilas_draw(text, T_BorderColor, T_Background)
      end
    end
  end
  #============================================================================
  # * Button
  #============================================================================
  class Button < Container
    #--------------------------------------------------------------------------
    # * Object Initialization
    #--------------------------------------------------------------------------
    def initialize(x, y, width, text, inactive = false)
      super(x, y, width, 30, text, !inactive)
    end
    #--------------------------------------------------------------------------
    # * Clickable?
    #--------------------------------------------------------------------------
    def clickable?
      !@inactive
    end
    #--------------------------------------------------------------------------
    # * Update
    #--------------------------------------------------------------------------
    def update(index=nil)
      # If hidden: return
      return unless @visible
      # Update both sprites
      self.objects.each {|obj| obj.update unless obj.nil?}
      # Return if inactive
      if @inactive
        @sprite1.visible = true
        @sprite2.visible = false
        return
      end
      # Control hover
      if @control.nil?
        @sprite1.visible = !Mouse.in_bounds?(*self.bounds)
        @sprite2.visible = Mouse.in_bounds?(*self.bounds)
      end
      # If clicked and there is an event
      if self.clicked? and self.clickable?
        # Play SE
        $game_system.se_play($data_system.decision_se)
        # Call the event
        if @event.parameters.size > 0
          self.call(index, &@event)
        else
          @event.call
        end
      end
    end
    #--------------------------------------------------------------------------
    # * Bounds
    #--------------------------------------------------------------------------
    def bounds
      o = self.objects[0]
      [o.x + 1, o.y + 1, o.bitmap.width - 2, o.bitmap.height - 2]
    end
  end
  #============================================================================
  # * Dialog
  #============================================================================
  class Dialog < Container
    #--------------------------------------------------------------------------
    # * Object Initialization
    #--------------------------------------------------------------------------
    def initialize(width, height, text, *buttons)
      @x = 320 - width / 2
      @y = 240 - height / 2
      super(@x, @y, width, height, text)
      # Set up button array
      @buttons = []
      # Get maximum button width
      tmp = Bitmap.new(640, 480)
      bw = 40
      for i in 0...buttons.size
        bw = tmp.text_size(buttons[i]).width unless bw
        if bw && tmp.text_size(buttons[i]).width > bw
          bw = tmp.text_size(buttons[i]).width
        end
      end
      # Get component width
      cw = buttons.size > 1 ? (bw+20) * buttons.size : width / 2 + 30
      # Add all buttons
      for i in 0...buttons.size
        @buttons << Button.new(x + width - cw + (bw+20) * i, 
          y + height - 34, (bw+16), buttons[i])
      end
      # Start all dialogs faded out
      self.visible = false
      self.opacity = 0
      # Set Z values
      self.z = 99999
    end
    #--------------------------------------------------------------------------
    # * Update
    #--------------------------------------------------------------------------
    def update
      super
      for i in 0...@buttons.size
        @buttons[i].update(i)
      end
    end
    #--------------------------------------------------------------------------
    # * Bind Event to Dialog Button
    #--------------------------------------------------------------------------
    def bind(index, event)
      @buttons[index].bind(event)
    end
    #--------------------------------------------------------------------------
    # * Objects
    #--------------------------------------------------------------------------
    def objects
      a = super
      a.concat(@buttons)
    end
    #--------------------------------------------------------------------------
    # * Set Z
    #--------------------------------------------------------------------------
    def z=(value)
      self.objects.each {|obj| obj.z = value}
      @buttons.each {|button| button.z = value + 50}
    end
    #--------------------------------------------------------------------------
    # * Visible Set
    #--------------------------------------------------------------------------
    def visible=(bool)
      super
      self.objects.each {|obj| obj.visible = bool}
    end
    #--------------------------------------------------------------------------
    # * Opacity Set
    #--------------------------------------------------------------------------
    def opacity=(n)
      super
      @buttons.each {|button| button.opacity = n}
    end
  end
  #============================================================================
  # * Selectable (lists)
  #============================================================================
  class Selectable < Container
    #--------------------------------------------------------------------------
    # * Object Initialization
    #--------------------------------------------------------------------------
    def initialize(x, y, width, height)
      super(x, y, width, height, nil, true)
      @data = []
      @control = true
      refresh
      create_highlight
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
    end
    #--------------------------------------------------------------------------
    # * Get Contents
    #--------------------------------------------------------------------------
    def contents
      @contents
    end
    #--------------------------------------------------------------------------
    # * Clickable?
    #--------------------------------------------------------------------------
    def clickable?
      return false unless @event
      return false unless @index
      @index >= 0
    end
    #--------------------------------------------------------------------------
    # * Create Highlight
    #--------------------------------------------------------------------------
    def create_highlight
      # Create the sprite
      @highlight = Sprite.new
      @highlight.x = @x + 1
      @highlight.y = -500
      @highlight.z = @contents.z - 100
      # Get the base rect
      rect = self.item_rect(0)
      # Get the destination rect
      dest = Rect.new(0, 0, rect.width, rect.height)
      # Create the bitmap
      bitmap = Bitmap.new(rect.width, rect.height)
      # Get the source
      src = Container::Highlight
      # Draw the highlight
      bitmap.stretch_blt(dest, src, Rect.new(0, 0, src.width, src.height))
      # Set bitmap
      @highlight.bitmap = bitmap
      # Set opacity
      @highlight.opacity = 100
    end
    #--------------------------------------------------------------------------
    # * Item Rect
    #--------------------------------------------------------------------------
    def item_rect(index)
      Rect.new(@x, @y + 4 + 34 * index, @width, 32)
    end
    #--------------------------------------------------------------------------
    # * Set Data
    #--------------------------------------------------------------------------
    def set_data(data)
      @data = data
    end
    #--------------------------------------------------------------------------
    # * Get Index
    #--------------------------------------------------------------------------
    def index
      @index
    end
    #--------------------------------------------------------------------------
    # * Items
    #--------------------------------------------------------------------------
    def items
      @data
    end
    #--------------------------------------------------------------------------
    # * Item
    #--------------------------------------------------------------------------
    def item
      return nil if @index.nil?
      @index >= 0 ? @data[@index] : nil
    end
    #--------------------------------------------------------------------------
    # * Add Item
    #--------------------------------------------------------------------------
    def add_item(item)
      @data << item
      self.refresh
    end
    #--------------------------------------------------------------------------
    # * Remove Item 
    #--------------------------------------------------------------------------
    def remove_item(index)
      @data.delete_at(index)
    end
    #--------------------------------------------------------------------------
    # * Update
    #--------------------------------------------------------------------------
    def update
      # Ensure highlight is not visible when hidden
      @highlight.visible = false unless self.visible
      # Return if not visible
      return unless self.visible
      # Call superclass
      super
      # Ensure contents is visible
      @contents.visible = self.visible
      # Check for mouse overs
      over = false
      @index = -1
      for i in 0...@data.size
        # If mouse over
        if Mouse.in_bounds?(self.item_rect(i))
          @highlight.x = self.item_rect(i).x
          @highlight.y = self.item_rect(i).y
          @highlight.visible = true
          @index = i
          over = true
        end
      end
      # Set highlight visibility
      @highlight.visible = false unless over
      # Update highlight
      update_highlight
    end
    #--------------------------------------------------------------------------
    # * Update Highlight (fading)
    #--------------------------------------------------------------------------
    def update_highlight
      # Fade in
      if @fade_in
        @highlight.opacity += 5
        if @highlight.opacity >= 200
          @fade_in = false
        end
      else
        @highlight.opacity -= 5
        if @highlight.opacity <= 100
          @fade_in = true
        end
      end
    end
    #--------------------------------------------------------------------------
    # * Set Z
    #--------------------------------------------------------------------------
    def z=(value)
      self.objects.each {|obj| obj.z = value}
      @contents.z += 50
      @highlight.z += 10
    end
    #--------------------------------------------------------------------------
    # * Objects
    #--------------------------------------------------------------------------
    def objects
      a = super
      a << @contents
      a << @highlight
      a
    end
  end
end