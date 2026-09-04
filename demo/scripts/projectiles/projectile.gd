class_name Projectile extends Area2D


# Public Signals
signal on_impact(projectile: Projectile, other: Node2D)


# Public Properties
@export var speed := 2000.0
@export var lifetime := 5.0
@export var ignore_classes: Array[GDScript]
@export var ignore_nodes: Array[Node2D]
@export var to_ignore_instigator: bool = true


# Private Properties
var _consume_on_impact: bool = true
var _instigator: Node2D = null
var _expiration_timer: SceneTreeTimer


# Public Properties
func set_instigator(new_instigator: Node2D):
	_instigator = new_instigator


# Protected Methods
func _to_ignore(other: Node2D) -> bool:

	# Ignore if null
	if(other == null):
		return true


	# Ignore if instigator
	if(to_ignore_instigator && other == _instigator):
		return true


	# Ignore if in ignore list
	if(ignore_nodes.has(other)):
		return true


	# ignore if of ignore class
	var other_script = other.get_script()
	if(other_script != null && ignore_classes.has(other_script)):
		return true


	return false
func _on_impact(_other:Node2D):
	pass


# Private Methods
func _on_impact_impl(other: Node2D):

	# Return if to ignore
	if(_to_ignore(other)):
		return


	# Invoke actual impact functionality
	_on_impact(other)
	on_impact.emit(self, other)


	# Delete on impact
	if(_consume_on_impact):
		queue_free()


# Override Methods
func _physics_process(delta: float):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta
func _ready():

	# Bind to collision signals
	body_entered.connect(_on_impact_impl)
	area_entered.connect(_on_impact_impl)


	# Create expiration timer
	if(lifetime > 0):
		_expiration_timer = get_tree().create_timer(lifetime)
		_expiration_timer.timeout.connect(queue_free)
