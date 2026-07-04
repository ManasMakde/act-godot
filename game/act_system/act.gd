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
enum BlockType {
	ONESHOT,
	PERSISTENT
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
signal block_changed(act: Act, blocking_act: Act, block_type: BlockType, did_block: bool)

var prologue: Callable = func(_act: Act) -> Array[Act]: return []  # List all acts to perform before this act, Return `[ null ]` for failure outcome
var perform_conditions: Array[Callable] = []  # Externally extendable conditions for `_can_perform()`, Signature func(_act: Act) -> bool

func init(theater: Theater, name := "", initially_enabled := true):

	# Assign new owning theater
	_theater = theater
	_theater._all_acts[self] = true


	# Assign new name
	_name = name


	# Disable Initially
	if(!initially_enabled):
		_block_self(self, BlockType.PERSISTENT)


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
	if(_can_perform_impl()):
		_perform_impl()
func perform_deferred(tick_flag := TickFlags.PHYSICS_TICK):
	if(_theater):
		_theater._stage_deferred(self, tick_flag)
func retry():
	_finish(Outcome.RETRY)
func abort():
	_finish(Outcome.INTERRUPTED)
func add_to_block(acts: Array[Act], block_type := BlockType.PERSISTENT):

	for b_act: Act in acts:

		# Skip if self (reserved for enable/disable)
		if(b_act == self):
			push_warning(_name, " Trying to block self!")
			continue
		

		# Add to block list
		_acts_to_block[b_act] = block_type
func set_enabled(new_enabled:bool):

	# Return if trying to reassign same value
	if(new_enabled == is_enabled()):
		return
	

	# Block/Unblock self
	if(!new_enabled):
		_block_self(self, BlockType.PERSISTENT)
	else:
		_unblock_self(self)
	

	# Broadcast enabled/disabled
	enable_changed.emit(self, is_enabled())
func did_perform(tick_flag := TickFlags.PHYSICS_TICK) -> bool:  # True if act was performed atleast once during current tick

	# Return false if no flag provided
	if tick_flag == TickFlags.NONE:
		return false
	

	# Check based on tick types
	var performed := false
	if tick_flag & TickFlags.TICK:
		performed = performed || _performed_on_tick == Engine.get_process_frames()
	if tick_flag & TickFlags.PHYSICS_TICK:
		performed = performed || _performed_on_physics_tick == Engine.get_physics_frames()


	return performed
func did_perform_ever() -> bool:  # True if act was performed atleast once since it was initialized
	return _performed_on_tick != -1 || _performed_on_physics_tick != -1
func is_ongoing() -> bool:
	return _status != Status.NONE
func is_enabled() -> bool:
	return !_blocked_by_acts.has(self)
func is_blocked() -> bool:

	# Incase act is disabled
	if(_blocked_by_acts.size() == 1 && _blocked_by_acts.has(self)):
		return false

	return _blocked_by_acts.size() != 0
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
func _block_self(by_act: Act, block_type: BlockType):

	# Return if already blocked or top epilogues match up
	if(_blocked_by_acts.has(by_act) or _has_mutual_top_epilogue(self, by_act)):
		return
	

	# Finish interrupted incase ongoing
	_finish(Outcome.INTERRUPTED)


	# Add to blocked by list if persistent
	if(block_type == BlockType.PERSISTENT):
		_blocked_by_acts[by_act] = true


	# Broadcast blocked
	if(by_act != self):
		block_changed.emit(self, by_act, block_type, true)
func _unblock_self(by_act: Act):

	# Return if not currently blocked by act
	if(!_blocked_by_acts.has(by_act)):
		return
	

	# Persistent Unblocking
	_blocked_by_acts.erase(by_act)


	# Broadcast unblocked
	if(by_act != self):
		block_changed.emit(self, by_act, BlockType.PERSISTENT, false)
func _block_others():
	for act: Act in _acts_to_block:
		act._block_self(self, _acts_to_block[act])
func _unblock_others():
	for act: Act in _acts_to_block:
		act._unblock_self(self)



# Private
var _theater: Theater = null  # Which theater this act belongs to
var _status := Status.NONE  # Keeps track of where in the perform life cycle the act is currently 
var _outcome := Outcome.NONE  # Denotes how the act ended
var _did_enter := false  # true if exit has been reached via enter 
var _name := ""  # Useful for debugging
var _acts_to_block: Dictionary[Act, BlockType] = {}  # Which acts to block when performing this act 
var _blocked_by_acts: Dictionary[Act, bool] = {}  # Which acts are blocking this act (Treat as HashSet)
var _top_epilogue_acts: Dictionary[Act, bool] = {}  # (Treat as HashSet)
var _epilogue_acts: Dictionary[Act, bool] = {}  # (Treat as HashSet)
var _prologue_acts: Dictionary[Act, bool] = {}  # (Treat as HashSet)
var _prologue_complete_count := 0
var _performed_on_tick := -1
var _performed_on_physics_tick := -1

static func _link_prologue_arrays(array_b: Array, array_a: Array):
	for i in range(array_b.size()):
		var act_b: Act = array_b[i]
		for j in range(array_a.size()):
			var act_a: Act = array_a[j]
			_assign_prologue(act_b, act_a)
static func _has_mutual_top_epilogue(act_a: Act, act_b: Act) -> bool:

	# Incase both are the same acts
	if(act_a == act_b):
		return false
	

