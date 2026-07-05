class_name CraneController
extends RigidBody2D

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
@export var node_head: RigidBody2D
@export var node_claw_r: RigidBody2D
@export var node_claw_l: RigidBody2D

@export var travel_speed: float = 200.0
@export var lower_height: float = 400.0
@export var cable_stiffness: float = 100.0
@export var claw_strength: float = 100000.0

@export_group("Timing", "timing_")
@export var timing_lower_speed: float = 200.0
@export var timing_lowered_pause_time: float = 0.5
@export var timing_grab_time: float = 1.0
@export var timing_grabbed_pause_time: float = 0.5
@export var timing_return_raise_speed: float = 200.0
@export var timing_return_travel_speed: float = 200.0
@export var timing_returned_pause_time: float = 1.5
@export var timing_drop_time: float = 0.5

@export var travel_limit: float = 500.0 # TODO: set a rect in editor, get the origin, limit, and drop height from the rect

var state: State = State.controllable
var chain: DampedSpringJoint2D
var claw_l_joint: PinJoint2D
var claw_r_joint: PinJoint2D

var origin: Vector2
var claw_home: float

var state_timer: float = 0.0

var target_angle: float = 0.0

func _ready() -> void:
	origin = position
	claw_home = node_head.position.y

	chain = DampedSpringJoint2D.new()
	add_child(chain)
	chain.node_a = get_path()
	chain.node_b = node_head.get_path()
	chain.stiffness = 100000
	set_chain_length(claw_home)

	claw_r_joint = PinJoint2D.new()
	node_head.add_child(claw_r_joint)
	claw_r_joint.node_a = node_claw_r.get_path()
	claw_r_joint.node_b = node_head.get_path()
	claw_r_joint.angular_limit_enabled = true
	claw_r_joint.angular_limit_lower = - CLAW_CLOSED_ANGLE
	claw_r_joint.angular_limit_upper = CLAW_OPEN_ANGLE

	claw_l_joint = PinJoint2D.new()
	node_head.add_child(claw_l_joint)
	claw_l_joint.node_a = node_claw_l.get_path()
	claw_l_joint.node_b = node_head.get_path()
	claw_l_joint.angular_limit_enabled = true
	claw_l_joint.angular_limit_lower = CLAW_OPEN_ANGLE
	claw_l_joint.angular_limit_upper = CLAW_CLOSED_ANGLE

	node_claw_r.add_collision_exception_with(node_claw_l)

	target_angle = 0


func _physics_process(delta: float) -> void:
	state_timer += delta

	match state:
		State.controllable:
			var input_direction = Input.get_axis("move_left", "move_right")
			move_and_collide(Vector2(input_direction * travel_speed * delta, 0))
			if Input.is_action_just_pressed("drop"):
				set_state(State.lowering)
		State.lowering:
			set_chain_length(chain.length + timing_lower_speed * delta)
			if node_head.position.y >= claw_home + lower_height:
				node_head.position.y = claw_home + lower_height
				set_state(State.lowered)
		State.lowered:
			if state_timer >= timing_lowered_pause_time:
				set_state(State.grabbing)
		State.grabbing:
			target_angle = clamped_lerp(CLAW_OPEN_ANGLE, CLAW_CLOSED_ANGLE, state_timer / timing_grab_time)
			if state_timer >= timing_grab_time:
				set_state(State.grabbed)
		State.grabbed:
			if state_timer >= timing_grabbed_pause_time:
				set_state(State.returning)
		State.returning:
			set_chain_length(chain.length - timing_return_raise_speed * delta)
			if chain.length <= claw_home:
				set_chain_length(claw_home)
			move_and_collide(Vector2(timing_return_travel_speed * delta, 0))
			if position.x >= origin.x:
				position.x = origin.x
			if position == origin and chain.length == claw_home:
				set_state(State.returned)
		State.returned:
			if state_timer >= timing_returned_pause_time:
				set_state(State.dropping)
		State.dropping:
			target_angle = clamped_lerp(CLAW_CLOSED_ANGLE, CLAW_OPEN_ANGLE, state_timer / timing_drop_time)
			if state_timer >= timing_drop_time:
				set_state(State.controllable)
		State.idle:
			pass
	node_claw_r.apply_torque_impulse(claw_strength * (target_angle - node_claw_r.rotation))
	node_claw_l.apply_torque_impulse(claw_strength * (-target_angle - node_claw_l.rotation))

func set_state(new_state: State) -> void:
	state = new_state
	state_timer = 0.0

func clamped_lerp(a: float, b: float, t: float) -> float:
	return lerp(a, b, clamp(t, 0.0, 1.0))

func set_chain_length(length: float) -> void:
	chain.length = length
	chain.rest_length = length
