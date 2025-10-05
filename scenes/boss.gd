extends CharacterBody2D

const BOSS_SPEED = 150.0
const ATTACK_RANGE = 80.0
const ATTACK_DAMAGE_RANGE = 120.0
const ATTACK_COOLDOWN = 0.6
const CHASE_DISTANCE = 500.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var player = null
var boss_health = 12
var is_attacking = false
var is_dead = false
var can_attack = true
var attack_cooldown_timer = 0.0

func _ready():
	add_to_group("boss")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta
		if attack_cooldown_timer <= 0:
			can_attack = true
	
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if player != null:
		var distance_to_player = global_position.distance_to(player.global_position)
		if player.global_position.x < global_position.x:
			anim.flip_h = true
		else:
			anim.flip_h = false
		
		if is_attacking:
			velocity.x = 0
		elif distance_to_player <= ATTACK_RANGE and can_attack:
			velocity.x = 0
			start_attack()
		elif distance_to_player < CHASE_DISTANCE and distance_to_player > ATTACK_RANGE:
			if distance_to_player > 60:
				var direction = sign(player.global_position.x - global_position.x)
				velocity.x = direction * BOSS_SPEED
				if not is_attacking:
					anim.play("idle")
		else:
			velocity.x = 0
			if not is_attacking:
				anim.play("idle")
	move_and_slide()

func start_attack():
	if is_attacking or not can_attack or is_dead:
		return
	is_attacking = true
	can_attack = false
	attack_cooldown_timer = ATTACK_COOLDOWN
	
	anim.play("attack")
	if is_inside_tree():
		await get_tree().create_timer(0.2).timeout
	
	if is_dead or not is_inside_tree():
		return
	deal_damage_to_player()
	
	if is_inside_tree():
		await get_tree().create_timer(0.3).timeout
	
	if is_dead or not is_inside_tree():
		return
		
	is_attacking = false

func deal_damage_to_player():
	if player == null or is_dead:
		return
	var distance = global_position.distance_to(player.global_position)
	
	if distance <= ATTACK_DAMAGE_RANGE:
		if player.has_method("take_damage"):
			player.take_damage(1)

func take_damage(amount: int):
	if is_dead:
		return
	boss_health -= amount
	if boss_health <= 0:
		die()

func die():
	is_dead = true
	velocity.x = 0
	can_attack = false
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	anim.play("dead")
	if is_inside_tree():
		await anim.animation_finished
	if is_inside_tree():
		get_tree().change_scene_to_file("res://next_level.tscn")
