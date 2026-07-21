extends Parallax2D

class_name Parallax2DCustom

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# an extra offset of half the screen * scroll scale is applied when the game is running, but not in the editor
	# make it look right in the editor, this code counteracts the extra offset
	scroll_offset += (Vector2)(get_viewport().size) / 2 * scroll_scale
