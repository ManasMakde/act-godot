class_name GeneralActs


# Player Acts
class PerpetualAct extends Act:

	# public properties
	var to_perpetuate := true


	# override methods
	func _setup():
		_can_reperform = true

		on_perform_end.connect(func (_act):
			if (to_perpetuate):
				perform_deferred()
		)

		if (to_perpetuate):
			perform_deferred()
	func _unblock_self(by_act:Act):
		super(by_act)
		
		if (to_perpetuate && !is_blocked()):
			perform_deferred()
class MoveAct extends Act:
	
	# Public
	var speed := 100.0
	var direction := 0.0


	# Private
	var _owner: CharacterBody2D


	func _setup():
		_owner = get_owner()
	func _can_perform():
		return !is_zero_approx(direction)
	func _enter():

		# fail if owner missing
		if(_owner == null):
			push_warning("[MoveAct] Cannot move, owner not found!")
			return Outcome.FAILURE

		_owner.velocity.x = direction * speed
		return Outcome.SUCCESS
	func _exit():
		direction = 0.0
class JumpAct extends Act:
	
	# Public
	var speed := -400.0
	var direction := Vector2.ZERO


	# Private
	var _owner: CharacterBody2D


	func _setup():
		_owner = get_owner()
	func _can_perform():

		# fail if owner missing
		if(_owner == null):
			push_warning("[JumpAct] Cannot jump, owner not found!")
			return false

		return _owner.is_on_floor()
	func _enter():

		# fail if owner missing
		if(_owner == null):
			push_warning("[JumpAct] Cannot jump, owner not found!")
			return Outcome.FAILURE

		_owner.velocity.y = speed
		return Outcome.SUCCESS
class LookAct extends Act:

	# Public
	var target: Node2D = null   # Node to look towards
	var target_location := Vector2.ZERO  # Fallback location to look towards
	var subject: Node2D = null  # Node which is to be rotated


	# Protected
	func _enter() -> Outcome:

		# fail if no effected node assigned
		if(subject == null):
			push_warning("[LookAct] Cannot look, subject not assigned!")
			return Outcome.FAILURE


		# Rotate towards target
		var look_pos := target.global_position if target != null else target_location
		subject.global_rotation = (look_pos - subject.global_position).angle()

		return Outcome.SUCCESS
