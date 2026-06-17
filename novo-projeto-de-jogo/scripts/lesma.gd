extends CharacterBody3D

const SPEED = 1.0
const CHASE_RANGE = 4.0
const ATTACK_RANGE = 1.5

@export var target: CharacterBody3D
@onready var nav_agent: NavigationAgent3D = $nav_agent
@onready var anim_player: AnimationPlayer = $lesma2/AnimationPlayer

var is_attacking: bool = false

func _ready() -> void:
	anim_player.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if not target:
		_play_animation("Idle")
		return
		
	velocity = Vector3.ZERO
	var distance = global_position.distance_to(target.global_position)
	
	if is_attacking:
		return
		
	if distance <= ATTACK_RANGE:
		velocity = Vector3.ZERO
		is_attacking = true
		_play_animation("Attack")
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
		return
	
	if distance < CHASE_RANGE:
		nav_agent.target_position = target.global_position
		
		if not nav_agent.is_navigation_finished():
			var next_nav_point = nav_agent.get_next_path_position()
			var direction = (next_nav_point - global_position).normalized()
			velocity = direction * SPEED
			look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
			
	move_and_slide()
	
	if velocity.length() > 0.01:
		_play_animation("Walk")
	else:
		_play_animation("Idle")

func _play_animation(animation_name: String) -> void:
	if anim_player.current_animation != animation_name:
		anim_player.play(animation_name, 0.3)

func _on_animation_finished(animation_name: String) -> void:
	if animation_name == "Attack":
		is_attacking = false
