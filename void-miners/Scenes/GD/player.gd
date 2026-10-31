extends CharacterBody2D

@export_group("Movement")
@export var walk_speed : float = 200.0
@export var sprint_speed : float = 500.0

@export_group("Stamina")
@export var stamina_max : float = 100.0
@export var stamina_decrease : float = 5.0
@export var stamina_reg : float = 5.0

@export_group("Health")
@export var max_health : float = 100

var stamina : float
var health : float

func _ready() -> void:
	stamina = stamina_max
	health = max_health
	
	$"../CanvasLayer/HealthBar".value = health
	$"../CanvasLayer/StaminaBar".value = stamina

func _physics_process(delta: float) -> void:
	handle_stamina(delta)
	handle_movement()

func handle_stamina(delta: float) -> void:
	if Input.is_action_pressed("sprint") and stamina > 0:
		stamina -= stamina_decrease * delta
	else:
		stamina += stamina_reg * delta

	stamina = clampf(stamina, 0.0, stamina_max)
	
	$"../CanvasLayer/StaminaBar".value = stamina

func handle_movement() -> void:
	var direction : Vector2 = Input.get_vector(
		"left", "right", "up", "down"
	)

	var current_speed : float = walk_speed

	if Input.is_action_pressed("sprint") and stamina > 0:
		current_speed = sprint_speed

	velocity = direction * current_speed
	move_and_slide()
	
func take_damage(damage : float):
	health -= damage
	update_health()
	
func heal(health_gain):
	health += health_gain
	update_health()
	
func update_health():
	$"../CanvasLayer/HealthBar".value = health
	health = clampf(health, 0, max_health)

func _on_area_2d_body_entered(_body: Node2D) -> void:
	take_damage(10)


func _on_area_2d_2_body_entered(_body: Node2D) -> void:
	heal(10)
