class_name Act extends Object


# Enums
enum TickFlags {
	NONE = 0,
	TICK = 1 << 0,
	PHYSICS_TICK = 1 << 1,
}
enum Status {
	NONE = 0,
	PROLOGUING,
	ENTERING,
	TICKING,
	EXITING
}
enum Outcome {
	INTERRUPTED = -2,
	FAILURE = -1,
	NONE = 0,  # Intentionally kept none=0 & success=1 for easier bool comparison DO NOT CHANGE
	SUCCESS = 1,
	RETRY = 2
}


# Public
signal pre_setup(act: Act)
signal post_setup(act: Act)
signal pre_prologue(act: Act)
signal post_prologue(act: Act)
signal pre_enter(act: Act)
signal post_enter(act: Act)
signal pre_tick(act: Act)
signal post_tick(act: Act)
signal pre_physics_tick(act: Act)
signal post_physics_tick(act: Act)
signal pre_exit(act: Act)
signal post_exit(act: Act)
signal pre_cleanup(act: Act)
signal post_cleanup(act: Act)
signal enable_changed(act: Act, new_is_enabled: bool)

var prologue: Callable = func(_act: Act) -> Array[Act]: return []  # List all acts to perform before this act, Return `[ null ]` for failure outcome
var perform_conditions: Array[Callable] = []  # Externally extendable conditions for `_can_perform()`, Signature func(_act: Act) -> bool

func init(theater: Theater, name := "", initially_enabled := true):

	# Assign new owning theater
	_theater = theater
	_theater._all_acts[self] = true


	# Assign new name
	_name = name


	# Assign is enabled initially
	_is_enabled = initially_enabled


	# Broadcast pre-setup
	pre_setup.emit(self)


	# Core setup
	_setup()


	# Broadcast post-setup
	post_setup.emit(self)
func deinit():

	# Make sure act is not ongoing
	abort()


	# Broadcast pre-cleanup
	pre_cleanup.emit(self)


	# Core cleanup
	_cleanup()


	# Broadcast post-cleanup
	post_cleanup.emit(self)


	# Unassign owning theater
	_theater._all_acts.erase(self)
	_theater = null
func perform():

	# Return if cannot perform
	if(!_can_perform_impl()):
		return


	# Finish any ongoing perform
	_finish(Outcome.INTERRUPTED)


	# Redirect to prologue
	_redirect(Status.PROLOGUING)
func perform_deferred(flag := TickFlags.PHYSICS_TICK):
	_theater._stage_deferred(self, flag)
func retry():
	_finish(Outcome.RETRY)
func abort():
	_finish(Outcome.INTERRUPTED)
func set_enabled(new_enabled:bool):

	if(new_enabled == _is_enabled):
		return
	
	_is_enabled = new_enabled

	if(!_is_enabled):
		_finish(Outcome.INTERRUPTED)
	
	enable_changed.emit(self, _is_enabled)
func is_ongoing() -> bool:
	return _status != Status.NONE
func is_enabled() -> bool:
	return _is_enabled
func did_enter() -> bool:
	return _did_enter
func can_tick(type: TickFlags) -> bool:
	return bool(_tick_flags & type)
func get_outcome() -> Outcome:
	return _outcome
func get_theater() -> Theater:
	return _theater
func get_owner() -> Node:

	# Return null if theater not assigned
	if(_theater == null):
		return null
	

	return _theater.get_parent()
func get_delta() -> float: 
	return _theater.get_process_delta_time()
func get_physics_delta() -> float:
	return _theater.get_physics_process_delta_time()
func get_name() -> String:
	return _name
static func seq(p_arrays: Array[Array]) -> Array:  # ONLY USE INSIDE `prologue`

	# Return if empty list
	var p_length := p_arrays.size() 
	if(p_length == 0):
		return []
	

	# Chain all prologues
	for i in range(p_length - 1, 0, -1):
		var array_b := p_arrays[i]
		var array_a := p_arrays[i - 1]
		_link_prologue_arrays(array_b, array_a)

	
	return p_arrays[p_length - 1]  # Return last acts



# Protected
var _can_reperform := false  # Indicates if act can interrupt itself & restart perform (Assign in `_setup()`)
var _tick_flags := TickFlags.NONE  # Indicates if act will be "Ticking" after entering (Assign in `_setup()`)

func _setup(): pass
func _can_perform() -> bool:
	return true
