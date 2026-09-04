class_name ShooterSpider extends PlatformCharacter


# Public Properties
@export var web_origin_node: Node2D
@export var shoot_origin_node: Node2D
@export var projectile_scene: PackedScene
@export var web_line_scene: PackedScene
@export var shot_count: int = 3
@export var shot_interval: float = 1.0
@export_range(0.0, 1.0) var pull_height_min_percent: float = 0.2
@export_range(0.0, 1.0) var pull_height_max_percent: float = 0.8
@export var pull_speed: float = 300.0
@export var max_ray_distance: float = 500.0
@export var speed: float = 100.0
@export var reaction_delay: float = 0.5
@export var patrol_delay: float = 0.5
@export var skin_node: Node2D


# Animation Properties
@export var animation_player: AnimationPlayer
@export var idle_anim := "idle"
@export var walk_anim := "walk"
@export var damaged_anim := "damaged"
@export var hanging_anim := "hanging"
@export var falling_anim := "falling"


# Act Properties
@onready var theater: Theater = $Theater
var live_act := GeneralActs.PerpetualAct.new()
var goto_act := GeneralActs.GotoAct.new()
var shoot_line_act := GeneralActs.ShootAct.new()
var climb_act := GeneralActs.GotoAct.new()
var levitate_act := GeneralActs.LevitateAct.new()
var shoot_act := GeneralActs.ShootAct.new()
var wait_act := GeneralActs.WaitAct.new()
var damage_act := GeneralActs.DamageAct.new()


# Private Properties
var _health_system := HealthSystem.new()
var _player: Player
var _web_line_projectile: Projectile = null  # tracks spawned web line to free and query later
var _web_did_hit: bool = false  # tracks if web line hit something
var _web_hit_position: Vector2 = Vector2.ZERO  # tracks where web line hit


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
func is_player_stuck() -> bool:

	# fail if no valid player to check
	if(!is_instance_valid(_player)):
		return false

	# check if player has a sticky effect node
	for child in _player.get_children():
		if(child is StickyEffect):
			return true

	return false


# Override Methods
func _process(_delta: float) -> void:

	# Flip Skin
	if skin_node:
		if velocity.x < 0:
			skin_node.scale.x = -abs(skin_node.scale.x)
		elif velocity.x > 0:
			skin_node.scale.x = abs(skin_node.scale.x)


	
	# Play Animations
	if(damage_act.is_active() && damage_act.to_animate):  # Damaged
		pass
	elif(goto_act.is_active()):  # Walking
		animation_player.play(walk_anim)
	elif(climb_act.is_active() || levitate_act.is_active()):  # Hanging
		animation_player.play(hanging_anim)
	elif(!is_on_floor()):  # Falling
		animation_player.play(falling_anim)
	else:  # Idle
		animation_player.play(idle_anim)
func _ready() -> void:

	# Get player
	_player = find_player(get_tree().current_scene)
	if(_player == null || !is_instance_valid(_player)):
		push_warning("[ShooterSpider] Cannot setup, _player not found!")
		return


	# Setup Live
	live_act.prologue = func(_act: Act):

		# Wait while still falling before starting a new cycle
		if(!is_on_floor()):
			wait_act.duration = reaction_delay
			return [wait_act]


		# Levitate only as long as the burst shoot needs to fire
		levitate_act.duration = (shoot_act.shoot_count - 1) * shoot_act.shoot_interval


		# Goto random point, shoot web up, climb it, then burst shoot at player
		goto_act.target_location = random_point_on_platform()


		# Check if player is stuck
		var player_stuck := is_player_stuck()
		wait_act.duration = patrol_delay


		return Act.seq([
			[goto_act],
			[shoot_line_act] if !player_stuck else [wait_act],
			[climb_act] if !player_stuck else [],
			[levitate_act, shoot_act] if !player_stuck else [],
		])
	live_act.init("Live Act", theater)


	# Setup Wait
	wait_act.init("Wait Act", theater)


	# Setup Goto
	goto_act.speed = speed
	goto_act.init("Goto Act", theater)


	# Setup Shoot web line
	shoot_line_act.spawn_node = web_origin_node
	shoot_line_act.projectile_scene = web_line_scene
	shoot_line_act.to_exit_on_impact = true
	shoot_line_act.on_pre_enter.connect(func(_act):

		# aim straight up from current position each time it fires
		shoot_line_act.target_location = global_position + Vector2.UP * max_ray_distance


		# reset tracked hit state for new shot
		_web_did_hit = false
		_web_hit_position = Vector2.ZERO
	)
	shoot_line_act.on_projectile_spawned.connect(func(projectile: Projectile):

		# skip tracking if spawned projectile invalid
		if(!is_instance_valid(projectile)):
			push_warning("[ShooterSpider] Cannot track web line, projectile invalid!")
			return


		# track spawned web line so it can be freed and queried later
		_web_line_projectile = projectile
		projectile.on_impact.connect(func(_proj, _other):
			_web_did_hit = true
			_web_hit_position = projectile.global_position
		)
	)
	shoot_line_act.on_pre_exit.connect(func(_act):

		# skip if nothing was found to attach to
		if(!_web_did_hit):
			return

		# pick a random percent of the hit distance to climb up
		var hit_distance := global_position.distance_to(_web_hit_position)
		var pull_height_percent = clamp(randf_range(pull_height_min_percent, pull_height_max_percent), 0.0, 1.0)
		climb_act.target_location = global_position + Vector2.UP * (pull_height_percent * hit_distance)
	)
	shoot_line_act.init("Shoot Web Act", theater)


	# Setup Climb
	climb_act.speed = pull_speed
	climb_act.only_move_horizontal = false
	climb_act.init("Climb Act", theater)


	# Setup Levitate
	levitate_act.on_perform_end.connect(func(_act):

		# Web is no longer needed once levitate ends
		if(_web_line_projectile != null && is_instance_valid(_web_line_projectile)):
			_web_line_projectile.queue_free()
		_web_line_projectile = null
	)
	levitate_act.duration = -1.0
	levitate_act.init("Levitate Act", theater)


	# Setup Shoot
	shoot_act.target_node = _player
	shoot_act.spawn_node = shoot_origin_node
	shoot_act.projectile_scene = projectile_scene
	shoot_act.shoot_count = shot_count
	shoot_act.shoot_interval = shot_interval
	shoot_act.on_post_exit.connect(func(_act):
		levitate_act.abort()
	)
	shoot_act.init("Shoot Act", theater)


	# Setup Damage
	damage_act.health_system = _health_system
	damage_act.animation_player = animation_player
	damage_act.animation_name = damaged_anim
	damage_act.on_pre_enter.connect(func (_act):
		damage_act.to_animate = is_on_floor() # Do not animate damage when in air
	)
	damage_act.add_to_block([live_act])
	damage_act.init("Damage Act", theater)
func _exit_tree():

	# Deinit all acts to clean up properly
	live_act.deinit()
	goto_act.deinit()
	shoot_line_act.deinit()
	climb_act.deinit()
	levitate_act.deinit()
	shoot_act.deinit()
	wait_act.deinit()
	damage_act.deinit()
