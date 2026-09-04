class_name Effect extends Node2D


# Private Properties
var _target: Node = null


# Public Methods
func set_target(new_target: Node):
	_target = new_target


# Override Methods
func _ready():
	
	# Set target if unassigned
	if (_target == null):
		_target = get_parent()
