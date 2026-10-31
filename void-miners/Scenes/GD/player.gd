extends CharacterBody2D

@export_group("Movement")
@export var walk_speed : float = 200.0
@export var sprint_speed : float = 500.0

@export_group("Stamina")
@export var stamina_max : float = 100.0
@export var stamina_decrease : float = 5.0
@export var stamina_reg : float = 5.0

var stamina : float

func _ready() -> void:
	stamina = stamina_max

func _physics_process(delta: float) -> void:
	handle_stamina(delta)
	handle_movement()

func handle_stamina(delta: float) -> void:
	if Input.is_action_pressed("sprint") and stamina > 0:
		stamina -= stamina_decrease * delta
	else:
		stamina += stamina_reg * delta

	stamina = clampf(stamina, 0.0, stamina_max)


func handle_movement() -> void:
	var direction : Vector2 = Input.get_vector(
		"left", "right", "up", "down"
	)

	var current_speed : float = walk_speed

	if Input.is_action_pressed("sprint") and stamina > 0:
		current_speed = sprint_speed

	velocity = direction * current_speed
	move_and_slide()
