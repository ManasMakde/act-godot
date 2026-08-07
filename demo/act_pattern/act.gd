# v0.1.1-alpha
# 
# Copyright (c) 2025-present Manas Ravindra Makde
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


class_name Act extends Object


# Enums
enum TickFlags {
	NONE = 0,
	TICK = 1 << 0,
	PHYSICS_TICK = 1 << 1
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
	INTERRUPT,
	PERSISTENT
}



# Public
signal on_pre_setup(act: Act)
signal on_post_setup(act: Act)
signal on_perform_start(act: Act)
signal on_pre_prologue(act: Act)
signal on_prologue_complete(act: Act, p_act: Act, p_outcome: Outcome)
signal on_post_prologue(act: Act)
signal on_pre_enter(act: Act)
signal on_post_enter(act: Act)
signal on_pre_tick(act: Act)
signal on_post_tick(act: Act)
signal on_pre_physics_tick(act: Act)
signal on_post_physics_tick(act: Act)
signal on_pre_exit(act: Act)
signal on_post_exit(act: Act)
signal on_perform_end(act: Act)
signal on_pre_cleanup(act: Act)
signal on_post_cleanup(act: Act)
signal on_enable_changed(act: Act, new_is_enabled: bool)
signal on_block_changed(act: Act, blocking_act: Act, block_type: BlockType, did_block: bool)

var prologue := func(_act: Act) -> Array[Act]: return []  # List all acts to perform before this act, Return { null } for failure outcome
var perform_conditions: Array[Callable] = []  # Externally extendable conditions for CanPerform()
var is_verbose := false  # Toggle for warning messages

func init(new_name: String = "", new_theater: Theater = null, initially_enabled: bool = true):

	# Return if trying to reinitialize
	if(_has_initialized):
		_write_log("Failed init(), Already initialized!")
		return


	# Return if already initialized
	if(_is_initializing):
		_write_log("Failed init(), Already initializing or deinitializing!")
		return


	# Mark as initialization started
	_is_initializing = true


	# Assign new name
	if(new_name != ""):
		_name = new_name


	# Assign new owning theater
	if(new_theater != null):
		_theater = new_theater
		_theater._add_act(self)


	# Disable Initially
	if(!initially_enabled):
		_block_self(self, BlockType.PERSISTENT)


	# Broadcast pre setup
	on_pre_setup.emit(self)


	# Core setup
	_setup()


	# Mark as initialization completed
	_is_initializing = false  # Intentionally before post setup broadcast DO NOT CHANGE
	_has_initialized = true


	# Broadcast post setup
	on_post_setup.emit(self)
func deinit():

	# Return if trying to redeinitialize
	if(!_has_initialized):
		_write_log("Failed deinit(), Already deinitialized!")
		return


	# Return if not initialized
	if(_is_initializing):
		_write_log("Failed deinit(), Already initializing or deinitializing!")
		return


	# Mark as deinitialization started
	_is_initializing = true


	# Make sure act is not ongoing
	abort()


	# Broadcast pre cleanup
	on_pre_cleanup.emit(self)


	# Core cleanup
	_cleanup()


	# Broadcast post cleanup
	on_post_cleanup.emit(self)


	# Unassign owning theater
	if(_theater != null):
		_theater._remove_act(self)
		_theater = null


	# Reset performed on ticks
	_perform_count = 0
	_performed_on_tick = -1
	_performed_on_physics_tick = -1


	# Mark as deinitialization completed
	_is_initializing = false
	_has_initialized = false
func perform():

	if(_can_perform_impl()):
		_perform_impl()
func perform_deferred(tick_flag: TickFlags = TickFlags.PHYSICS_TICK):
	
	# Warn if null theater provided
	if(_theater == null):
		_write_log("Cannot perform deferred, Assign a theater first!")
		return

	_theater._stage_deferred(self, tick_flag)
func retry():

	if(is_ongoing()):
		_redirect(Status.EXITING, Outcome.RETRY)
	else:
		perform()
func abort():

	_redirect(Status.EXITING, Outcome.INTERRUPTED)


	# Clear deferred
	if(_theater != null):
		_theater._unstage_deferred(self)
		return
