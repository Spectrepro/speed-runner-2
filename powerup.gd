extends Area2D

@export var damage_per_second := 20

func _ready():
	set_process(false)
	visible = false

func _process(delta):
	for body in get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage_per_second * delta)

func turn_on():
	set_process(true)
	visible = true

func turn_off():
	set_process(false)
	visible = false
