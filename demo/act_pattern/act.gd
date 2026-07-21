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
	PENDING = 0,
	SUCCESS = 1,
	RETRY = 2
}
enum BlockType {
	ONESHOT,
	PERSISTENT
}


# Public
signal on_perform_start(act: Act)
signal on_perform_end(act: Act)
signal on_pre_setup(act: Act)
signal on_post_setup(act: Act)
signal on_pre_prologue(act: Act)
signal on_post_prologue(act: Act)
signal on_pre_enter(act: Act)
signal on_post_enter(act: Act)
signal on_pre_tick(act: Act)
signal on_post_tick(act: Act)
signal on_pre_physics_tick(act: Act)
signal on_post_physics_tick(act: Act)
signal on_pre_exit(act: Act)
signal on_post_exit(act: Act)
signal on_pre_cleanup(act: Act)
signal on_post_cleanup(act: Act)
signal on_enable_changed(act: Act, new_is_enabled: bool)
signal on_block_changed(act: Act, blocking_act: Act, block_type: BlockType, did_block: bool)

var prologue := func(_act: Act) -> Array[Act]: return []  # List all acts to perform before this act, Return [ null ] for failure outcome
var perform_conditions: Array[Callable] = []  # Externally extendable conditions for _can_perform(), Signature func(_act: Act) -> bool
var is_verbose := false  # Toggle for warning messages

func init(theater: Theater, name := "", initially_enabled := true):

	# Warn if null theater provided
	if (theater == null):
		_write_log("Null theater provided for initialization!", name)
		return


	# Assign new owning theater
	_theater = theater
	_theater._add_act(self)


	# Assign new name
	_name = name


	# Disable Initially
	if(!initially_enabled):
		_block_self(self, BlockType.PERSISTENT)


	# Broadcast pre-setup
	on_pre_setup.emit(self)


	# Core setup
	_setup()


	# Broadcast post-setup
	on_post_setup.emit(self)
func deinit():

	# Make sure act is not ongoing
	abort()


	# Broadcast pre-cleanup
	on_pre_cleanup.emit(self)


	# Core cleanup
	_cleanup()


	# Broadcast post-cleanup
	on_post_cleanup.emit(self)


	# Unassign owning theater
	if (_theater != null):
		_theater._remove_act(self)
		_theater = null


	# Reset performed on ticks
	_performed_on_tick = -1
	_performed_on_physics_tick = -1
func perform():
	if(_can_perform_impl()):
		_perform_impl()
func perform_deferred(tick_flag := TickFlags.PHYSICS_TICK):

	# Warn if null theater provided
	if (_theater == null):
		_write_log("Cannot perform deferred, Theater is null! Have you initialized act?")
		return
	
	_theater._stage_deferred(self, tick_flag)
func retry():
	if(is_ongoing()):
		_redirect(Status.EXITING, Outcome.RETRY)
	else:
		perform()
func abort():
	_redirect(Status.EXITING, Outcome.INTERRUPTED)
func add_to_block(acts: Array[Act], block_type := BlockType.PERSISTENT):

	for b_act: Act in acts:

		# Skip if self (reserved for enable/disable)
		if(b_act == self):
			_write_log("Trying to block self!")
			continue
		

		# Add to block list
		_acts_to_block[b_act] = block_type
func remove_from_block(acts: Array[Act]):

	for b_act: Act in acts:

		# Skip if self (reserved for enable/disable)
		if(b_act == self):
			_write_log("Trying to unblock self!")
			continue
		

		# Remove from block list
		_acts_to_block.erase(b_act)
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
	on_enable_changed.emit(self, is_enabled())
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
func is_active() -> bool:
	return _status != Status.NONE && _status != Status.PROLOGUING;
func is_enabled() -> bool:
	return !_blocked_by_acts.has(self)
func is_blocked() -> bool:

	# Incase act is disabled
	if(_blocked_by_acts.size() == 1 && _blocked_by_acts.has(self)):
		return false

	return _blocked_by_acts.size() != 0
