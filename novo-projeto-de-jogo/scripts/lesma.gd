extends CharacterBody3D

const SPEED = 1.0
const CHASE_RANGE = 4.0

@export var target: CharacterBody3D
@onready var nav_agent: NavigationAgent3D = $nav_agent

func _physics_process(delta: float) -> void:
	if not target:
		return
		
	velocity = Vector3.ZERO
	
	if global_position.distance_to(target.global_position) < CHASE_RANGE:
		nav_agent.target_position = target.global_position
		
		if not nav_agent.is_navigation_finished():
			var next_nav_point = nav_agent.get_next_path_position()
			
			var direction = (next_nav_point - global_position).normalized()
			velocity = direction * SPEED
			look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
			
			
	move_and_slide()