func _enter() -> Outcome:
	return Outcome.NONE if _tick_flags != TickFlags.NONE else Outcome.SUCCESS
func _tick() -> Outcome:
	return Outcome.NONE
func _physics_tick() -> Outcome:
	return Outcome.NONE
func _exit(): pass
func _cleanup(): pass
func _finish(new_outcome := Outcome.SUCCESS):  # Call in _enter() if _exit() needs to be delayed

	# If currently prologuing
	if(_status == Status.PROLOGUING):
		_continue_prologue(null, new_outcome)


	# If currently entering or ticking
	elif(_status == Status.ENTERING || _status == Status.TICKING):
		_redirect(Status.EXITING, new_outcome)



# Private
var _theater: Theater = null  # Which theater this act belongs to
var _status := Status.NONE  # Keeps track of where in the perform life cycle the act is currently 
var _outcome := Outcome.NONE  # Denotes how the act ended
var _did_enter := false  # true if exit has been reached via enter 
var _is_enabled := true
var _name := ""  # Useful for debugging
var _epilogue_acts: Dictionary[Act, bool] = {}  # (Treat as HashSet)
var _prologue_acts: Dictionary[Act, bool] = {}  # (Treat as HashSet)
var _prologue_complete_count := 0

static func _link_prologue_arrays(array_b: Array, array_a: Array):
	for i in range(array_b.size()):
		var act_b: Act = array_b[i]
		for j in range(array_a.size()):
			var act_a: Act = array_a[j]
			act_b._prologue_acts[act_a] = true
			act_a._epilogue_acts[act_b] = true
func _can_perform_impl() -> bool:

	# Return if disabled or already ongoing
	if(!_is_enabled || !_theater._is_enabled || (!_can_reperform && is_ongoing())):
		return false
	

	# Return if any external condition is false
	for cond: Callable in perform_conditions:
		if(!cond.call(self)):
			return false


	return _can_perform()
func _prologue_impl():

	# Let theater know this is act is ongoing
	_theater._stage_ongoing(self)
	if (_status != Status.PROLOGUING): return # Guard


	# Get all prologue acts
	for p_act in prologue.call(self):

		# Skip self
		if(p_act == self):
			continue
		
		# Fail incase of null
		if(p_act == null):
			return _redirect(Status.EXITING, Outcome.FAILURE)

		# Add to list
		_prologue_acts[p_act] = true


	# Skip if none to perform
	if (_prologue_acts.size() == 0): 
		return _redirect(Status.ENTERING)
	

	# Exit with failure if any prologue cannot perform
	for p_act in _prologue_acts:
		if(!p_act.is_ongoing() && !p_act._can_perform_impl()):
			return _redirect(Status.EXITING, Outcome.FAILURE)
	

	# Broadcast pre-prologue
	pre_prologue.emit(self)
	if (_status != Status.PROLOGUING): return # Guard


	# Perform all
	for p_act in _prologue_acts:
		p_act._epilogue_acts[self] = true

		# Skip perform if already ongoing
		if(p_act.is_ongoing()):
			continue
		
		p_act.perform()
		if (_status != Status.PROLOGUING): return # Guard
func _continue_prologue(p_act: Act, new_outcome:= Outcome.NONE):
	
	# Guard
	if(_status != Status.PROLOGUING):
		return
	

	# Increment prologue completed count
	var prologue_succeeded := (new_outcome == Outcome.SUCCESS && p_act != null)
	if(prologue_succeeded):
		_prologue_complete_count += 1


	# Wait for all prologues to complete
	if(prologue_succeeded && _prologue_acts.size() != _prologue_complete_count):
		return


	# Broadcast post-prologue
	if(_prologue_acts.size() != 0):  # Skip broadcast if there were no prologues
		post_prologue.emit(self)
	if (_status != Status.PROLOGUING): return # Guard


	# If prologue succeeded goto enter otherwise exit
	_redirect(Status.ENTERING if prologue_succeeded else Status.EXITING, new_outcome)
func _finish_prologues():

	for p_act: Act in _prologue_acts:
		if(p_act != null):
			p_act._finish(Outcome.INTERRUPTED if _outcome == Outcome.RETRY else _outcome)
	
	_prologue_acts.clear()
