class_name Theater extends Node


# Public Signals
signal on_enable_changed(theater: Theater, new_is_enabled: bool)
signal on_perform_start(theater: Theater, act: Act)
signal on_perform_end(theater: Theater, act: Act)
signal on_all_perform_end(theater: Theater)


# Public Methods
func is_enabled() -> bool:
	return _is_enabled
func set_enabled(new_enabled:bool):

	if(new_enabled == _is_enabled):
		return
	
	_is_enabled = new_enabled

	if(!_is_enabled):
		abort_all()

	on_enable_changed.emit(self, _is_enabled)
func abort_all():

	for act: Act in _all_acts:
		act.abort()
func are_any_ongoing() -> bool:
	return _ongoing_acts.size() != 0
func get_all_acts() -> Dictionary[Act, bool]:
	return _all_acts.duplicate()


# Private Properties
var _all_acts: Dictionary[Act, bool] = {}  # (Treat as HashSet)
var _ongoing_acts: Dictionary[Act, bool] = {}  # (Treat as HashSet)
var _deferred_acts: Dictionary[Act, Act.TickFlags] = {}  # (Treat as HashSet)
var _staged_tick_acts: Dictionary[Act, bool] = {}
var _staged_physics_tick_acts: Dictionary[Act, bool] = {}
var _acts_to_tick: Dictionary[Act, bool] = {}
var _acts_to_physics_tick: Dictionary[Act, bool] = {}
var _is_enabled := true


# Private Staging Methods
func _stage_deferred(act: Act, flag: Act.TickFlags):
		
	if(act == null):
		return
	
	_deferred_acts[act] = flag
func _unstage_deferred(act: Act):
		
	if(act == null):
		return
	
	_deferred_acts.erase(act)
func _stage_tick(act: Act):
	
	if(act == null):
		return
	
	_staged_tick_acts[act] = true
func _unstage_tick(act: Act):

	if(act == null):
		return
	

	# Remove if not reference swapped yet else mark as pending removal
	if(_staged_tick_acts.has(act)):
		_staged_tick_acts.erase(act)
	elif(_acts_to_tick.has(act)):
		_staged_tick_acts[act] = false
func _stage_physics_tick(act: Act):

	if(act == null):
		return
	
	_staged_physics_tick_acts[act] = true
func _unstage_physics_tick(act: Act):
	
	if(act == null):
		return
	

	# Remove if not reference swapped yet else mark as pending removal
	if(_staged_physics_tick_acts.has(act)):
		_staged_physics_tick_acts.erase(act)
	elif(_acts_to_physics_tick.has(act)):
		_staged_physics_tick_acts[act] = false
func _stage_ongoing(act: Act):

	# Return if invalid act or already ongoing
	if(act == null || _ongoing_acts.has(act)):
		return
	

	# Mark as ongoing act
	_ongoing_acts[act] = true


	# Clear defer
	_unstage_deferred(act)


	# Broadcast act started
	on_perform_start.emit(self, act)
func _unstage_ongoing(act: Act):

	# Remove as ongoing act
	_ongoing_acts.erase(act)


	# Broadcast act ended
	on_perform_end.emit(self, act)


	# Broadcast all ended if none ongoing
	if(!are_any_ongoing()):
		on_all_perform_end.emit(self)


# Private Tick Methods
func _tick_acts():

	# Return if no act to tick
	if(_staged_tick_acts.size() == 0):
		return
	

	# Reference swap to avoid mutation
	_acts_to_tick = _staged_tick_acts 
	_staged_tick_acts = {}


	# Tick all acts
	for act: Act in _acts_to_tick:
		act._tick_impl()
	

	# Merge back
	_staged_tick_acts.merge(_acts_to_tick, false)


	# Clear
	_acts_to_tick.clear()


	# Filter
	var filter: Array[Act] = []
	for act: Act in _staged_tick_acts:
		if(!_staged_tick_acts[act]):
			filter.append(act)
	
	for act: Act in filter:
		_staged_tick_acts.erase(act)
func _physics_tick_acts():
	
	# Return if no act to physics tick
	if(_staged_physics_tick_acts.size() == 0):
		return
	

	# Reference swap to avoid mutation
	_acts_to_physics_tick = _staged_physics_tick_acts 
	_staged_physics_tick_acts = {}


	# Physics tick all acts
	for act: Act in _acts_to_physics_tick:
		act._physics_tick_impl()
	

	# Merge back
	_staged_physics_tick_acts.merge(_acts_to_physics_tick, false)


	# Clear
	_acts_to_physics_tick.clear()


	# Filter
	var filter: Array[Act] = []
	for act: Act in _staged_physics_tick_acts:
		if(!_staged_physics_tick_acts[act]):
			filter.append(act)
	
	for act: Act in filter:
		_staged_physics_tick_acts.erase(act)
func _defer_acts(flag: Act.TickFlags):
	
	# Return if no acts to defer
	if(_deferred_acts.size() == 0):
		return
	

	# Reference swap to avoid mutation
	var acts_to_defer := _deferred_acts
	_deferred_acts = {}


	# Defer perform acts
	var filter: Array[Act] = []
	for act: Act in acts_to_defer:
		if(bool(acts_to_defer[act] & flag)):
			act.perform()
			filter.append(act)


	# Filter out
	for act: Act in filter:
		acts_to_defer.erase(act)
	

	# Merge back unperformed
	_deferred_acts.merge(acts_to_defer)


# Private Override Methods
func _process(_delta: float):
	_tick_acts()
	_defer_acts(Act.TickFlags.TICK)
func _physics_process(_delta: float):
	_physics_tick_acts()
	_defer_acts(Act.TickFlags.PHYSICS_TICK)
