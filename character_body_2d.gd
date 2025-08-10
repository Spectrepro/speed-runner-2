extends CharacterBody2D

# --- Movement ---
@export var SPEED := 200
@export var JUMP_VELOCITY := -1000
@export var GRAVITY := 900

# --- Health ---
@export var MAX_HEALTH := 100
var current_health: int

# --- Respawn ---
@export var respawn_position: Vector2 = Vector2.ZERO
@export var death_height := 2000 # Y position below which player respawns

# --- Nodes ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var flamethrower_particles: GPUParticles2D = $Flamethrower
@onready var muzzle_position: Node2D = $Muzzle

# --- Signals ---
signal health_changed(new_health: int, max_health: int)
signal died

func _ready():
	current_health = MAX_HEALTH
	emit_signal("health_changed", current_health, MAX_HEALTH)
	flamethrower_particles.emitting = false

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
	
	# Horizontal movement
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * SPEED
		sprite.play("run")
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		sprite.play("idle")

	# Move
	move_and_slide()

	# Flamethrower firing
	if Input.is_action_pressed("fire"):
		flamethrower_particles.emitting = true
		# Flip muzzle position for left/right
		muzzle_position.position.x = abs(muzzle_position.position.x) * (-1 if sprite.flip_h else 1)
	else:
		flamethrower_particles.emitting = false

	# Respawn if fall out of world
	if position.y > death_height:
		respawn()

# --- Damage and Death ---
func take_damage(amount: int) -> void:
	current_health = clamp(current_health - amount, 0, MAX_HEALTH)
	emit_signal("health_changed", current_health, MAX_HEALTH)
	if current_health <= 0:
		die()

func heal(amount: int) -> void:
	current_health = clamp(current_health + amount, 0, MAX_HEALTH)
	emit_signal("health_changed", current_health, MAX_HEALTH)

func die() -> void:
	emit_signal("died")
	respawn()

func respawn() -> void:
	position = respawn_position
	current_health = MAX_HEALTH
	emit_signal("health_changed", current_health, MAX_HEALTH)
