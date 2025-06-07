extends CharacterBody2D


const SPEED = 250.0
const JUMP_VELOCITY = -400.0
var finishedHitGround = true
var runAnim = true

@onready var anim = get_node("AnimationPlayer")

enum PlayerStatus {Idle, Run, Jump, Fall, HitGround, Attack, Death}

var status = PlayerStatus.Idle

func _ready() -> void:
	anim.play("Idle")
	anim.connect("animation_finished", _on_animation_finished)

func _physics_process(delta: float) -> void:

	if status == PlayerStatus.Idle:
		_idleState()
	elif status == PlayerStatus.Run:
		_runState()
	elif status == PlayerStatus.Jump:
		_jumpState(delta)
	elif status == PlayerStatus.Fall:
		_fallState(delta)
	elif status == PlayerStatus.HitGround:
		_hitGroundState()
	elif status == PlayerStatus.Attack:
		_attackState()
	move_and_slide()

func _move() -> void:
	var direction := Input.get_axis("left", "right")

	if direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
	if direction == 1:
		get_node("AnimatedSprite2D").flip_h = false
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func _idleState() -> void:
	anim.play("Idle")
	
	if not is_on_floor():
		anim.play("Fall")
		status = PlayerStatus.Jump
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		status = PlayerStatus.Jump
		anim.play("Jump")

	var direction := Input.get_axis("left", "right")

	_move()

	if direction:
		status = PlayerStatus.Run
		anim.play("Run")

func _runState() -> void:

	if not is_on_floor():
		anim.play("Fall")
		status = PlayerStatus.Fall
	elif Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		status = PlayerStatus.Jump
		anim.play("Jump")
	else :
		_move()

		var direction := Input.get_axis("left", "right")

		if direction == 0:
			status = PlayerStatus.Idle
		else:
			anim.play("Run")


func _jumpState(delta: float) -> void:
	velocity += get_gravity() * delta
	
	_move()
	if velocity.y > 0 and not is_on_floor():
		status = PlayerStatus.Fall
		anim.play("Fall")

func _fallState(delta: float) -> void:
	velocity += get_gravity() * delta
	
	_move()

	if is_on_floor() :
		finishedHitGround = false
		status = PlayerStatus.HitGround
		anim.play("HitGround")

func _hitGroundState() -> void:
	_move()
	if finishedHitGround == true:
		status = PlayerStatus.Idle
		anim.play("Idle")
		finishedHitGround = false

func _attackState() -> void:
	# A Complété
	status = PlayerStatus.Idle

func _on_animation_finished(nameAnimation) -> void:
	if nameAnimation == "HitGround":
		finishedHitGround = true
		status = PlayerStatus.Idle