func add_to_block(acts: Array[Act], block_type: BlockType = BlockType.PERSISTENT):
	for b_act in acts:
		
		# Skip if self (reserved for enable/disable)
		if(b_act == self):
			_write_log("Trying to block self!")
			continue


		# Add to block list
		_acts_to_block[b_act] = block_type


		# Block if ongoing
		if(is_ongoing()):
			b_act._block_self(self, block_type)
func remove_from_block(acts: Array[Act]):
	for b_act in acts:

		# Skip if self (reserved for enable/disable)
		if(b_act == self):
			_write_log("Trying to unblock self!")
			continue


		# Unblock if ongoing
		b_act._unblock_self(self)


		# Remove from block list
		_acts_to_block.erase(b_act)
func set_enabled(new_enabled: bool):

	# Return if trying to reassign same value
	if(new_enabled == is_enabled()):
		return


	# Block unblock self
	if(!new_enabled):
		_block_self(self, BlockType.PERSISTENT)
	else:
		_unblock_self(self)


	# Broadcast enabled disabled
	on_enable_changed.emit(self, is_enabled())
func did_perform(tick_flag: TickFlags = TickFlags.PHYSICS_TICK) -> bool:

	# Return false if no flag provided
	if(tick_flag == TickFlags.NONE):
		return false


	# Check based on tick types
	var has_performed := false
	if((tick_flag & TickFlags.TICK) != 0):
		has_performed = has_performed || _performed_on_tick == Engine.get_process_frames()
	if((tick_flag & TickFlags.PHYSICS_TICK) != 0):
		has_performed = has_performed || _performed_on_physics_tick == Engine.get_physics_frames()

	return has_performed
func is_ongoing() -> bool:
	return _status != Status.NONE
func is_active() -> bool:
	return _status != Status.NONE && _status != Status.PROLOGUING
func is_enabled() -> bool:
	return !_blocked_by_acts.has(self)
func is_blocked() -> bool:

	# Incase act is disabled
	if(_blocked_by_acts.size() == 1 && _blocked_by_acts.has(self)):
		return false

	return !_blocked_by_acts.is_empty()
func can_tick(type: TickFlags) -> bool:
	return (_tick_flags & type) != 0
func get_theater() -> Theater:
	return _theater
func get_owner() -> Node:

	# Return null if theater not assigned
	if(_theater == null):
		return null

	return _theater.get_parent()
func get_blocked_by_acts() -> Dictionary[Act, bool]:
	return _blocked_by_acts.duplicate()
func get_acts_to_block() -> Dictionary[Act, BlockType]:
	return _acts_to_block.duplicate()
func get_status() -> Status:
	return _status
func get_outcome() -> Outcome:
	return _outcome
func get_perform_count() -> int:
	return _perform_count
func get_tick_count() -> int:
	return _tick_count
func get_physics_tick_count() -> int:
	return _physics_tick_count
func get_delta() -> float: 
	return _theater.get_process_delta_time() if _theater != null else 0.0
func get_physics_delta() -> float: 
	return _theater.get_physics_process_delta_time() if _theater != null else 0.0
func get_name() -> String:
	return _name
static func seq(p_arrays:Array[Array]) -> Array:  # Only use inside prologue

	# Return if null
	if(p_arrays == null):
		return [null]


	# Return if any null
	for p_array in p_arrays:
		if(p_array == null || p_array.has(null)):
			return [null]


	# Remove empty lists before chaining
	p_arrays = p_arrays.filter(func(p_arr): return p_arr.size() != 0)


	# Return if empty list
	var p_length := p_arrays.size()
	if(p_length == 0):
		return []


	# Chain all prologues
	for i in range(p_length - 1, 0, -1):
		_link_prologue_arrays(p_arrays[i], p_arrays[i - 1])


	return p_arrays[p_length - 1]  # Return last acts



# Protected
var _name := ""
var _can_reperform := false  # Indicates if act can interrupt itself & restart perform, Only assign in Setup()
var _tick_flags := TickFlags.NONE  # Indicates if act will be "Ticking" after entering, Only assign in Setup()

