extends CharacterBody2D

@export var SPEED := 300
@export var JUMP_VELOCITY := -300
@export var GRAVITY := 1000
@export var max_health := 100
@export var flamethrower_damage := 10
@export var flamethrower_range := 150
@export var flamethrower_node: NodePath
@export var animated_sprite_path: NodePath

var current_health
var facing_dir := 1

@onready var ANIMATED_SPRITE: AnimatedSprite2D = get_node(animated_sprite_path)
@onready var FLAMETHROWER: GPUParticles2D = get_node(flamethrower_node)

func _ready():
	current_health = max_health
	FLAMETHROWER.emitting = false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var dir = Input.get_axis("move_left", "move_right")
	if dir != 0:
		facing_dir = dir
		velocity.x = dir * SPEED
		ANIMATED_SPRITE.flip_h = dir < 0
		ANIMATED_SPRITE.play("running")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		ANIMATED_SPRITE.play("idle")

	if Input.is_action_pressed("fire"):
		use_flamethrower()
	else:
		FLAMETHROWER.emitting = false

	move_and_slide()

func use_flamethrower():
	FLAMETHROWER.emitting = true
	ANIMATED_SPRITE.play("attack")

	# Damage enemies in range
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if position.distance_to(enemy.position) <= flamethrower_range:
			enemy.take_damage(flamethrower_damage * get_physics_process_delta_time())

func take_damage(amount):
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	ANIMATED_SPRITE.play("death")
	queue_free() # You can replace with respawn logic
