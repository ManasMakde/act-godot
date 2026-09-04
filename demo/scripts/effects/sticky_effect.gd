class_name StickyEffect extends Effect


# Public Properties
@export var sprite: Sprite2D
@export var sprite_offset := Vector2(3.0, 45.0)
@export var sprite_scale := Vector2(0.55, 0.55)
@export var stuck_duration: float = 3.0


# Private Properties
var _character: CharacterBody2D
var _timer: Timer
var _is_ending: bool = false


# Private Methods
func _untrap_and_destroy():

	# Mark self as ending before checking siblings
	_is_ending = true


	# Skip unstick if another non ending sticky exists
	if(is_instance_valid(_target)):
		for sibling in _target.get_children():
			if sibling is StickyEffect && sibling != self && !sibling._is_ending:
				queue_free()
				return


	# Enable target movement
	if is_instance_valid(_target):
		_target.set_movement_enabled(true)


	queue_free()


# Override Methods
func _physics_process(_delta: float) -> void:
	if(_character != null):
		sprite.visible = _character.is_on_floor()
func _ready():
	
	super._ready()

	
	# If invalid target or movement cannot be disabled then remove self
	if(_target == null || !is_instance_valid(_target) || !_target.has_method("set_movement_enabled")):
		queue_free()
		return


	# Disable target movement
	if is_instance_valid(_target):
		_target.set_movement_enabled(false)


	# Setup character
	_character = _target as CharacterBody2D


	# Setup sprite
	sprite.position = sprite_offset
	sprite.scale = sprite_scale


	# Create timer
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_untrap_and_destroy)
	add_child(_timer)
	_timer.start(stuck_duration)
