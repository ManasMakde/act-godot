class_name Player extends PlatformCharacter


# Public Properties
@export var run_speed: float = 500.0
@export var jump_velocity: float = -700.0
@export var arm_node: Node2D
@export var muzzle_node: Node2D
@export var bullet_scene: PackedScene
@export var skin_node: Node2D


# Animation Properties
@export var animation_player: AnimationPlayer
@export var idle_anim := "idle"
@export var run_anim := "run"
@export var back_run_anim := "run backwards"
@export var in_air_anim := "in air"


# Act Properties
@onready var theater:Theater = $Theater
var run_act := GeneralActs.MoveAct.new()
var jump_act := GeneralActs.JumpAct.new()
var aim_act := GeneralActs.LookAct.new()
var shoot_act := GeneralActs.ShootAct.new()
var damage_act := GeneralActs.DamageAct.new()


# Private Properties
var _health_system := HealthSystem.new()
var _move_direction := 0.0  # Last commanded move direction, unaffected by wall collision


# Public Methods
func damage(amount: float):
	damage_act.amount = amount
	damage_act.perform()
func set_movement_enabled(new_enabled: bool):
	run_act.set_enabled(new_enabled)
	jump_act.set_enabled(new_enabled)


# Override Methods
func _process(_delta: float) -> void:

	# Flip Skin
	var mouse_pos := get_global_mouse_position()
	if skin_node:
		if mouse_pos.x < global_position.x:
			skin_node.scale.x = -abs(skin_node.scale.x)
		elif mouse_pos.x > global_position.x:
			skin_node.scale.x = abs(skin_node.scale.x)


	# Play animations
	if(!is_on_floor()):  # In Air animation
		animation_player.play(in_air_anim)
	elif(run_act.did_perform_in_tick()):  # Run animation
		var aim_direction = sign(mouse_pos.x - global_position.x)
		var is_walking_backwards = aim_direction != 0.0 && sign(_move_direction) != aim_direction
		animation_player.play(back_run_anim if is_walking_backwards else run_anim)
	else:  # Idle animation
		animation_player.play(idle_anim)
func _physics_process(delta: float) -> void:


	# No Slide
	velocity.x = 0.0


	# Jump
	if Input.is_action_just_pressed("ui_up"):
		jump_act.perform()


	# Walk/Run
	_move_direction = Input.get_axis("ui_left", "ui_right")
	run_act.direction = _move_direction
	run_act.perform()


	# Aim
	aim_act.target_location = get_global_mouse_position()
	aim_act.perform()


	# Shoot
	if Input.is_action_just_pressed("ui_shoot"):
		shoot_act.target_location = get_global_mouse_position()
		shoot_act.perform()
	

	super._physics_process(delta)
func _ready():

	# Setup Run
	run_act.speed = run_speed
	run_act.init("Run Act", theater)


	# Setup Jump
	jump_act.speed = jump_velocity
	jump_act.init("Jump Act", theater)


	# Setup Aim
	aim_act.subject = arm_node
	aim_act.init("Aim Act", theater)


	# Setup Shoot
	shoot_act.spawn_node = muzzle_node
	shoot_act.aim_node = arm_node
	shoot_act.projectile_scene = bullet_scene
	shoot_act.init("Shoot Act", theater)


	# Setup Damage
	damage_act.health_system = _health_system
	damage_act.init("Damage Act", theater)
func _exit_tree():

	# Deinit all acts to clean up properly
	run_act.deinit()
	jump_act.deinit()
	aim_act.deinit()
	shoot_act.deinit()
	damage_act.deinit()
