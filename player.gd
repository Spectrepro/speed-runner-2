extends CharacterBody2D

@export var SPEED := 200
@export var JUMP_VELOCITY := -400
@export var GRAVITY := 1250

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		# Reset vertical velocity when on floor
		velocity.y = 0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction*SPEED
	else:
		velocity.x = move_toward(velocity.x,15,SPEED)  

		move_and_slide()

	