func can_tick(type: TickFlags) -> bool:
	return bool(_tick_flags & type)
func get_theater() -> Theater:
	return _theater
func get_owner() -> Node:

	# Return null if theater not assigned
	if(_theater == null):
		return null
	

	return _theater.get_parent()
func get_status() -> Status:
	return _status
func get_outcome() -> Outcome:
	return _outcome
func get_delta() -> float: 
	return _theater.get_process_delta_time() if _theater != null else 0.0
func get_physics_delta() -> float:
	return _theater.get_physics_process_delta_time() if _theater != null else 0.0
func get_name() -> String:
	return _name
static func seq(p_arrays: Array[Array]) -> Array:  # Only use inside prologue

	# Check for any null
	for p_array in p_arrays:
		if p_array.has(null):
			return [null]


	# Remove empty lists before chaining
	p_arrays = p_arrays.filter(func(p_arr): return p_arr.size() > 0)

	
	# Return if empty list
	var p_length := p_arrays.size() 
	if(p_length == 0):
		return []
	

	# Chain all prologues
	for i in range(p_length - 1, 0, -1):
		_link_prologue_arrays(p_arrays[i], p_arrays[i - 1])

	
	return p_arrays[p_length - 1]  # Return last acts



# Protected
var _can_reperform := false  # Indicates if act can interrupt itself & restart perform, Only assign in _setup()
var _tick_flags := TickFlags.NONE  # Indicates if act will be "Ticking" after entering, Only assign in _setup()

func _setup(): pass
func _can_perform() -> bool:
	return true
func _enter() -> Outcome:
	return Outcome.PENDING if _tick_flags != TickFlags.NONE else Outcome.SUCCESS
func _tick() -> Outcome:
	return Outcome.PENDING
func _physics_tick() -> Outcome:
	return Outcome.PENDING
func _exit(): pass
func _cleanup(): pass
func _finish(new_outcome := Outcome.SUCCESS):
	_redirect(Status.EXITING, new_outcome)
func _block_self(by_act: Act, block_type: BlockType):

	# Return in null act
	if(by_act == null):
		_write_log("Failed to block, null act provided!")
		return


	# Return if already blocked
	if(_blocked_by_acts.has(by_act)):
		return


	# Return if both acts are in the same prologue chain
	if(self != by_act && _do_dicts_overlap(_get_top_epilogues(self), _get_top_epilogues(by_act))):
		_write_log("Failed to block, Both " + _name + " & " + by_act._name + " are in the same prologue chain!")
		return


	# Finish interrupted incase ongoing
	_redirect(Status.EXITING, Outcome.INTERRUPTED)


	# Add to blocked by list if persistent
	if(block_type == BlockType.PERSISTENT):
		_blocked_by_acts[by_act] = true


	# Broadcast blocked
	if(by_act != self):
		on_block_changed.emit(self, by_act, block_type, true)
func _unblock_self(by_act: Act):

	# Return incase null act
	if(by_act == null):
		_write_log("Failed to unblock, null act provided!")
		return


	# Return if not currently blocked by act
	if(!_blocked_by_acts.has(by_act)):
		_write_log("Failed to unblock, Act is not blocked by " + by_act._name)
		return
	

	# Persistent Unblocking
	_blocked_by_acts.erase(by_act)


	# Broadcast unblocked
	if(by_act != self):
		on_block_changed.emit(self, by_act, BlockType.PERSISTENT, false)
func _block_others():
	for act: Act in _acts_to_block:
		act._block_self(self, _acts_to_block[act])
func _unblock_others():
	for act: Act in _acts_to_block:
		if(_acts_to_block[act] == BlockType.PERSISTENT):  # Skip oneshot
			act._unblock_self(self)



