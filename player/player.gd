extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var anim_tree = $AnimationTree
@onready var anim_state_machine:AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")
var last_direction := 1  # 1=right, -1=left
var is_attacking := false


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var is_moving := input_dir != Vector2.ZERO
	
	if Input.is_action_just_pressed("a") and not is_attacking:
		print_debug("attacking...")
		is_attacking = true
		if last_direction > 0:
			anim_state_machine.travel("attack1_right")
		else:
			anim_state_machine.travel("attack1_left")
	
	if not is_attacking:
		if is_moving:
			last_direction = sign(input_dir.x) if input_dir.x != 0 else last_direction
			if last_direction > 0:
				anim_state_machine.travel("run_right")
			else:
				anim_state_machine.travel("run_left")
		else:
			if last_direction > 0:
				anim_state_machine.travel("idle_right")
			else:
				anim_state_machine.travel("idle_left")

	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack"):
		is_attacking = false
	print_debug("stop attack")
