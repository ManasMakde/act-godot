class_name ActBot extends CharacterBody2D


# Public Properties
@export var walk_speed: float = 100.0
@export var run_speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var idle_anim := "idle"
@export var walk_anim := "walk"
@export var run_anim := "run"
@export var jump_anim := "jump"


# Private Properties
@onready var theater:Theater = $Theater
@onready var anim_player:AnimationPlayer = $AnimationPlayer
@onready var sprite:Sprite2D = $Sprite
var walk_act := LocomotionActs.MoveAct.new()
var run_act := LocomotionActs.MoveAct.new()
var jump_act := LocomotionActs.JumpAct.new()
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction := 0.0


# Private Methods
func handle_animation():
	
	# Get which animation to play
	var anim_to_play:String
	if(!is_on_floor()):
		anim_to_play = jump_anim
	elif walk_act.did_perform():
		anim_to_play = walk_anim
	elif run_act.did_perform():
		anim_to_play = run_anim
	else:
		anim_to_play = idle_anim


	# Play animation
	if anim_player.current_animation != anim_to_play:
		anim_player.play(anim_to_play)


	# Flip based on direction
	if(direction < 0.0):
		sprite.flip_h = true
	elif(direction > 0.0):
		sprite.flip_h = false


# Override Methods
func _physics_process(delta: float) -> void:

	# Gravity & No Slide
	velocity.y += gravity * delta
	velocity.x = 0.0

	# Jump
	if Input.is_action_just_pressed("ui_up"):
		jump_act.perform()

	# Walk/Run
	direction = Input.get_axis("ui_left", "ui_right")
	var movement_act := run_act if Input.is_action_pressed("ui_shift") else walk_act
	movement_act.direction = direction
	movement_act.perform()

	# Apply physics
	move_and_slide()

	# Play animation
	handle_animation()
func _ready():

	# Setup Walk
	walk_act.speed = walk_speed
	walk_act.init(theater)

	# Setup Run
	run_act.speed = run_speed
	run_act.init(theater)

	# Setup Jump
	jump_act.speed = jump_velocity
	jump_act.init(theater)
