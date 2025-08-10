extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval := 5.0
@export var max_enemies := 5
@export var spawn_points_parent: NodePath
@export var patrol_points_parent: NodePath
@export var player_path: NodePath

var rng := RandomNumberGenerator.new()
var spawn_points := []
var patrol_points := []

func _ready():
	rng.randomize()
	spawn_points = get_node(spawn_points_parent).get_children()
	patrol_points = get_node(patrol_points_parent).get_children()
	_spawn_wave()
	$Timer.wait_time = spawn_interval
	$Timer.connect("timeout", Callable(self, "_spawn_wave"))
	$Timer.start()

func _spawn_wave():
	if get_tree().get_nodes_in_group("enemies").size() >= max_enemies:
		return

	var spawn_pos = spawn_points[rng.randi_range(0, spawn_points.size() - 1)].global_position
	var enemy = enemy_scene.instantiate()
	enemy.position = spawn_pos
	enemy.player_ref = get_node(player_path)
	enemy.patrol_points = patrol_points
	get_parent().add_child(enemy)
