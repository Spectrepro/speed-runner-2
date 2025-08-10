extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval := 5.0
@export var max_enemies := 5
@export var spawn_points_parent: NodePath
@export var patrol_points_parent: NodePath

var spawn_points := []
var patrol_points := []
var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()

	if spawn_points_parent != null:
		spawn_points = get_node(spawn_points_parent).get_children()
	if patrol_points_parent != null:
		patrol_points = get_node(patrol_points_parent).get_children()

	spawn_wave()
	get_tree().create_timer(spawn_interval).timeout.connect(spawn_wave)

func spawn_wave():
	if get_tree().get_nodes_in_group("enemies").size() >= max_enemies:
		return

	var spawn_index = rng.randi_range(0, spawn_points.size() - 1)
	var spawn_pos = spawn_points[spawn_index].global_position

	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.position = spawn_pos
	enemy_instance.player_ref = get_parent().get_node("Player")
	enemy_instance.patrol_points = pick_random_patrol_set()

	get_parent().add_child(enemy_instance)

func pick_random_patrol_set():
	var selected_points := []
	if patrol_points.size() > 0:
		var point_count = rng.randi_range(2, min(4, patrol_points.size()))
		selected_points = patrol_points.duplicate()
		selected_points.shuffle()
		selected_points = selected_points.slice(0, point_count)
	return selected_points
