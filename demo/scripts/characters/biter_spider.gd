class_name BiterSpider extends PlatformCharacter


# Public Properties
@export var is_venomous: bool = false
@export var venom_scene: PackedScene
@export var attack_delay: float = 0.5
@export var attack_radius: float = 30.0
@export var wait_duration_min: float = 1.0
@export var wait_duration_max: float = 5.0
@export var speed: float = 100.0
@export var platform_ray_distance: float = 50.0
@export var reaction_delay: float = 0.5
@export var skin_node: Node2D


# Animation Properties
@export var animation_player: AnimationPlayer
@export var idle_anim := "idle"
@export var walk_anim := "walk"
@export var attack_anim := "attack"
@export var damaged_anim := "damaged"
@export var falling_anim := "falling"


# Act Properties
@onready var theater: Theater = $Theater
var live_act := GeneralActs.PerpetualAct.new()
var patrol_act := GeneralActs.GotoAct.new()
var chase_act := GeneralActs.GotoAct.new()
var wait_act := GeneralActs.WaitAct.new()
var attack_act := GeneralActs.AttackAct.new()
var attack_delay_act := GeneralActs.WaitAct.new()
var damage_act := GeneralActs.DamageAct.new()


# Private Properties
var _health_system := HealthSystem.new()
var _player: Player


# Public Methods
func damage(amount: float):
	damage_act.amount = amount
	damage_act.perform()


# Private Methods
func find_player(node: Node) -> Player:
	if node is Player:
		return node
	
	for child in node.get_children():
		var result = find_player(child)
		if result:
			return result
	return null
func in_attack_range(target: Player) -> bool:

	if(target == null || !is_instance_valid(target)):
		return false

	return global_position.distance_to(target.global_position) <= attack_radius
func get_chase_bounds() -> Rect2:

	# Return empty rect if no platform to stay on
	if(_platform == null || !is_instance_valid(_platform)):
		return Rect2()


	# Find collision on platform
	var collision := _platform.get_node("CollisionShape2D") as CollisionShape2D
	if(collision == null):
		return Rect2()


	# Find shape
	var shape := collision.shape as RectangleShape2D
	if(shape == null):
		return Rect2()


	# Set left & right bounds
	var platform_left := collision.global_position.x - shape.size.x / 2.0
	var platform_right := collision.global_position.x + shape.size.x / 2.0

	return Rect2(Vector2(platform_left, 0), Vector2(platform_right - platform_left, 0))


# Override Methods
func _process(_delta: float) -> void:

	# Flip Skin
	if skin_node:
		if velocity.x < 0:
			skin_node.scale.x = -abs(skin_node.scale.x)
		elif velocity.x > 0:
			skin_node.scale.x = abs(skin_node.scale.x)


	
	# Play Animations
	if(attack_act.is_active() || damage_act.is_active()):  # Attack or Damaged
		pass
	elif(patrol_act.is_active() || chase_act.is_active()):  # Walking
		animation_player.play(walk_anim)
	elif(!is_on_floor()):  # Falling
		animation_player.play(falling_anim)
	else:  # Idle
		animation_player.play(idle_anim)
func _ready() -> void:

	# Get player
	_player = find_player(get_tree().current_scene)
	if(_player == null || !is_instance_valid(_player)):
		push_warning("[BiterSpider] Cannot setup, _player not found!")
		return

	_player.on_platform_changed.connect(func (_old_platform, new_platform):

		# Skip if player no longer valid
		if(!is_instance_valid(_player)):
			push_warning("[BiterSpider] Skipping platform change, player no longer valid!")
			return


		# Don't reconsider if player in air or jumped onto same platform
		var player_prev_platform = _player.get_prev_platform()
		if(new_platform == null):
			return


		# Make spider reconsider life choices
		var self_platform = get_platform()
		if(new_platform == self_platform || self_platform == player_prev_platform):
			live_act.retry()
			return
	)


	# Setup chase target
	chase_act.target = _player
	chase_act.timeout_duration = -1.0
	chase_act.acceptance_radius = attack_radius
	chase_act.init("Chase Act", theater)


	# Setup Live
	live_act.prologue = func(_act: Act):

		# Do nothing if falling or in air
		if(!is_on_floor()):
			wait_act.duration = reaction_delay
			return [wait_act]


		# Goto player & attack if on same platform
		var is_player_valid =  is_instance_valid(_player)
		var self_platform = get_platform()
		var player_platform = _player.get_platform() if is_player_valid else null
		if(is_player_valid && self_platform == player_platform):
			chase_act.bounds = get_chase_bounds()
			chase_act.use_bounds = true
			return Act.seq([
				[chase_act] if !in_attack_range(_player) else [],
				[attack_delay_act],
				[attack_act]
			])
		

		# Patrol on random points if player not on same platform
		patrol_act.target_location = random_point_on_platform()
		wait_act.duration = randf_range(wait_duration_min, wait_duration_max)
		return Act.seq([
			[patrol_act],
			[wait_act]
		])
	live_act.init("Live Act", theater)


	# Setup Wait
	wait_act.init("Wait Act", theater)


	# Setup Patrol
	patrol_act.init("Goto Act", theater)


	# Setup Attack
	attack_act.target = _player
	attack_act.animation_player = animation_player
	attack_act.animation_name = attack_anim
	attack_act.on_pre_enter.connect(func(act: Act):
		if(is_instance_valid(_player) && !in_attack_range(_player)):
			act.abort()
	)
	attack_act.on_post_enter.connect(func(_act: Act):

		# Skip venom if not venomous or player no longer valid
		if(!is_venomous || !is_instance_valid(_player)):
			return


		# Skip if no venom scene assigned
		if(venom_scene == null):
			push_warning("[BiterSpider] Cannot spawn venom, venom_scene not assigned!")
			return


		var venom := venom_scene.instantiate()
		_player.add_child(venom)
	)
	attack_act.init("Attack Act", theater)


	# Setup Attack Delay
	attack_delay_act.duration = attack_delay
	attack_delay_act.init("Attack Delay Act", theater)


	# Setup Damage
	damage_act.health_system = _health_system
	damage_act.animation_player = animation_player
	damage_act.animation_name = damaged_anim
	damage_act.add_to_block([live_act])
	damage_act.init("Damage Act", theater)
func _exit_tree():

	# Deinit all acts to clean up properly
	live_act.deinit()
	patrol_act.deinit()
	chase_act.deinit()
	wait_act.deinit()
	attack_act.deinit()
	attack_delay_act.deinit()
	damage_act.deinit()
