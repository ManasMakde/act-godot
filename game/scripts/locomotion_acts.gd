class_name LocomotionActs


# Player Acts
class MoveAct extends Act:
	
	# Public
	var speed := 100.0
	var direction := 0.0

	func _can_perform():
		return !is_zero_approx(direction)
	func _enter():
		get_owner().velocity.x = direction * speed
		return Outcome.SUCCESS
	func _exit():
		direction = 0.0
class JumpAct extends Act:
	
	# Public
	var speed := -400.0
	var direction := Vector2.ZERO

	func _can_perform():
		return get_owner().is_on_floor()
	func _enter():
		get_owner().velocity.y = speed
		return Outcome.SUCCESS