func _setup():
	pass
func _can_perform() -> bool:
	return true
func _enter() -> Outcome:
	return Outcome.PENDING if _tick_flags != TickFlags.NONE else Outcome.SUCCESS
func _tick() -> Outcome:
	return Outcome.SUCCESS
func _physics_tick() -> Outcome:
	return Outcome.SUCCESS
func _exit():
	pass
func _cleanup():
	pass
func _finish(new_outcome: Outcome = Outcome.SUCCESS):
	_redirect(Status.EXITING, new_outcome)
func _block_self(by_act: Act, block_type: BlockType):

	# Return incase null act
	if(by_act == null):
		_write_log("Failed to block, null act provided!")
		return


	# Return if already blocked
	if(_blocked_by_acts.has(by_act)):
		return


	# Return if both acts are in the same prologue chain
	if(self != by_act && (!_epilogue_acts.is_empty() || !by_act._epilogue_acts.is_empty())):
		_result_top_epilogues.clear()
		_visited_top_epilogues.clear()
		by_act._result_top_epilogues.clear()
		by_act._visited_top_epilogues.clear()
		if(_does_overlap(_get_top_epilogues(self, _result_top_epilogues, _visited_top_epilogues), _get_top_epilogues(by_act, by_act._result_top_epilogues, by_act._visited_top_epilogues))):
			_write_log("Failed to block, Both " + _name + " and " + by_act._name + " are in the same prologue chain!")
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
		return


	# Persistent unblocking
	_blocked_by_acts.erase(by_act)


	# Broadcast unblocked
	if(by_act != self):
		on_block_changed.emit(self, by_act, BlockType.PERSISTENT, false)
func _block_others():

	for act in _acts_to_block:
		act._block_self(self, _acts_to_block[act])
func _unblock_others():

	for act in _acts_to_block:
		if(_acts_to_block[act] == BlockType.PERSISTENT):
			act._unblock_self(self)
func _write_log(message: String, override_name: String = ""):

	if(!is_verbose):
		return

	push_warning("[" + (override_name if override_name != "" else _name) + "] " + message)



# Private
var _theater: Theater = null  # Which theater this act belongs to
var _status := Status.NONE  # Keeps track of where in the perform life cycle the act is currently
var _prev_status := Status.NONE
var _outcome := Outcome.PENDING  # Denotes how the act ended
var _acts_to_block: Dictionary[Act, BlockType] = {}  # Which acts to block when performing this act
var _blocked_by_acts: Dictionary[Act, bool] = {}  # Which acts are blocking this act # (Treat as HashSet)

var _epilogue_acts: Dictionary[Act, bool] = {}  # (Treat as HashSet)
var _pending_epilogue_acts: Dictionary[Act, bool] = {}  # (Treat as HashSet)

var _prologue_acts: Dictionary[Act, bool] = {}  # (Treat as HashSet)
var _pending_prologue_acts: Dictionary[Act, bool] = {}  # (Treat as HashSet)
var _completed_prologue_acts: Dictionary[Act, bool] = {}  # (Treat as HashSet)

var _result_top_epilogues: Dictionary[Act, bool] = {}  # (Treat as HashSet)
var _visited_top_epilogues: Dictionary[Act, bool] = {}  # (Treat as HashSet)

var _has_initialized := false
var _is_initializing := false
var _has_precomputed_prologues := false

var _perform_count := 0
var _tick_count := 0
var _physics_tick_count := 0

var _tick_req_count := 0
var _physics_tick_req_count := 0

var _performed_on_tick := -1
var _performed_on_physics_tick := -1

static func _link_prologue_arrays(array_b: Array, array_a: Array):
	
	for i in range(array_b.size()):
		var act_b: Act = array_b[i]
		for j in range(array_a.size()):
			var act_a: Act = array_a[j]
			act_b._prologue_acts[act_a] = true
			act_a._epilogue_acts[act_b] = true
			act_a._pending_epilogue_acts[act_b] = true
