extends Camera2D

@export var parallax_material: Material
@export var parallax_offset: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	parallax_material.set_shader_parameter("CamPos", global_position + parallax_offset)
