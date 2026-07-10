class_name CraneController
extends Node2D

const CLAW_CLOSED_ANGLE: float = deg_to_rad(40)
const CLAW_OPEN_ANGLE: float = 0

enum State {
	controllable,
	lowering,
	lowered,
	grabbing,
	grabbed,
	returning,
	returned,
	dropping,
	idle,
}

# TODO: look into RapierRigidBody2D instead
@export_group("Nodes", "node_")
@export var node_base: RigidBody2D
@export var node_head: RigidBody2D
@export var node_claw_r: RigidBody2D
@export var node_claw_l: RigidBody2D
@export var node_bounds: Marker2D

@export var travel_speed: float = 200.0
@export var cable_stiffness: float = 100.0

@export var claw_strength: float = 80000.0

@export_group("Timing", "timing_")
@export var timing_lower_speed: float = 200.0
@export var timing_lowered_pause_time: float = 0.5
@export var timing_grab_time: float = 1.0
@export var timing_grabbed_pause_time: float = 0.5
@export var timing_return_raise_speed: float = 200.0
@export var timing_return_travel_speed: float = 200.0
@export var timing_returned_pause_time: float = 1.5
@export var timing_drop_time: float = 0.5
@export var timingg_return_slide_delay = 1.5

var state: State = State.controllable
# var chain: RapierDampedSpringJoint2D
var chain: LimitDistanceJoint
var claw_l_joint: RapierPinJoint2D
var claw_r_joint: RapierPinJoint2D

var origin: Vector2
var claw_home: float

var state_timer: float = 0.0

func _ready() -> void:
	origin = node_base.position
	claw_home = node_head.position.y

	chain = LimitDistanceJoint.new()
	add_child(chain)
	chain.root = node_base
	chain.end = node_head
	chain.distance = claw_home

	claw_r_joint = setup_pin_joint(node_head, node_claw_r, -CLAW_CLOSED_ANGLE, -CLAW_OPEN_ANGLE)
	claw_l_joint = setup_pin_joint(node_head, node_claw_l, CLAW_CLOSED_ANGLE, CLAW_OPEN_ANGLE)

	node_claw_r.add_collision_exception_with(node_claw_l)


func _physics_process(delta: float) -> void:
	state_timer += delta

	match state:
		State.controllable:
			var input_direction = Input.get_axis("move_left", "move_right")
			var vel = input_direction * travel_speed * delta
			if node_base.position.x + vel > 0:
				vel = node_base.position.x
			elif node_base.position.x + vel < node_bounds.position.x:
				vel = node_bounds.position.x - node_base.position.x
			node_base.move_and_collide(Vector2(vel, 0))
			if Input.is_action_just_pressed("drop"):
				set_state(State.lowering)
		State.lowering:
			set_chain_length(chain.distance + timing_lower_speed * delta)
			if chain.distance >= claw_home + node_bounds.position.y:
				set_chain_length(claw_home + node_bounds.position.y)
				set_state(State.lowered)
		State.lowered:
			if state_timer >= timing_lowered_pause_time:
				set_state(State.grabbing)
		State.grabbing:
			set_claw_angle(clamped_lerp(CLAW_OPEN_ANGLE, CLAW_CLOSED_ANGLE, state_timer / timing_grab_time))
			if state_timer >= timing_grab_time:
				set_state(State.grabbed)
		State.grabbed:
			if state_timer >= timing_grabbed_pause_time:
				set_state(State.returning)
		State.returning:
			set_chain_length(chain.distance - timing_return_raise_speed * delta)
			if chain.distance <= claw_home:
				set_chain_length(claw_home)
			if state_timer > timingg_return_slide_delay:
				node_base.move_and_collide(Vector2(timing_return_travel_speed * delta, 0))
				if node_base.position.x >= origin.x:
					node_base.position.x = origin.x
				if node_base.position == origin and chain.distance == claw_home:
					set_state(State.returned)
		State.returned:
			if state_timer >= timing_returned_pause_time:
				set_state(State.dropping)
		State.dropping:
			set_claw_angle(clamped_lerp(CLAW_CLOSED_ANGLE, CLAW_OPEN_ANGLE, state_timer / timing_drop_time))
			if state_timer >= timing_drop_time:
				set_state(State.controllable)
		State.idle:
			pass

func set_state(new_state: State) -> void:
	state = new_state
	state_timer = 0.0

func clamped_lerp(a: float, b: float, t: float) -> float:
	return lerp(a, b, clamp(t, 0.0, 1.0))

func set_chain_length(length: float) -> void:
	chain.distance = length

func setup_pin_joint(node_b: RigidBody2D, node_a: RigidBody2D, closed_angle: float, open_angle: float) -> RapierPinJoint2D:
	var joint = RapierPinJoint2D.new()
	node_a.add_child(joint)
	joint.node_a = node_a.get_path()
	joint.node_b = node_b.get_path()
	joint.angular_limit_enabled = true
	joint.angular_limit_lower = min(closed_angle, open_angle)
	joint.angular_limit_upper = max(closed_angle, open_angle)
	joint.motor_position_enabled = true
	joint.motor_position_stiffness = claw_strength
	return joint

func set_claw_angle(angle: float) -> void:
	claw_r_joint.motor_position_target_angle = - angle
	claw_l_joint.motor_position_target_angle = angle