static func _get_top_epilogues(of_act: Act, result: Dictionary[Act, bool], visited: Dictionary[Act, bool]) -> Dictionary[Act, bool]:
	
	# Skip if already visited
	if(visited.has(of_act)):
		return result


	# Mark as visited
	visited[of_act] = true


	# Add if top epilogue
	if(of_act._epilogue_acts.is_empty()):
		result[of_act] = true
		return result


	# Recurse into each epilogue
	for e_act in of_act._epilogue_acts:
		_get_top_epilogues(e_act, result, visited)

	return result
static func _precompute_prologue_chain(of_act: Act):

	# Fail Incase directly null provided
	var prologue_acts = of_act.prologue.call(of_act)
	if(prologue_acts == null):
		of_act._redirect(Status.EXITING, Outcome.FAILURE)
		return


	# Iterate through prologue acts
	for p_act in prologue_acts:
		# Skip self
		if(p_act == of_act):
			continue


		# Fail incase null
		if(p_act == null):
			of_act._redirect(Status.EXITING, Outcome.FAILURE)
			return


		# Assign prologue and epilogue
		of_act._prologue_acts[p_act] = true
		p_act._epilogue_acts[of_act] = true


		# Recurse into prologue
		_precompute_prologue_chain(p_act)


	# Mark as precomputed
	of_act._has_precomputed_prologues = true
static func _finish_prologues(of_act: Act, new_outcome: Outcome):

	# Set outcome to iterrupted incase retrying
	var p_outcome := Outcome.INTERRUPTED if new_outcome == Outcome.RETRY else new_outcome


	# Finish all pending prologues
	while(!of_act._pending_prologue_acts.is_empty()):
		var p_act := _get_first(of_act._pending_prologue_acts)
		of_act._pending_prologue_acts.erase(p_act)
		if(p_act != null):
			p_act._finish(p_outcome)
static func _continue_epilogues(of_act: Act, new_outcome: Outcome):

	# Continue and clear out epilogues
	while(!of_act._pending_epilogue_acts.is_empty()):
		var e_act := _get_first(of_act._pending_epilogue_acts)
		of_act._pending_epilogue_acts.erase(e_act)
		e_act._completed_prologue_acts[of_act] = true
		e_act._completed_prologue(of_act, new_outcome)
static func _clear_prologue_chain(of_act: Act):

	while(!of_act._prologue_acts.is_empty() || !of_act._completed_prologue_acts.is_empty()):

		# Get prologue act
		var p_act: Act
		if(of_act._prologue_acts.is_empty()):
			p_act = _get_first(of_act._completed_prologue_acts)
			of_act._completed_prologue_acts.erase(p_act)
		else:
			p_act = _get_first(of_act._prologue_acts)
			of_act._prologue_acts.erase(p_act)


		# Skip if null
		if(p_act == null):
			continue


		# Remove self from epilogue
		p_act._epilogue_acts.erase(of_act)
		p_act._pending_epilogue_acts.erase(of_act)


		# Recurse down, Incase Seq() linked stale acts that were never performed
		if(p_act._epilogue_acts.is_empty()):
			_clear_prologue_chain(p_act)
static func _get_first(data: Dictionary[Act, bool]) -> Act:

	if(data.is_empty()):
		return null

	for act in data:
		return act

	return null
static func _does_overlap(a: Dictionary[Act, bool], b: Dictionary[Act, bool]) -> bool:

	for k in a:
		if(b.has(k)):
			return true
	
	return false
func _can_perform_impl(is_retrying: bool = false) -> bool:

	# Return if in between initialization
	if(_is_initializing):
		_write_log("Cannot perform, act is initializing or deinitializing!")
		return false


	# Return if exiting
	if(!is_retrying && _status == Status.EXITING):
		_write_log("Cannot perform, act is between exiting!")
		return false


	# Return if disabled or theater is disabled
	if(!is_enabled() || (_theater != null && !_theater.is_enabled())):
		_write_log("Cannot perform, act or theater is disabled!")
		return false


	# Return if blocked
	if(is_blocked()):
		_write_log("Cannot perform, act is blocked!")
		return false


	# Return if already ongoing
	if(!is_retrying && !_can_reperform && is_ongoing()):
		_write_log("Cannot perform, act is ongoing!")
		return false


	# Return if any external condition is false
	for cond in perform_conditions:
		if(!cond.call(self)):
			return false


	return _can_perform()
