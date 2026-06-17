extends CharacterBody3D

const SPEED = 50
const JUMP_VELOCITY = 10

@onready var animator = get_node("jose/AnimationPlayer") as AnimationPlayer

@export var view : Node3D

var gravity = 0
var movement_velocity : Vector3
var rotation_direction : float

var knockback_velocity : Vector3 = Vector3.ZERO
var is_knocked_back : bool = false

func _ready() -> void:
	if not view:
		view = get_node("../Camera_pivot")
		
	if animator:
		animator.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if not is_knocked_back:
		handle_input(delta)
	else:
		knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, delta * 30.0)
		velocity = knockback_velocity
		if knockback_velocity.length() < 0.5:
			is_knocked_back = false
			velocity = Vector3.ZERO 
			movement_velocity = Vector3.ZERO
			
	apply_gravity(delta)
	jump(delta)
	handle_animations()
	
	var applied_velocity : Vector3
	if not is_knocked_back:
		applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	else:
		applied_velocity = velocity
		
	applied_velocity.y = -gravity
	velocity = applied_velocity
	
	move_and_slide()
	
	if not is_knocked_back:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider and collider.name == "Lesma":
				var local_shape = collider.shape_owner_get_owner(collider.shape_find_owner(collision.get_collider_shape_index()))
				if local_shape and local_shape.name == "thorns":
					take_damage(collider.global_position, 12.0)
					break
	
	if not is_knocked_back and movement_velocity.length() > 0.01:
		rotation_direction = Vector2(movement_velocity.z, movement_velocity.x).angle()
		rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)

func handle_input(delta):
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_backward")
	
	input = input.rotated(Vector3.UP, view.rotation.y).normalized()
	
	movement_velocity = input * (SPEED * 5.0) * delta

func handle_animations():
	if not animator:
		return
		
	if is_knocked_back:
		return
		
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			animator.play("Walk", 0.3)
		else:
			animator.play("Idle", 0.3)
	else:
		animator.play("Jump", 2)
		
	if !is_on_floor() and gravity > 2:
		animator.play("Idle", 0.3)
	
func apply_gravity(delta):
	if not is_on_floor():
		gravity += 25 * delta
		
	if gravity > 0 and is_on_floor():
		gravity = 0
	
func jump(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_knocked_back:
		gravity = -JUMP_VELOCITY

func take_damage(source_position: Vector3, force: float) -> void:
	is_knocked_back = true
	
	var direction = (global_position - source_position)
	direction.y = 0
	direction = direction.normalized()
	
	knockback_velocity = direction * force
	gravity = -4.0

func _on_animation_finished(animation_name: String) -> void:
	pass

func _on_hurt_box_body_entered(body: Node3D) -> void:
	pass