# Private
var _name := ""  # Useful for debugging
var _theater: Theater = null  # Which theater this act belongs to
var _status := Status.NONE  # Keeps track of where in the perform life cycle the act is currently 
var _prev_status := Status.NONE
var _outcome := Outcome.PENDING  # Denotes how the act ended
var _acts_to_block: Dictionary[Act, BlockType] = {}  # Which acts to block when performing this act 
var _blocked_by_acts: Dictionary[Act, bool] = {}  # Which acts are blocking this act (Treat as HashSet)
var _epilogue_acts: Dictionary[Act, bool] = {}  # (Treat as HashSet)
var _prologue_acts: Dictionary[Act, bool] = {}  # (Treat as HashSet)
var _pending_prologue_acts: Dictionary[Act, bool] = {}  # Prologues started but not yet completed (Treat as HashSet)
var _performed_on_tick := -1
var _performed_on_physics_tick := -1

static func _link_prologue_arrays(array_b: Array, array_a: Array):
	for i in range(array_b.size()):
		var act_b: Act = array_b[i]
		for j in range(array_a.size()):
			var act_a: Act = array_a[j]
			act_b._prologue_acts[act_a] = true
			act_a._epilogue_acts[act_b] = true
static func _get_top_epilogues(of_act: Act, result: Dictionary[Act, bool] = {}, visited: Dictionary[Act, bool] = {}) -> Dictionary[Act, bool]:

	# Skip if already visited
	if(visited.has(of_act)):
		return result


	# Mark as visited
	visited[of_act] = true


	# Add if top epilogue
	if(of_act._epilogue_acts.size() == 0):
		result[of_act] = true
		return result


	# Recurse into each epilogue
	for e_act: Act in of_act._epilogue_acts:
		_get_top_epilogues(e_act, result, visited)

	return result
static func _assign_prologue_chain(of_act: Act):
	for p_act: Act in of_act.prologue.call(of_act):

		# Skip self
		if(p_act == of_act):
			continue


		# Fail incase null
		if(p_act == null):
			return of_act._redirect(Status.EXITING, Outcome.FAILURE)


		# Assign prologue and epilogue
		of_act._prologue_acts[p_act] = true
		p_act._epilogue_acts[of_act] = true
static func _finish_prologues(of_act: Act, new_outcome: Outcome):

	# Set outcome to interrupted incase retrying
	var p_outcome := Outcome.INTERRUPTED if new_outcome == Outcome.RETRY else new_outcome


	# Finish all pending prologues
	while(of_act._pending_prologue_acts.size() != 0):
		var p_act: Act = _first_key(of_act._pending_prologue_acts)
		of_act._pending_prologue_acts.erase(p_act)
		if(p_act != null):
			p_act._finish(p_outcome)
static func _continue_epilogues(of_act: Act, new_outcome: Outcome):

	# Continue and clear out epilogues
	while(of_act._epilogue_acts.size() != 0):
		var e_act: Act = _first_key(of_act._epilogue_acts)
		of_act._epilogue_acts.erase(e_act)
		e_act._completed_prologue(of_act, new_outcome)
static func _clear_prologue_chain(of_act: Act):

	while(of_act._prologue_acts.size() != 0):

		# Get prologue act
		var p_act: Act = _first_key(of_act._prologue_acts)
		of_act._prologue_acts.erase(p_act)


		# Skip if null
		if(p_act == null):
			continue


		# Remove self from epilogue
		p_act._epilogue_acts.erase(of_act)


		# Recurse down, Incase seq() linked stale acts that were never performed
		if(p_act._epilogue_acts.size() == 0):
			_clear_prologue_chain(p_act)
static func _do_dicts_overlap(a: Dictionary[Act, bool], b: Dictionary[Act, bool]) -> bool:
	for k in a:
		if(b.has(k)):
			return true
	return false
static func _first_key(dict: Dictionary[Act, bool]) -> Act:  # Get first key of dict
	for act: Act in dict:
		return act
	
	return null