func _perform_impl():

	# Finish any ongoing perform
	if(_status != Status.NONE):
		_finish(Outcome.INTERRUPTED)


	# Store during which tick act was performed
	_perform_count += 1
	_performed_on_tick = Engine.get_process_frames()
	_performed_on_physics_tick = Engine.get_physics_frames()


	# Clear deferred
	if(_theater != null):
		_theater._unstage_deferred(self)


	# Start prologuing
	_redirect(Status.PROLOGUING)
func _prologue_impl():

	# Broadcast perform start
	on_perform_start.emit(self)
	if(_status != Status.PROLOGUING):
		return  # Guard


	# Let theater know this act has started
	if(_theater != null):
		_theater._stage_ongoing(self)
	if(_status != Status.PROLOGUING):
		return  # Guard


	# Precompute prologue chain
	if(!_has_precomputed_prologues):
		_precompute_prologue_chain(self)
	if(_status != Status.PROLOGUING):
		return  # Guard


	# Assign self as pending epilogue
	for p_act in _prologue_acts:
		p_act._pending_epilogue_acts[self] = true


	# Block
	_block_others()
	if(_status != Status.PROLOGUING):
		return  # Guard


	# Skip if no prologues
	if(_prologue_acts.is_empty()):
		_redirect(Status.ENTERING)  # Intentional to skip pre prologue signal
		return


	# Broadcast pre prologue
	on_pre_prologue.emit(self)
	if(_status != Status.PROLOGUING):
		return  # Guard


	# Perform all prologues
	while(!_prologue_acts.is_empty()):
		# Guard
		if(_status != Status.PROLOGUING):
			return


		# Skip prologue if ongoing
		var p_act := _get_first(_prologue_acts)
		if(p_act.is_ongoing()):
			_prologue_acts.erase(p_act)
			_pending_prologue_acts[p_act] = true
			continue


		# Skip if already completed
		if(_completed_prologue_acts.has(p_act)):
			_prologue_acts.erase(p_act)
			_completed_prologue(p_act, Outcome.SUCCESS)
			continue


		# Perform prologue
		if(p_act._can_perform_impl()):
			_prologue_acts.erase(p_act)
			_pending_prologue_acts[p_act] = true
			p_act._perform_impl()
			continue


		# Exit with failure if failed to perform
		_redirect(Status.EXITING, Outcome.FAILURE)
		return
func _completed_prologue(p_act: Act, new_outcome: Outcome):

	# Guard
	if(_status != Status.PROLOGUING):
		return


	# Remove from pending and move to completed
	_pending_prologue_acts.erase(p_act)


	# Broadcast prologue completed
	on_prologue_complete.emit(self, p_act, new_outcome)
	if(_status != Status.PROLOGUING):
		return


	# Exit if prologue act did not succeed
	if(new_outcome != Outcome.SUCCESS):
		_redirect(Status.EXITING, new_outcome)
		return


	# Wait for all prologues to complete
	if(!_pending_prologue_acts.is_empty() || !_prologue_acts.is_empty()):
		return


	# Broadcast post prologue
	on_post_prologue.emit(self)
	if(_status != Status.PROLOGUING):
		return  # Guard


	# Redirect to enter
	_redirect(Status.ENTERING)
func _enter_impl():

	# Broadcast pre enter
	on_pre_enter.emit(self)
	if(_status != Status.ENTERING):
		return  # Guard


	# Core enter
	var new_outcome := _enter()
	if(_status != Status.ENTERING):
		return  # Guard


	# Broadcast post enter
	on_post_enter.emit(self)
	if(_status != Status.ENTERING):
		return  # Guard


	# Redirect to exit
	if(new_outcome != Outcome.PENDING):
		_redirect(Status.EXITING, new_outcome)
		return


	# Return if no ticking
	if(_tick_flags == TickFlags.NONE):
		return


	# Return if no theater assigned for ticking
	if(_theater == null):
		_write_log("Cannot tick, Assign a theater first!")
		return


	# Redirect to ticking
	_redirect(Status.TICKING)
