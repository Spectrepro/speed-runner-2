# GameScene.gd
# This script manages the main game scene, including score, mob spawning, and game state.

extends Node

# Exporting a variable allows you to set the Mob scene from the Inspector.
@export var mob_scene: PackedScene

# These variables will hold references to nodes in the scene.
@onready var score_label = $UserInterface/ScoreLabel
@onready var message_label = $UserInterface/Message
@onready var player = $Player
@onready var mob_spawn_location = $MobPath/MobSpawnLocation
@onready var mob_timer = $MobTimer
@onready var score_timer = $ScoreTimer
@onready var start_timer = $StartTimer

# Game state variable
var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Hide the message label initially
	message_label.hide()
	# Connect signals to their respective functions
	player.hit.connect(game_over)


# This function is called to start a new game.
func new_game():
	# Reset the score
	score = 0
	score_label.text = "Score: " + str(score)

	# Position the player at the starting position
	player.start($StartPosition.position)

	# Start the initial countdown timer
	start_timer.start()

	# Show "Get Ready" message
	message_label.text = "Get Ready!"
	message_label.show()


# This function is called when the game is over.
func game_over():
	# Stop the timers that control mob spawning and score counting
	mob_timer.stop()
	score_timer.stop()

	# Show the "Game Over" message
	message_label.text = "Game Over"
	message_label.show()

	# A brief delay before we allow a restart, to prevent accidental restarts.
	await get_tree().create_timer(1.0).timeout
	
	# Allow the player to restart by pressing the "start" input action
	message_label.text += "\nPress Start"


# Called every time the ScoreTimer times out.
func _on_score_timer_timeout():
	score += 1
	score_label.text = "Score: " + str(score)


# Called every time the StartTimer times out.
func _on_start_timer_timeout():
	# When the "Get Ready" timer finishes, start the main game timers
	mob_timer.start()
	score_timer.start()
	message_label.hide()


# Called every time the MobTimer times out.
func _on_mob_timer_timeout():
	# This is where we spawn a new mob.

	# Check if the mob scene has been assigned in the inspector
	if not mob_scene:
		print("Error: Mob scene not set in the GameScene script.")
		return

	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random starting location on the spawn path.
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2
	
	# Position the mob at the random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Set the mob's velocity.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Add the mob to the scene.
	add_child(mob)