class ShootAct extends Act:

	# Public Signals
	signal on_projectile_spawned(projectile: Projectile)


	# Public Properties
	var spawn_node: Node2D = null  # Node at which to spawn projectile
	var spawn_location := Vector2.ZERO  # Fallback location at which to spawn projectile
	var aim_node: Node2D = null  # Node used to calc shoot direction
	var target_node: Node2D = null  # Node towards which to shoot projectile
	var target_location := Vector2.ZERO  # Fallback location towards which to shoot projectile
	var projectile_scene: PackedScene = null
	var shoot_count := 1  # How many times to fire
	var shoot_interval := 0.3  # After what intervals to fire
	var to_exit_on_impact := false  # If true act will exit when impacted not after all projectiles have been fired


	# Private Properties
	var _spawned_projectiles: Array[Node2D] = []
	var _projectiles_shot_count := 0
	var _next_shoot_timer: SceneTreeTimer
	var _owner: Node


	# Private Methods
	func _shoot_projectile():

		# fail if owner missing
		if(_owner == null):
			push_warning("[ShootAct] Cannot shoot, owner not found!")
			_finish(Outcome.FAILURE)
			return


		# Calculate spawn position & aim origin
		var spawn_pos := spawn_node.global_position if spawn_node != null else spawn_location
		var aim_pos := aim_node.global_position if aim_node != null else spawn_pos
		var direction := (target_node.global_position if target_node != null else target_location) - aim_pos


		# Fail if no valid direction
		if(direction.is_zero_approx()):
			push_warning("[ShootAct] Cannot shoot projectile, No valid aim direction!")
			_finish(Outcome.FAILURE)
			return


		# spawn projectile
		var projectile := projectile_scene.instantiate()
		projectile.global_position = spawn_pos
		projectile.rotation = direction.angle()
		projectile.set_instigator(_owner)
		_owner.get_tree().current_scene.add_child(projectile)
		_spawned_projectiles.append(projectile)


		# Increment projectile count
		_projectiles_shot_count += 1


		# Emit projectile spawned
		on_projectile_spawned.emit(projectile)

		
		# If last projectile
		if(shoot_count <= _projectiles_shot_count):
			
			# Wait for impact before finishing
			if(to_exit_on_impact):  
				projectile.on_impact.connect(_on_projectile_impact)
			else:
				_finish(Outcome.SUCCESS)
			
			return


		# Wait before shooting next projectile
		_next_shoot_timer = _owner.get_tree().create_timer(shoot_interval)
		_next_shoot_timer.timeout.connect(_shoot_projectile)
	func _on_projectile_impact(projectile: Node2D, _other: Node2D):

		# Skip if projectile not tracked
		if(!_spawned_projectiles.has(projectile)):
			return

		_finish(Outcome.SUCCESS)

	
	# Override Methods
	func _setup():
		_owner = get_owner()
	func _can_perform() -> bool:

		# fail if no projectile scene assigned
		if(projectile_scene == null):
			push_warning("[ShootAct] Cannot shoot, no projectile scene assigned!")
			return false


		# fail if shot count not positive
		if(shoot_count <= 0):
			push_warning("[ShootAct] Cannot shoot, shot count must be positive!")
			return false

		return true
	func _enter() -> Outcome:
		_projectiles_shot_count = 0
		_spawned_projectiles.clear()
		_shoot_projectile()
		return Outcome.PENDING
	func _exit():

		# disconnect timer if still pending
		if(_next_shoot_timer != null && _next_shoot_timer.timeout.is_connected(_shoot_projectile)):
			_next_shoot_timer.timeout.disconnect(_shoot_projectile)
		_next_shoot_timer = null


		# disconnect projectile impact if still pending
		for spawned_projectile in _spawned_projectiles:
			if(is_instance_valid(spawned_projectile) && spawned_projectile.on_impact.is_connected(_on_projectile_impact)):
				spawned_projectile.on_impact.disconnect(_on_projectile_impact)


# Spider Acts
class AnimAct extends Act:

	# Public Properties
	var animation_player: AnimationPlayer
	var animation_name: String = ""
	var to_animate := true


	# Private Methods
	func _on_animation_finished(anim_name: String):

		# skip if different animation finished
		if(anim_name != animation_name):
			return

		_finish(Outcome.SUCCESS)


	# Override Methods
	func _can_perform() -> bool:

		# fail if animation requested but no player assigned
		if(animation_name != "" && animation_player == null):
			push_warning("[AnimAct] Cannot perform, animation_player not assigned!")
			return false

		return true
	func _enter() -> Outcome:

		# skip if animation disabled
		if(!to_animate):
			return Outcome.SUCCESS


		# skip if no animation requested
		if(animation_name == ""):
			return Outcome.SUCCESS


		# fail if animation missing on player
		if(!animation_player.has_animation(animation_name)):
			push_warning("[AnimAct] Cannot play animation, animation not found!")
			return Outcome.FAILURE

		animation_player.animation_finished.connect(_on_animation_finished)
		animation_player.play(animation_name)
		return Outcome.PENDING
	func _exit():

		# disconnect finished signal if still pending
		if(animation_player != null && animation_player.animation_finished.is_connected(_on_animation_finished)):
			animation_player.animation_finished.disconnect(_on_animation_finished)
			animation_player.stop()
class AttackAct extends AnimAct:

	# Public Properties
	var damage_amount: float = 10.0
	var target: Node


	# Override Methods
	func _can_perform() -> bool:

		# Failed if no target
		if target == null:
			return false


		# Fail if no damage function
		if not target.has_method("damage"):
			return false

		return super._can_perform()
	func _enter() -> Outcome:

		# fail if target no longer valid
		if(!is_instance_valid(target)):
			return Outcome.FAILURE

		target.damage(damage_amount)

		return super._enter()
