extends Node2D
class_name ParallaxScroll

@export var parallax_material: Material
@export var scroll_speed: float
@export var scroll_target: Node2D
@export var horizon: float

var start_pos: Vector2
var target_start_pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_pos = position
	target_start_pos = scroll_target.position
	print("init: " + name, position, start_pos, target_start_pos)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position = start_pos + (scroll_target.position - target_start_pos) * scroll_speed
	if position != start_pos:
			print("moved: ", name, " ", start_pos, " ", position)
	if parallax_material != null:
		parallax_material.set_shader_parameter("cam_pos", global_position + Vector2(0, horizon))
