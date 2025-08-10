extends CharacterBody2D

@export var SPEED := 80
@export var max_health := 50
@export var damage := 10
@export var attack_range := 40
@export var attack_cooldown := 1.0

var current_health
var attack_timer := 0.0
var player_ref
var patrol_points: Array = []
var patrol_index := 0
var chasing := false

@onready var ANIMATED_SPRITE: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	current_health = max_health
	add_to_group("enemies")

func _physics_process(delta):
	if player_ref and is_instance_valid(player_ref):
		if position.distance_to(player_ref.position) <= 200:
			chasing = true
		elif position.distance_to(player_ref.position) > 250:
			chasing = false

		if chasing:
			move_towards_player(delta)
			handle_attack(delta)
		else:
			patrol(delta)

	move_and_slide()

func patrol(delta):
	if patrol_points.size() == 0:
		return
	var target = patrol_points[patrol_index].global_position
	if position.distance_to(target) < 5:
		patrol_index = (patrol_index + 1) % patrol_points.size()
	else:
		velocity.x = sign(target.x - position.x) * SPEED
		ANIMATED_SPRITE.flip_h = velocity.x < 0
		ANIMATED_SPRITE.play("walk")

func move_towards_player(delta):
	var dir = sign(player_ref.position.x - position.x)
	velocity.x = dir * SPEED
	ANIMATED_SPRITE.flip_h = dir < 0
	if abs(player_ref.position.x - position.x) > attack_range:
		ANIMATED_SPRITE.play("walk")

func handle_attack(delta):
	attack_timer -= delta
	if abs(player_ref.position.x - position.x) <= attack_range:
		if attack_timer <= 0:
			perform_attack()
			attack_timer = attack_cooldown

func perform_attack():
	ANIMATED_SPRITE.play("attack")
	if player_ref and is_instance_valid(player_ref):
		player_ref.take_damage(damage)

func take_damage(amount):
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	queue_free()