class DamageAct extends AnimAct:

	# Public Properties
	var health_system: HealthSystem
	var amount: float = 0.0;
	var can_die := true
	var to_flash := true
	var flash_node: CanvasItem = null
	var flash_duration := 0.75
	var flash_interval := 0.25
	var flash_alpha := 0.3  # Transparency


	# Private Properties
	var _flash_tween: Tween = null
	var _original_modulate := Color.WHITE
	var _owner: Node
	var _to_die := false


	# Private Methods
	func _start_flash():

		# fail if flash node missing
		if(flash_node == null):
			push_warning("[DamageAct] Cannot flash, flash_node missing!")
			_finish()
			return


		# Save original modulate
		_original_modulate = flash_node.modulate
		var flashed_modulate := Color(_original_modulate.r, _original_modulate.g, _original_modulate.b, flash_alpha)


		# Tween node transparency
		var loop_count := int(flash_duration / flash_interval)
		_flash_tween = _owner.create_tween()
		_flash_tween.set_loops(loop_count)
		_flash_tween.tween_property(flash_node, "modulate", flashed_modulate, flash_interval * 0.5)
		_flash_tween.tween_property(flash_node, "modulate", _original_modulate, flash_interval * 0.5)
		_flash_tween.finished.connect(_finish)
	func _stop_flash():

		# Stop tween
		if(_flash_tween != null && _flash_tween.is_valid()):
			_flash_tween.kill()
			_flash_tween = null


		# Reset original modulate
		if(to_flash && flash_node != null):
			flash_node.modulate = _original_modulate


	# Override Methods
	func _setup():
		_can_reperform = true
		_owner = get_owner()
		flash_node = _owner if flash_node == null else flash_node
	func _can_perform() -> bool:

		# fail if no health system assigned
		if(health_system == null):
			push_warning("[DamageAct] Cannot perform, no health system assigned!")
			return false


		# Fail if flash requested but no node assigned
		if(to_flash && flash_node == null):
			push_warning("[DamageAct] Cannot perform, flash requested but no flash_node assigned!")
			return false

		return super._can_perform()
	func _enter():

		# fail if owner missing
		if(_owner == null):
			push_warning("[DamageAct] Cannot damage, owner not found!")
			return Outcome.FAILURE

		
		# Reduce health
		health_system.reduce_health(amount)


		# Mark to die if health hit zero
		if(can_die && is_zero_approx(health_system.get_health())):
			_to_die = true


		# Play animation, whichever of flash or anim finishes first wins
		var anim_outcome := super._enter()


		# Start flashing
		if(to_flash):
			_start_flash()
			return Outcome.PENDING

		return anim_outcome
	func _exit():
		_stop_flash()
		super._exit()


		# Queue free owner after anim and flash finished
		if(_to_die):
			_owner.queue_free()
			_to_die = false
