extends Polygon2D

class_name Polygon2DFixedBounds

func _process(_delta: float) -> void:
	# force always visible by keeping the viewport culling rect on screen
	var rect = get_viewport_rect()
	rect.position.x -= global_position.x
	rect.position.y -= global_position.y
	RenderingServer.canvas_item_set_custom_rect(get_canvas_item(), true, rect)