func _handle_ticking_impl():
	if(can_tick(TickFlags.TICK)):
		_tick_req_count += 1
		_theater._stage_tick(self)
	if(can_tick(TickFlags.PHYSICS_TICK)):
		_physics_tick_req_count += 1
		_theater._stage_physics_tick(self)
func _tick_impl():

	# Guard
	if(_status != Status.TICKING):
		return


	# Increment tick count
	_tick_count += 1


	# Save tick request count
	var curr_tick_req_count := _tick_req_count


	# Broadcast pre tick
	on_pre_tick.emit(self)
	if(_status != Status.TICKING || curr_tick_req_count != _tick_req_count):
		return  # Guard


	# Core tick
	var new_outcome := _tick()
	if(_status != Status.TICKING || curr_tick_req_count != _tick_req_count):
		return  # Guard


	# Broadcast post tick
	on_post_tick.emit(self)
	if(_status != Status.TICKING || curr_tick_req_count != _tick_req_count):
		return  # Guard


	# Check if exit was requested
	if(new_outcome != Outcome.PENDING):
		_redirect(Status.EXITING, new_outcome)
func _physics_tick_impl():

	# Guard
	if(_status != Status.TICKING):
		return


	# Increment physics tick count
	_physics_tick_count += 1


	# Save physics tick request count
	var curr_physics_tick_req_count := _physics_tick_req_count


	# Broadcast pre physics tick
	on_pre_physics_tick.emit(self)
	if(_status != Status.TICKING || curr_physics_tick_req_count != _physics_tick_req_count):
		return  # Guard


	# Core tick
	var new_outcome := _physics_tick()
	if(_status != Status.TICKING || curr_physics_tick_req_count != _physics_tick_req_count):
		return  # Guard


	# Broadcast post physics tick
	on_post_physics_tick.emit(self)
	if(_status != Status.TICKING || curr_physics_tick_req_count != _physics_tick_req_count):
		return  # Guard


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


		# Broadcast pre exit
		on_pre_exit.emit(self)


		# Core exit
		_exit()


		# Broadcast post exit
		on_post_exit.emit(self)


	# Cleanup prologues
	_finish_prologues(self, _outcome)
	_clear_prologue_chain(self)
	_has_precomputed_prologues = false
	_prologue_acts.clear()
	_pending_prologue_acts.clear()
	_completed_prologue_acts.clear()


	# Retry
	if(_outcome == Outcome.RETRY):
		if(_can_perform_impl(true)):
			_status = Status.NONE
			_perform_impl()
			return


		# Change outcome to failure since could not retry
		_outcome = Outcome.FAILURE


	# Unblock & Continue Epilogues
	_unblock_others()
	_continue_epilogues(self, _outcome)
	_epilogue_acts.clear()
	_pending_epilogue_acts.clear()


	# Reset status
	_status = Status.NONE


	# Let theater know this act has ended
	if(_theater != null):
		_theater._unstage_ongoing(self)


	# Broadcast perform end
	on_perform_end.emit(self)
func _redirect(new_status: Status, new_outcome: Outcome = Outcome.PENDING):

	# None -> prologue
	if(_status == Status.NONE && new_status == Status.PROLOGUING):
		_prev_status = _status
		_status = Status.PROLOGUING
		_outcome = Outcome.PENDING
		_prologue_impl()

	# prologue -> Enter
	elif(_status == Status.PROLOGUING && new_status == Status.ENTERING):
		_prev_status = _status
		_status = Status.ENTERING
		_enter_impl()

	# Enter -> Tick
	elif(_status == Status.ENTERING && new_status == Status.TICKING):
		_prev_status = _status
		_status = Status.TICKING
		_handle_ticking_impl()

	# prologue or Enter or Tick -> Exit
	elif((_status == Status.PROLOGUING || _status == Status.ENTERING || _status == Status.TICKING) && new_status == Status.EXITING):
		_prev_status = _status
		_status = Status.EXITING
		_outcome = new_outcome
		_exit_impl()
func _to_string() -> String: 
	return _name # For easier debugging in editor
