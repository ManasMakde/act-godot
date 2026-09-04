extends Node2D


# Public Properties
@export var in_play_mode: bool = true
@export var spider_scenes: Array[PackedScene] = []
@export var min_spiders_per_platform: int = 1
@export var spawn_limit: int = 20
@export var min_spawn_count: int = 1
@export var max_spawn_count: int = 3
@export var min_platform_count: int = 1
@export var max_platform_count: int = 3
@export var spawn_interval_min: float = 5.0
@export var spawn_interval_max: float = 10.0
@export var spawn_margin: float = 8.0
@export var spawn_on_start: bool = true
@export var platform_group_name: String = "platform"


# UI Properties
@export var opening_screen_ui: Control
@export var score_ui: Control
@export var game_over_ui: Control
@export var start_button: Button
@export var restart_button: Button
@export var points_label: Label


# Private Properties
var _player: Player
var _is_game_over := false
var _current_spider_count := 0
var _score := 0
var _platform_spider_counts: Dictionary[StaticBody2D, int] = {}


# Private Methods
func find_player(node: Node) -> Player:
	if node is Player:
		return node

	for child in node.get_children():
		var result = find_player(child)
		if result:
			return result
	return null
func get_platform_bounds(platform: StaticBody2D) -> Rect2:

	# Return empty rect if platform invalid
	if(platform == null || !is_instance_valid(platform)):
		push_warning("[GameManager] Cannot get bounds, platform is invalid!")
		return Rect2()


	# Return empty rect if no collision shape found
	var collision_shape := platform.get_node("CollisionShape2D") as CollisionShape2D
	if(collision_shape == null):
		push_warning("[GameManager] Cannot get bounds, no collision shape on platform!")
		return Rect2()

	var shape := collision_shape.shape as RectangleShape2D
	if(shape == null):
		push_warning("[GameManager] Cannot get bounds, platform shape is not a rectangle!")
		return Rect2()

	var platform_left := collision_shape.global_position.x - shape.size.x / 2.0
	var platform_right := collision_shape.global_position.x + shape.size.x / 2.0
	var platform_top := collision_shape.global_position.y - shape.size.y / 2.0

	return Rect2(Vector2(platform_left, platform_top), Vector2(platform_right - platform_left, 0))
func get_spider_half_extents(spider: Node2D) -> Vector2:

	# Return zero extents if spider invalid
	if(spider == null || !is_instance_valid(spider)):
		push_warning("[GameManager] Cannot get spider extents, spider is invalid!")
		return Vector2.ZERO


	# Return zero extents if no collision shape found
	var collision_shape := spider.get_node("CollisionShape2D") as CollisionShape2D
	if(collision_shape == null):
		push_warning("[GameManager] Cannot get spider extents, no collision shape found!")
		return Vector2.ZERO

	var shape := collision_shape.shape as RectangleShape2D
	if(shape == null):
		push_warning("[GameManager] Cannot get spider extents, spider shape is not a rectangle!")
		return Vector2.ZERO

	return shape.size / 2.0
func spawn_spider_on_platform(bounds: Rect2, platform: StaticBody2D):

	# Return if no spider scenes assigned
	if(spider_scenes.is_empty()):
		push_warning("[GameManager] Cannot spawn spider, no spider scenes assigned!")
		return

	var scene_index := randi() % spider_scenes.size()
	var spider := spider_scenes[scene_index].instantiate() as Node2D


	# Return if instantiate failed or wrong type
	if(spider == null):
		push_warning("[GameManager] Cannot spawn spider, instantiate failed!")
		return

	add_child(spider)

	var half_extents := get_spider_half_extents(spider)
	var spawn_left := bounds.position.x + half_extents.x
	var spawn_right := bounds.position.x + bounds.size.x - half_extents.x
	var spawn_y := bounds.position.y - half_extents.y - spawn_margin

	# Track spider so count and score update on death
	_current_spider_count += 1
	_platform_spider_counts[platform] = _platform_spider_counts.get(platform, 0) + 1
	var health_system = spider.get("_health_system")
	if(health_system == null):
		push_warning("[GameManager] Cannot track spider death, no health system found!")
	else:
		health_system.on_health_changed.connect(func (_old_health, new_health):
			if(is_zero_approx(new_health)):
				_current_spider_count -= 1
				_platform_spider_counts[platform] = _platform_spider_counts.get(platform, 0) - 1
				add_score(1)
		)

	# Fallback to platform center if platform is narrower than spider
	if(spawn_left > spawn_right):
		spider.global_position = Vector2(bounds.position.x + bounds.size.x / 2.0, spawn_y)
		return

	var spawn_x := randf_range(spawn_left, spawn_right)
	spider.global_position = Vector2(spawn_x, spawn_y)
