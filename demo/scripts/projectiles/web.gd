class_name Web extends Projectile


# Public Properties
@export var sticky_scene: PackedScene = null


# Override Methods
func _on_impact(other:Node2D):

	# Return if invalid other or no sticky effect provided
	if(!is_instance_valid(other) || sticky_scene == null):
		return
	
	# Attach sticky effect
	var sticky := sticky_scene.instantiate()
	other.add_child(sticky)
func _ready():
	super._ready()

	ignore_classes.append(Web)
