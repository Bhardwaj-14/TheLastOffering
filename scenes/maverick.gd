extends CharacterBody2D

@onready var anim = $animation

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 1000.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = input_vector.x * SPEED
	
	move_and_slide()
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		anim.play("attack")
	elif not is_on_floor():
		anim.play("jump")
	elif input_vector.x != 0:
		anim.play("run")
	else:
		anim.play("idle")
	
	if input_vector.x != 0:
		anim.flip_h = input_vector.x < 0