func _can_perform_impl() -> bool:

	# Return if null theater
	if(_theater == null):
		_write_log("Cannot perform, Theater is null! Have you initialized act?")
		return false


	# Return if disabled
	if(!is_enabled() || !_theater.is_enabled()):
		_write_log("Cannot perform, act or theater is disabled!")
		return false
	
	
	# Return if blocked
	if(is_blocked()):
		_write_log("Cannot perform, act is blocked!")
		return false
	

	# Return if already ongoing
	if(!_can_reperform && is_ongoing()):
		_write_log("Cannot perform, act is ongoing!")
		return false
	

	# Return if any external condition is false
	for cond: Callable in perform_conditions:
		if(!cond.call(self)):
			return false


	return _can_perform()
func _perform_impl():

	# Finish any ongoing perform
	_finish(Outcome.INTERRUPTED)
	

	# Start prologuing
	_redirect(Status.PROLOGUING)
func _prologue_impl():

	# Broadcast perform start
	on_perform_start.emit(self)
	if(_status != Status.PROLOGUING): return


	# Let theater know this act has started
	if(_theater != null):
		_theater._stage_ongoing(self)
	if(_status != Status.PROLOGUING): return


	# Store during which tick act was performed
	_performed_on_tick = Engine.get_process_frames()
	_performed_on_physics_tick = Engine.get_physics_frames()


	# Assign prologues & epilogues
	_assign_prologue_chain(self)
	if(_status != Status.PROLOGUING): return  # Guard


	# Block
	_block_others()
	if(_status != Status.PROLOGUING): return  # Guard


	# Skip if no prologues
	if(_prologue_acts.size() == 0):
		return _redirect(Status.ENTERING)  # Intentional to skip pre prologue signal


	# Broadcast pre prologue
	on_pre_prologue.emit(self)
	if(_status != Status.PROLOGUING): return # Guard


	# Reset pending prologues
	_pending_prologue_acts.clear()


	# Perform all prologues
	while(_prologue_acts.size() != 0):

		# Pop a prologue & get prerequisites
		var p_act: Act = _first_key(_prologue_acts)
		var is_ongoing := p_act.is_ongoing()
		var can_perform := p_act._can_perform_impl()


		# Fail incase cannot perform
		if(!is_ongoing && !can_perform):
			return _redirect(Status.EXITING, Outcome.FAILURE)


		# Shift to pending
		_prologue_acts.erase(p_act)
		_pending_prologue_acts[p_act] = true


		# Perform if not already ongoing
		if(!is_ongoing):
			p_act._perform_impl()
		if(_status != Status.PROLOGUING): return # Guard
func _completed_prologue(p_act: Act, new_outcome: Outcome):

	# Guard
	if(_status != Status.PROLOGUING): return


	# Remove from pending and move to completed
	_pending_prologue_acts.erase(p_act)


	# Exit if prologue act did not succeed
	if(new_outcome != Outcome.SUCCESS):
		return _redirect(Status.EXITING, new_outcome)


	# Wait for all prologues to complete
	if(_pending_prologue_acts.size() != 0 || _prologue_acts.size() != 0):
		return


	# Broadcast post prologue
	on_post_prologue.emit(self)
	if(_status != Status.PROLOGUING): return # Guard


	# Redirect to enter
	_redirect(Status.ENTERING)
func _enter_impl():

	# Broadcast pre-enter
	on_pre_enter.emit(self)
	if (_status != Status.ENTERING): return # Guard


	# Core enter
	var new_outcome = _enter()
	if (_status != Status.ENTERING): return # Guard


	# Broadcast post-enter
	on_post_enter.emit(self)
	if (_status != Status.ENTERING): return # Guard


	# Redirect to exit
	if(new_outcome != Outcome.PENDING):
		return _redirect(Status.EXITING, new_outcome)


	# Start ticking
	if(can_tick(TickFlags.TICK) && _theater != null):
		_theater._stage_tick(self)
	if(can_tick(TickFlags.PHYSICS_TICK) && _theater != null):
		_theater._stage_physics_tick(self)


	# Redirect to ticking	
	return _redirect(Status.TICKING)
