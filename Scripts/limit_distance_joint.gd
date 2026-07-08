extends Node2D
class_name LimitDistanceJoint

@export var root: Node2D
@export var end: RigidBody2D
@export var distance: float = 0

func _physics_process(delta: float) -> void:
	var upcoming_pos = end.global_position + end.linear_velocity * delta
	var upcoming_dist = upcoming_pos.distance_to(root.global_position)
	if upcoming_dist <= distance:
		return

	var adjustment = upcoming_pos.direction_to(root.global_position) * (upcoming_dist - distance)

	end.linear_velocity += adjustment / delta