	# Incase act_a is a top epilogue
	if(act_a._epilogue_acts.size() == 0 && act_b._top_epilogue_acts.has(act_a)):
		return true
	

	# Incase act_b is a top epilogue
	if(act_b._epilogue_acts.size() == 0 && act_a._top_epilogue_acts.has(act_b)):
		return true


	# Check for overlap in top epilogue of both
	for e_act: Act in act_a._top_epilogue_acts:
		if(act_b._top_epilogue_acts.has(e_act)):  
			return true
	
	return false
static func _finish_prologues(of_act: Act, new_outcome: Outcome):

	for p_act: Act in of_act._prologue_acts:
		if(p_act != null):
			p_act._finish(new_outcome)
static func _finish_epilogues(of_act: Act, new_outcome: Outcome):

	for e_act: Act in of_act._epilogue_acts:
		e_act._continue_prologue(of_act, new_outcome)
static func _clear_prologue_chain(of_act: Act):
	
	# Recurse clear
	for p_act: Act in of_act._prologue_acts:
		if(p_act != null):
			_clear_prologue_chain(p_act)
	
	of_act._epilogue_acts.clear()
	of_act._top_epilogue_acts.clear()
	of_act._prologue_acts.clear()
static func _assign_prologue(e_act: Act, p_act: Act):

	# Assign prologue
	e_act._prologue_acts[p_act] = true


	# Assign epilogue
	p_act._epilogue_acts[e_act] = true


	# Assign top epilogue
	if(e_act._epilogue_acts.size() == 0):
		p_act._top_epilogue_acts[e_act] = true
	else:
		p_act._top_epilogue_acts.merge(e_act._top_epilogue_acts.duplicate())
func _can_perform_impl() -> bool:

	# Return if null theater
	if(_theater == null):
		push_warning(_name, "Null theater found, Initialize first!")
		return false


	# Return conditions
	if(!is_enabled() || !_theater._is_enabled || is_blocked() || (!_can_reperform && is_ongoing())):
		return false
	

	# Return if any external condition is false
	for cond: Callable in perform_conditions:
		if(!cond.call(self)):
			return false


	return _can_perform()
func _perform_impl():

	# Store tick 
	_performed_on_tick = Engine.get_process_frames()
	_performed_on_physics_tick = Engine.get_physics_frames()


	# Finish any ongoing perform
	_finish(Outcome.INTERRUPTED)


	# Redirect to prologue
	_redirect(Status.PROLOGUING)
func _prologue_impl():

	# Let theater know this is act is now ongoing
	_theater._stage_ongoing(self)
	if (_status != Status.PROLOGUING): return # Guard


	# Assign all prologues & epilogues
	for p_act: Act in prologue.call(self):

		# Skip self
		if(p_act == self):
			continue
		
		# Fail incase null
		if(p_act == null):
			return _redirect(Status.EXITING, Outcome.FAILURE)

		# Assign prologue, epilogue & top epilogue
		_assign_prologue(self, p_act)


	# Block
	_block_others()
	if (_status != Status.PROLOGUING): return # Guard


	# Skip if no prologues
	if (_prologue_acts.size() == 0):
		return _redirect(Status.ENTERING)  # Intentional to skip pre prologue signal
	

	# Broadcast pre-prologue
	pre_prologue.emit(self)
	if (_status != Status.PROLOGUING): return # Guard


	# Perform all prologues
	for p_act: Act in _prologue_acts:

		# Skip if ongoing
		if(p_act.is_ongoing()):
			continue
		
		# Fail incase cannot perform
		if(!p_act._can_perform_impl()):
			return _redirect(Status.EXITING, Outcome.FAILURE)
		
		# Perform
		p_act._perform_impl()
		if (_status != Status.PROLOGUING): return # Guard
func _continue_prologue(p_act: Act, new_outcome:= Outcome.NONE):
	
	# Guard
	if(_status != Status.PROLOGUING):
		return
	

	# Wait for all prologues to complete
	var prologue_succeeded = (new_outcome == Outcome.SUCCESS && p_act != null)
	if(prologue_succeeded && _prologue_complete_count + 1 != _prologue_acts.size()):
		_prologue_complete_count += 1
		return


	# Broadcast post-prologue
	if(prologue_succeeded):
		post_prologue.emit(self)
	if (_status != Status.PROLOGUING): return # Guard


	# If prologue succeeded goto enter otherwise exit
	_redirect(Status.ENTERING if prologue_succeeded else Status.EXITING, new_outcome)
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

	
	# Broadcast pre-physics-tick
	pre_physics_tick.emit(self)
	if (_status != Status.TICKING): return # Guard


	# Core tick
	var new_outcome := _physics_tick()
	if (_status != Status.TICKING): return # Guard


	# Broadcast post-physics-tick
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
	if(_outcome != Outcome.RETRY):
		_finish_epilogues(self, _outcome)
	if (_status != Status.EXITING): return # Guard


	# Finish prologues
	_finish_prologues(self, Outcome.INTERRUPTED if _outcome == Outcome.RETRY else _outcome)
	if (_status != Status.EXITING): return # Guard


	# Clear chain
	_clear_prologue_chain(self)


	# Reset properties
	var to_retry := _outcome == Outcome.RETRY
	_status = Status.NONE
	_outcome = Outcome.NONE
	_did_enter = false
	_prologue_complete_count = 0


	# Unblock
	_unblock_others()


	# Retry performance
	if(to_retry):
		perform()
		return


	# Let theater know this is act has ended
	_theater._unstage_ongoing(self)
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
