extends Node2D

@export var enemy_scene : PackedScene

@onready var spawn_point = $Marker2D


func _on_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	
	get_tree().current_scene.add_child(enemy)
	
	enemy.global_position = spawn_point.global_position
