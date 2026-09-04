class_name Bullet extends Projectile


# Public Properties
@export var damage_amount := 10.0


# Override Methods
func _on_impact(other: Node2D):

    if(!is_instance_valid(other) || !other.has_method("damage")):
        return

    other.damage(damage_amount)
