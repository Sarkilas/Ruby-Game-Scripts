#==============================================================================
# ** Window_File
#------------------------------------------------------------------------------
#  This window class contains file listing for the title screen.
#==============================================================================

class Window_File < Window_Base
  #----------------------------------------------------------------------------
  # * Object Initialization
  #----------------------------------------------------------------------------
  def initialize(n, tag=0, time=0, date=0)
    super(0, 0, 160, 172)
    self.contents = Bitmap.new(width - 32, height - -32)
    @id = n
    @tag = tag
    @time = time
    @date = date
    refresh
    self.opacity = 0
    self.z = 9999
  end
  #----------------------------------------------------------------------------
  # * Refresh
  #----------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    self.contents.font.outline = false
    self.contents.font.size = 24
    self.contents.draw_text(4,0,width,32, "Story ##{@id}")
    return if @tag == 0
    self.contents.font.size = 20
    self.contents.draw_text(4,16,width,32, @tag)
    self.contents.font.size = 18
    self.contents.draw_text(4,40,width,32, "Play Time")
    self.contents.font.size = 18
    self.contents.draw_text(4,60,width,32, @time)
    self.contents.font.size = 18
    self.contents.draw_text(4,88,width,32, "Last Save At")
    self.contents.font.size = 18
    self.contents.draw_text(4,104,width,32, @date.strftime("%d/%m/%Y %H:%M"))
  end
end
    