func _finish_epilogues():

	if(_outcome == Outcome.RETRY):
		return

	for e_act: Act in _epilogue_acts:
		e_act._continue_prologue(self, _outcome)
	
	_epilogue_acts.clear()
func _enter_impl():

	# Broadcast pre-enter
	pre_enter.emit(self)
	if (_status != Status.ENTERING): return # Guard


	# Core enter
	var new_outcome = _enter()
	if (_status != Status.ENTERING): return # Guard


	# Broadcast post-enter
	post_enter.emit(self)
	if (_status != Status.ENTERING): return # Guard


	# Redirect to exit
	if(new_outcome != Outcome.NONE):
		return _redirect(Status.EXITING, new_outcome)


	# Start ticking
	if(can_tick(TickFlags.TICK)):
		_theater._stage_tick(self)
	if (_status != Status.ENTERING): return # Guard


	# Start physics ticking
	if(can_tick(TickFlags.PHYSICS_TICK)):
		_theater._stage_physics_tick(self)
	if (_status != Status.ENTERING): return # Guard


	# Redirect to ticking	
	return _redirect(Status.TICKING)
func _tick_impl():

	# Guard
	if(_status != Status.TICKING): 
		return
	

	# Broadcast pre-tick
	pre_tick.emit(self)
	if (_status != Status.TICKING): return # Guard


	# Core tick
	var new_outcome := _tick()
	if (_status != Status.TICKING): return # Guard


	# Broadcast post-tick
	post_tick.emit(self)
	if (_status != Status.TICKING): return # Guard


	# Check if exit was requested
	if(new_outcome != Outcome.NONE):
		_redirect(Status.EXITING, new_outcome)
func _physics_tick_impl():
	
	# Guard
	if(_status != Status.TICKING): 
		return

	
	# Broadcast pre-tick
	pre_physics_tick.emit(self)
	if (_status != Status.TICKING): return # Guard


	# Core tick
	var new_outcome := _physics_tick()
	if (_status != Status.TICKING): return # Guard


	# Broadcast post-tick
	post_physics_tick.emit(self)
	if (_status != Status.TICKING): return # Guard


	# Check if exit was requested
	if(new_outcome != Outcome.NONE):
		_redirect(Status.EXITING, new_outcome)
func _exit_impl():

	# Stop ticking
	if(can_tick(TickFlags.TICK)):
		_theater._unstage_tick(self)
	if (_status != Status.EXITING): return # Guard


	# Stop physics ticking
	if(can_tick(TickFlags.PHYSICS_TICK)):
		_theater._unstage_physics_tick(self)
	if (_status != Status.EXITING): return # Guard


	# Broadcast pre-exit
	pre_exit.emit(self)
	if (_status != Status.EXITING): return # Guard


	# Core exit
	_exit()
	if (_status != Status.EXITING): return # Guard


	# Broadcast post-exit
	post_exit.emit(self)
	if (_status != Status.EXITING): return # Guard


	# Finish epilogues
	_finish_epilogues()
	if (_status != Status.EXITING): return # Guard


	# Finish prologues
	_finish_prologues()
	if (_status != Status.EXITING): return # Guard


	# Check if to retry before resetting
	var to_retry := _outcome == Outcome.RETRY


	# Let theater know this is act has ended
	if(!to_retry):
		_theater._unstage_ongoing(self)
	if (_status != Status.EXITING): return # Guard


	# Reset
	_status = Status.NONE
	_outcome = Outcome.NONE
	_did_enter = false
	_prologue_complete_count = 0


	# Retry
	if(to_retry):
		perform()
func _redirect(new_status: Status, new_outcome := Outcome.NONE):

	# None -> Prologue
	if(_status == Status.NONE && new_status == Status.PROLOGUING):
		_status = Status.PROLOGUING
		_prologue_impl()

	# Prologue -> Enter
	elif(_status == Status.PROLOGUING && new_status == Status.ENTERING):
		_status = Status.ENTERING
		_enter_impl()

	# Enter -> Tick
	elif(_status == Status.ENTERING && new_status == Status.TICKING):
		_status = Status.TICKING

	# Prologue or Enter or Tick -> Exit
	elif((_status == Status.PROLOGUING || _status == Status.ENTERING || _status == Status.TICKING) && new_status == Status.EXITING):
		_did_enter = (_status == Status.ENTERING || _status == Status.TICKING)
		_status = Status.EXITING
		_outcome = new_outcome
		_exit_impl()
