class_name HealthSystem


# Public Signals
signal on_health_changed(old_health: float, new_health: float)


# Private Properties
var _max_health := 100.0
var _current_health := 100.0


# Public Methods
func get_health() -> float:
	return _current_health
func reduce_health(amount: float) -> void:

	# Return if trying to reassign
	var old_health = _current_health
	var new_health = max(_current_health - amount, 0.0)
	if (is_equal_approx(old_health, new_health)):
		return


	# Assign & emit
	_current_health = new_health
	on_health_changed.emit(old_health, new_health)
func increase_health(amount: float) -> void:
	
	# Return if trying to reassign
	var old_health = _current_health
	var new_health = min(_current_health + amount, _max_health)
	if (is_equal_approx(old_health, new_health)):
		return


	# Assign & emit
	_current_health = new_health
	on_health_changed.emit(old_health, new_health)
