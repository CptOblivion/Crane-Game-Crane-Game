extends Node2D

class_name Parallax2DCustom

@export var scroll_scale: float = 1

var start_position: Vector2
var start_camera_position: Vector2

func _ready() -> void:
	start_position = position
	start_camera_position = get_viewport().get_camera_2d().position

func _process(_delta: float) -> void:
	position = start_position + (get_viewport().get_camera_2d().position - start_camera_position) * scroll_scale
