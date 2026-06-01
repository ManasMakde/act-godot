class_name Dummy extends CharacterBody2D


@onready var theater:Theater = $Theater
var walk_act := LocomotionActs.MoveAct.new()
var run_act := LocomotionActs.MoveAct.new()
var jump_act := LocomotionActs.JumpAct.new()
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta: float) -> void:

	# Gravity & No Slide
	velocity.y += gravity * delta
	velocity.x = 0.0

	# Jump
	if Input.is_action_just_pressed("ui_accept"):
		jump_act.perform()

	# Walk/Run
	var direction := Input.get_axis("ui_left", "ui_right")
	var movement_act := run_act if Input.is_action_pressed("ui_shift") else walk_act
	movement_act.direction = direction
	movement_act.perform()

	move_and_slide()
func _ready():

	# Setup Walk
	walk_act.speed = 300.0
	walk_act.init(theater)

	# Setup Run
	run_act.speed = 500.0
	run_act.init(theater)

	# Setup Jump
	jump_act.speed = -400.0
	jump_act.init(theater)
