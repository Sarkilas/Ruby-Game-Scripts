#==============================================================================
# ** Graphics Tools Module
#------------------------------------------------------------------------------
#  This module contains methods for additional graphics tools.
#==============================================================================

module GFX_Tools
	#--------------------------------------------------------------------------
	# * Draw Actor Graphic
	#--------------------------------------------------------------------------
	def draw_actor_graphic(x, y, actor, bitmap)
		char = RPG::Cache.character(actor.character_name, actor.character_hue)
		cw = char.width / 4
		ch = char.height / 4
		src_rect = Rect.new(0, 0, cw, ch)
		bitmap.blt(x, y, char, src_rect)
	end
	#--------------------------------------------------------------------------
	# * Draw Bar
	#--------------------------------------------------------------------------
	def draw_bar(x, y, current, max, bar, bitmap, width = 196)
		# Get container
		container = RPG::Cache.gui("Container")
		# Get percentage
		perc = current.to_f / max.to_f
		# Draw container first
		dest = Rect.new(x, y, width, container.height)
		bitmap.stretch_blt(dest, container, Rect.new(0, 0, container.width, container.height))
		# Get source rect
		rect = Rect.new(0, 0, width, bar.height)
		# Draw actual bar
		dest = Rect.new(x, y, width * perc, bar.height)
		bitmap.stretch_blt(dest, bar, rect)
	end
	#--------------------------------------------------------------------------
	# * Draw Bar Numbers
	#--------------------------------------------------------------------------
	def draw_bar_numbers(x, y, label, current, max, bitmap, width = 196)
		# Draw label first
		bitmap.font.color = Color.new(255, 180, 180)
		bitmap.draw_text(x + 2, y - 2, width, 16, label)
		# Draw numbers
		bitmap.font.color = Color.new(255, 255, 255)
		bitmap.draw_text(x + 2, y - 2, width - 4, 16, "#{current} / #{max}", 2)
	end
end