func _tick_impl():

	# Guard
	if(_status != Status.TICKING): return
	

	# Broadcast pre-tick
	on_pre_tick.emit(self)
	if (_status != Status.TICKING): return # Guard


	# Core tick
	var new_outcome := _tick()
	if (_status != Status.TICKING): return # Guard


	# Broadcast post-tick
	on_post_tick.emit(self)
	if (_status != Status.TICKING): return # Guard


	# Check if exit was requested
	if(new_outcome != Outcome.PENDING):
		_redirect(Status.EXITING, new_outcome)
func _physics_tick_impl():
	
	# Guard
	if(_status != Status.TICKING): 
		return

	
	# Broadcast pre-physics-tick
	on_pre_physics_tick.emit(self)
	if (_status != Status.TICKING): return # Guard


	# Core tick
	var new_outcome := _physics_tick()
	if (_status != Status.TICKING): return # Guard


	# Broadcast post-physics-tick
	on_post_physics_tick.emit(self)
	if (_status != Status.TICKING): return # Guard


	# Check if exit was requested
	if(new_outcome != Outcome.PENDING):
		_redirect(Status.EXITING, new_outcome)
func _exit_impl():

	# Only exit if coming from enter or tick
	if(_prev_status == Status.ENTERING || _prev_status == Status.TICKING):
		
		# Stop ticking
		if(can_tick(TickFlags.TICK) && _theater != null):
			_theater._unstage_tick(self)
		if(can_tick(TickFlags.PHYSICS_TICK) && _theater != null):
			_theater._unstage_physics_tick(self)


		# Broadcast pre-exit
		on_pre_exit.emit(self)


		# Core exit
		_exit()


		# Broadcast post-exit
		on_post_exit.emit(self)


	# Finish prologues if any pending & Clear prologue chain
	_finish_prologues(self, _outcome)
	_clear_prologue_chain(self)


	# Do not continue epilogues or unblock if retrying
	if(_outcome != Outcome.RETRY):
		_continue_epilogues(self, _outcome)
		_unblock_others()


	# Retry
	if(_outcome == Outcome.RETRY):
		if(_can_perform_impl()):
			_status = Status.NONE
			_perform_impl()
			return


		# Continue epilogues & unblock which were previously skipped
		_continue_epilogues(self, _outcome)
		_unblock_others()


	# Reset status
	_status = Status.NONE


	# Let theater know this is act has ended
	if(_theater != null):
		_theater._unstage_ongoing(self)


	# Broadcast perform end
	on_perform_end.emit(self)
func _redirect(new_status: Status, new_outcome := Outcome.PENDING):

	# None -> Prologue
	if(_status == Status.NONE && new_status == Status.PROLOGUING):
		_prev_status = _status
		_status = Status.PROLOGUING
		_outcome = Outcome.PENDING
		_prologue_impl()

	# Prologue -> Enter
	elif(_status == Status.PROLOGUING && new_status == Status.ENTERING):
		_prev_status = _status
		_status = Status.ENTERING
		_enter_impl()

	# Enter -> Tick
	elif(_status == Status.ENTERING && new_status == Status.TICKING):
		_prev_status = _status
		_status = Status.TICKING

	# Prologue or Enter or Tick -> Exit
	elif((_status == Status.PROLOGUING || _status == Status.ENTERING || _status == Status.TICKING) && new_status == Status.EXITING):
		_prev_status = _status
		_status = Status.EXITING
		_outcome = new_outcome
		_exit_impl()
func _write_log(message: String, override_name :=""):
	if(!is_verbose):
		return

	push_warning(override_name if override_name !="" else _name, " ", message)
func _to_string() -> String:
	return _name  # For easier debugging in editor
