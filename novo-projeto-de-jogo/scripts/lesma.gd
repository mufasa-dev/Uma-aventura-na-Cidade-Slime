extends CharacterBody3D

const SPEED = 1.0
const CHASE_RANGE = 4.0
const ATTACK_RANGE = 1.5
const DAMAGE_FRAME_TIME = 0.83 
const ATTACK_ANGLE_LIMIT = 0.7

@export var target: CharacterBody3D
@onready var nav_agent: NavigationAgent3D = $nav_agent
@onready var anim_player: AnimationPlayer = $lesma2/AnimationPlayer

var is_attacking: bool = false
var damage_applied: bool = false
var attack_timer: float = 0.0

func _ready() -> void:
	anim_player.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if not target:
		_play_animation("Idle")
		return
		
	velocity = Vector3.ZERO
	var distance = global_position.distance_to(target.global_position)
	
	if is_attacking:
		attack_timer += delta
		
		if attack_timer >= DAMAGE_FRAME_TIME and not damage_applied:
			if distance <= ATTACK_RANGE:
				# Calcula a direção até o jogador (somente no plano horizontal XZ)
				var to_target = (target.global_position - global_position)
				to_target.y = 0
				to_target = to_target.normalized()
				
				# Pega a direção para onde a frente da lesma está apontando
				var forward_direction = -global_transform.basis.z
				forward_direction.y = 0
				forward_direction = forward_direction.normalized()
				
				# Compara os dois vetores. Retorna 1.0 se estiver perfeito na frente
				var dot_product = forward_direction.dot(to_target)
				
				if dot_product >= ATTACK_ANGLE_LIMIT:
					if target.has_method("take_damage"):
						target.take_damage(global_position, 15.0)
						
			damage_applied = true
		return
		
	if distance <= ATTACK_RANGE:
		is_attacking = true
		damage_applied = false
		attack_timer = 0.0
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
		damage_applied = false
		attack_timer = 0.0
