extends CharacterBody2D

@onready var attack_area = $PlayerAttackArea
@onready var detection_area = $DetectionArea
@onready var sprite = $Weapon

@export_group("Movement")
@export var walk_speed : float = 200.0
@export var sprint_speed : float = 500.0

@export_group("Stamina")
@export var stamina_max : float = 100.0
@export var stamina_decrease : float = 5.0
@export var stamina_reg : float = 5.0

@export_group("Health")
@export var max_health : float = 100

@export_group("Attack")
@export var attack_damage : float = 5
@export var offset : Vector2 = Vector2(1, 0)

var stamina : float
var health : float
var can_attack : bool = true
var current_target = null

func _ready() -> void:
	stamina = stamina_max
	health = max_health
	
	$"../CanvasLayer/HealthBar".value = health
	$"../CanvasLayer/StaminaBar".value = stamina

func _physics_process(delta: float) -> void:
	handle_stamina(delta)
	handle_movement()
	handle_attack()

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
	
	if health <= 0:
		queue_free()
	
func update_target_direction():
	if current_target == null:
		return
		
	var direction = global_position.direction_to(current_target.global_position)
	
	sprite.rotation = direction.angle()
	sprite.position = direction * offset
	$AnimationPlayer.current_animation = "sword_attack"
	
func attack():
	if not can_attack:
		return
		
	can_attack = false
	
	attack_area.monitoring = true

	await get_tree().physics_frame
	
	for area in detection_area.get_overlapping_areas():
		if area.has_method("enemy_take_damage"):
			area.enemy_take_damage(attack_damage)
			
	await get_tree().create_timer(0.3).timeout
	
	attack_area.monitoring = false
	await get_tree().create_timer(0.3).timeout
	
	can_attack = true
	
func handle_attack():
	if current_target != null:
		update_target_direction()
	
		if can_attack:
			attack()

func _on_area_2d_body_entered(_body: Node2D) -> void:
	take_damage(10)

func _on_area_2d_2_body_entered(_body: Node2D) -> void:
	heal(10)
		
func _on_detection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		current_target = area

func _on_detection_area_area_exited(area: Area2D) -> void:
	if area == current_target:
		current_target = null