func spawn_spiders_on_platform(platform: StaticBody2D):

	# Return if platform invalid
	if(platform == null || !is_instance_valid(platform)):
		push_warning("[GameManager] Cannot spawn spiders, platform is invalid!")
		return

	var bounds := get_platform_bounds(platform)

	# Return if bounds could not be determined
	if(bounds.size.x <= 0.0):
		push_warning("[GameManager] Cannot spawn spiders, invalid platform bounds!")
		return

	var spawn_count := randi_range(min_spawn_count, max_spawn_count)
	for i in range(spawn_count):

		# Break if max spiders reached
		if(_current_spider_count >= spawn_limit):
			break

		spawn_spider_on_platform(bounds, platform)
func ensure_min_spiders_on_all_platforms():
	var platforms := get_tree().get_nodes_in_group(platform_group_name)

	# Return if no platforms found
	if(platforms.is_empty()):
		push_warning("[GameManager] Cannot ensure min spiders, no platforms found in group!")
		return

	for platform_node in platforms:
		var platform := platform_node as StaticBody2D
		var current_count = _platform_spider_counts.get(platform, 0)

		# Skip if platform already meets minimum
		if(current_count >= min_spiders_per_platform):
			continue

		var bounds := get_platform_bounds(platform)

		# Skip if bounds invalid
		if(bounds.size.x <= 0.0):
			push_warning("[GameManager] Cannot ensure min spiders, invalid platform bounds!")
			continue

		# Spawn missing spiders ignoring max spiders cap
		var needed_count = min_spiders_per_platform - current_count
		for i in range(needed_count):
			spawn_spider_on_platform(bounds, platform)
func spawn_on_random_platforms():

	# Guarantee every platform meets its minimum first
	ensure_min_spiders_on_all_platforms()

	var platforms := get_tree().get_nodes_in_group(platform_group_name)

	# Return if no platforms found
	if(platforms.is_empty()):
		push_warning("[GameManager] Cannot spawn spiders, no platforms found in group!")
		return

	platforms.shuffle()
	var platform_count := randi_range(min_platform_count, min(max_platform_count, platforms.size()))

	for i in range(platform_count):
		spawn_spiders_on_platform(platforms[i] as StaticBody2D)
func start_spawn_loop():
	while not _is_game_over:
		var wait_time := randf_range(spawn_interval_min, spawn_interval_max)
		await get_tree().create_timer(wait_time).timeout

		# Stop loop if game ended while waiting
		if(_is_game_over):
			return

		spawn_on_random_platforms()
func add_score(amount: int):
	_score += amount

	if(points_label != null):
		points_label.text = str(_score)
	else:
		push_warning("[GameManager] Cannot update score label, not assigned!")
func freeze_game():
	_is_game_over = true
	var tree = get_tree()
	if(tree != null):
		tree.paused = true
func show_game_over():
	freeze_game()

	if(game_over_ui != null):
		game_over_ui.show()
	else:
		push_warning("[GameManager] Cannot show game over ui, not assigned!")
func start_game():

	# Unfreeze and reset game state
	_is_game_over = false
	_current_spider_count = 0
	_platform_spider_counts.clear()
	get_tree().paused = false


	# Reset score
	add_score(-_score)


	# Switch ui to score screen
	if(opening_screen_ui != null):
		opening_screen_ui.hide()
	else:
		push_warning("[GameManager] Cannot hide opening screen, not assigned!")

	if(score_ui != null):
		score_ui.show()
	else:
		push_warning("[GameManager] Cannot show score ui, not assigned!")


	# Spawn first wave instantly if enabled
	if(spawn_on_start):
		spawn_on_random_platforms()


	# Keep spawning on random interval
	start_spawn_loop()
func _on_start_pressed():
	start_game()
func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()


# Override Methods
func _ready():

	# Skip if not in play mode
	if(!in_play_mode):
		return
	

	# Get player
	_player = find_player(get_tree().current_scene)


	# Return if player missing
	if(_player == null || !is_instance_valid(_player)):
		push_warning("[GameManager] Cannot setup game manager, player not found!")
		return


	# Show game over ui when player dies
	_player.tree_exited.connect(func ():
		show_game_over()
	)


	# Hide game over ui until player dies
	if(game_over_ui != null):
		game_over_ui.hide()
	else:
		push_warning("[GameManager] Cannot hide game over ui, not assigned!")


	# Hide score ui until game starts
	if(score_ui != null):
		score_ui.hide()
	else:
		push_warning("[GameManager] Cannot hide score ui, not assigned!")


	# Show opening screen and freeze until player presses start
	if(opening_screen_ui != null):
		opening_screen_ui.show()
	else:
		push_warning("[GameManager] Cannot show opening screen, not assigned!")

	get_tree().paused = true


	# Let start button work while game is paused
	if(start_button != null):
		start_button.process_mode = Node.PROCESS_MODE_ALWAYS
		start_button.pressed.connect(_on_start_pressed)
	else:
		push_warning("[GameManager] Cannot connect start button, not assigned!")


	# Let restart button work while game is paused
	if(restart_button != null):
		restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
		restart_button.pressed.connect(_on_restart_pressed)
	else:
		push_warning("[GameManager] Cannot connect restart button, not assigned!")
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
