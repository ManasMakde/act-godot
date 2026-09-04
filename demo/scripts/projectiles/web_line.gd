class_name WebLine extends Projectile


# Public Properties
@export var web_width := 4.0
@export var web_color := Color.WHITE
@export var skin: Node


# Private Properties
var _web_line: Line2D
var _movement_enabled: bool = true


# Private Methods
func _update_web_line():

	# Skip if nothing to be updated or instigator no longer valid
	if(_web_line == null || _instigator == null || !is_instance_valid(_instigator)):
		return


	# Update line points position
	_web_line.set_point_position(0, _instigator.global_position)
	_web_line.set_point_position(1, global_position)


# Override Methods
func _on_impact(_other:Node2D):

	# Remove timer 
	if(_expiration_timer != null):
		_expiration_timer.timeout.disconnect(queue_free)


	# Stop movement & collisions
	_movement_enabled = false
	set_deferred("monitorable", false)


	# Stop from being removed
	_consume_on_impact = false


	# Hide projectile sprite
	# skin.visible = false
func _to_ignore(other: Node2D) -> bool:
	return !(other is StaticBody2D)  # Ignore everything else except static bodies
func _physics_process(delta: float):

	# Move ahead
	if(_movement_enabled):
		super._physics_process(delta)


	# Keep web line updated
	_update_web_line()
func _ready():
	super._ready()

	# Create line
	_web_line = Line2D.new()
	_web_line.z_index = -1
	_web_line.width = web_width
	_web_line.default_color = web_color
	get_tree().current_scene.add_child(_web_line)


	# Add 2 points to line
	var is_instigator_valid := _instigator != null && is_instance_valid(_instigator)
	_web_line.add_point(_instigator.global_position if is_instigator_valid else global_position)
	_web_line.add_point(global_position)


	# Update web line position
	_update_web_line()
func _exit_tree():

	# Remove line
	if(is_instance_valid(_web_line)):
		_web_line.queue_free()
