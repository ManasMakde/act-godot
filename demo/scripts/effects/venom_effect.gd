class_name VenomEffect extends Effect


# Public Properties
@export var damage_count: int = 3  # Negative means infinite
@export var damage_delay: float = 1.0
@export var damage_amount: float = 2.0
@export var damage_interval: float = 1.0


# Private Properties
var _timer: Timer
var _inflict_count: int = 0  # Number of times damage delt so far


# Private Methods
func _damage_target():

	# Free when limit reached
	if(0 <= damage_count && damage_count <= _inflict_count):
		queue_free()
		return


	# Skip damage if target no longer valid
	if(!is_instance_valid(_target)):
		push_warning("[VenomEffect] Cannot damage, target no longer valid!")
		queue_free()
		return


	# Inflict damage
	_target.damage(damage_amount)
	_inflict_count += 1


# Override Methods
func _ready():
	
	super._ready()

	# If invalid target or cannot be damaged then remove self
	if(!is_instance_valid(_target) || !_target.has_method("damage")):
		push_warning("[VenomEffect] Cannot setup, target invalid or missing damage method!")
		queue_free()
		return


	# Setup repeating timer
	_timer = Timer.new()
	_timer.wait_time = damage_interval
	_timer.timeout.connect(_damage_target)
	add_child(_timer)


	# Start after delay
	var delay_timer := get_tree().create_timer(damage_delay)
	delay_timer.timeout.connect(_timer.start)