class GotoAct extends Act:

	# Public Methods
	var body: CharacterBody2D
	var target: Node2D
	var target_location: Vector2
	var speed: float = 100.0
	var acceptance_radius: float = 4.0
	var timeout_duration: float = 10.0  # Infinite if negative
	var use_bounds := false
	var bounds := Rect2()
	var only_move_horizontal := true


	# Private Properties
	var _timer: SceneTreeTimer


	# Override Methods
	func _setup():
		body = get_owner() if body == null else body
		_tick_flags = TickFlags.PHYSICS_TICK
	func _can_perform() -> bool:

		# Fail if invalid body
		if(!is_instance_valid(body)):
			push_warning("[GotoAct] Cannot perform goto, body is missing!")
			return false


		return true
	func _enter() -> Outcome:

		# Start timeout
		if(body != null && 0 <= timeout_duration):
			_timer = body.get_tree().create_timer(timeout_duration)
			_timer.timeout.connect(_finish)


		# Disable gravity
		if(!only_move_horizontal && body is PlatformCharacter):
			body.is_gravity_enabled = false


		return Outcome.PENDING
	func _physics_tick() -> Outcome:

		# Fail if body no longer valid
		if(!is_instance_valid(body)):
			push_warning("[GotoAct] Cannot tick goto, body no longer valid!")
			return Outcome.FAILURE


		# Move horizontally
		var destination := target.global_position if target != null else target_location
		var direction = sign(destination.x - body.global_position.x)
		body.velocity.x = direction * speed if direction != 0 else move_toward(body.velocity.x, 0, speed)


		# Move vertically
		if(!only_move_horizontal):
			var vertical_direction = sign(destination.y - body.global_position.y)
			body.velocity.y = vertical_direction * speed if vertical_direction != 0 else move_toward(body.velocity.y, 0, speed)


		# Clamp between bounds
		if(use_bounds):
			if(body.global_position.x <= bounds.position.x && body.velocity.x < 0):
				body.velocity.x = 0
			elif(body.global_position.x >= bounds.end.x && body.velocity.x > 0):
				body.velocity.x = 0


		# Finish if reached destination
		if(body.global_position.distance_to(destination) <= acceptance_radius):
			return Outcome.SUCCESS


		return Outcome.PENDING
	func _exit():

		# Stop horizontal movement on exit
		if(body != null && is_instance_valid(body)):
			body.velocity.x = 0

			# Stop vertical velocity too if this was a climb
			if(!only_move_horizontal):
				body.velocity.y = 0


			# Restore gravity if this was a vertical climb
			if(!only_move_horizontal && body is PlatformCharacter):
				body.is_gravity_enabled = true


		# Disconnect timeout timer if still pending
		if(_timer != null && _timer.timeout.is_connected(_finish)):
			_timer.timeout.disconnect(_finish)
		_timer = null
class WaitAct extends Act:

	# Public
	var duration := 1.0


	# Private
	var _timer: SceneTreeTimer
	var _owner: Node


	# Override Methods
	func _setup():
		_owner = get_owner()
	func _can_perform() -> bool:

		# fail if no owner found
		if(_owner == null):
			push_warning("[WaitAct] Cannot wait, no owner found!")
			return false

		return true
	func _enter() -> Outcome:

		# fail if owner missing
		if(_owner == null):
			push_warning("[WaitAct] Cannot wait, no owner found!")
			return Outcome.FAILURE

		_timer = _owner.get_tree().create_timer(duration)
		_timer.timeout.connect(_on_timeout)
		return Outcome.PENDING
	func _exit():

		# Disconnect timer if still pending
		if(_timer != null && _timer.timeout.is_connected(_on_timeout)):
			_timer.timeout.disconnect(_on_timeout)
		_timer = null
	func _on_timeout():
		_finish(Outcome.SUCCESS)
class LevitateAct extends Act:

	# Public Properties
	var duration := 1.0  # Infinite if negative 


	# Private Properties
	var _owner: PlatformCharacter
	var _timer: SceneTreeTimer


	# Override Methods
	func _setup():
		_owner = get_owner()
		_tick_flags = TickFlags.PHYSICS_TICK
	func _can_perform() -> bool:

		# Fail if owner missing
		if(!is_instance_valid(_owner)):
			push_warning("[LevitateAct] Cannot levitate, body is missing!")
			return false

		return true
	func _enter() -> Outcome:

		# Fail if owner no longer valid
		if(!is_instance_valid(_owner)):
			push_warning("[LevitateAct] Cannot levitate, body no longer valid!")
			return Outcome.FAILURE


		# Disable gravity
		if(_owner is PlatformCharacter):
			_owner.is_gravity_enabled = false
		

		# Start timer
		if(0 <= duration):
			_timer = _owner.get_tree().create_timer(duration)
			_timer.timeout.connect(_finish)


		return Outcome.PENDING
	func _physics_tick() -> Outcome:

		# Fail if owner no longer valid
		if(!is_instance_valid(_owner)):
			push_warning("[LevitateAct] Cannot tick levitate, body no longer valid!")
			return Outcome.FAILURE

		_owner.velocity.y = 0
		return Outcome.PENDING
	func _exit():

		# Disconnect timer
		if(_timer != null && _timer.timeout.is_connected(_finish)):
			_timer.timeout.disconnect(_finish)
		_timer = null

		
		# Enable gravity
		if(is_instance_valid(_owner) && _owner is PlatformCharacter):
			_owner.is_gravity_enabled = true
