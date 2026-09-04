class_name PlatformCharacter extends CharacterBody2D


# Signals
signal on_platform_changed(old_platform: StaticBody2D, new_platform: StaticBody2D)


# Public Properties
@export var gravity: float = 980
@export var is_gravity_enabled := true


# Protected Properties
var _platform: StaticBody2D
var _prev_platform: StaticBody2D  # Last non null platform character was standing on


# Public Methods
func get_platform() -> StaticBody2D:
	return _platform
func get_prev_platform() -> StaticBody2D:
	return _prev_platform


# Protected methods
func random_point_on_platform() -> Vector2:

	# Ray trace which StaticBody2D is below
	if(_platform == null):
		return global_position


	# Find random point along x axis of platform & y of self
	var collision_shape := _platform.get_node("CollisionShape2D") as CollisionShape2D
	if(collision_shape == null):
		push_warning("[BiterSpider] Cannot find random point, no collision shape on platform!")
		return global_position

	var shape := collision_shape.shape as RectangleShape2D
	if(shape == null):
		push_warning("[BiterSpider] Cannot find random point, platform shape is not a rectangle!")
		return global_position

	var platform_left := collision_shape.global_position.x - shape.size.x / 2.0
	var platform_right := collision_shape.global_position.x + shape.size.x / 2.0

	return Vector2(randf_range(platform_left, platform_right), global_position.y)
func set_platform(new_platform: StaticBody2D):

	# Return if trying to reassign same value
	if(new_platform == _platform):
		return
	

	# Store previous non null platform
	var old_platform = _platform
	if(old_platform != null):
		_prev_platform = old_platform
	

	_platform = new_platform
	on_platform_changed.emit(old_platform, _platform)
func calc_platform() -> StaticBody2D:

	# Return null if in air
	if !is_on_floor():
		return null


	# Check if colliding with any StaticBody2D
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is StaticBody2D && collision.get_normal().dot(Vector2.UP) > 0.7:
			return collider
	
	return null


# Override Methods
func _physics_process(delta: float) -> void:

	# Gravity
	if(is_gravity_enabled):
		velocity.y += gravity * delta
	

	# Apply physics
	move_and_slide()


	# Calculate which platform currently standing on 
	var new_platform = calc_platform()
	set_platform(new_platform)
