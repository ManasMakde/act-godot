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


class_name Theater extends Node


# Public Signals
signal on_enable_changed(theater: Theater, new_enabled: bool)
signal on_perform_start(theater: Theater, act: Act)
signal on_perform_end(theater: Theater, act: Act)
signal on_all_perform_end(theater: Theater)


# Public Methods
func is_enabled() -> bool:
	return _is_enabled
func set_enabled(new_enabled: bool):

	if(new_enabled == _is_enabled):
		return

	_is_enabled = new_enabled

	if(!_is_enabled):
		abort_all()

	on_enable_changed.emit(self, _is_enabled)
func abort_all():

	# Return if already in between aborting all
	if(_is_aborting_all):
		return


	# Guard to avoid mutation
	_is_aborting_all = true


	# Abort all acts
	for act in _all_acts:
		act.abort()


	# Reset guard
	_is_aborting_all = false


	# Apply pending adds & removes after loop
	for act in _pending_mod_acts:
		if(_pending_mod_acts[act]):
			_all_acts[act] = true
		else:
			_all_acts.erase(act)
	_pending_mod_acts.clear()
func are_any_ongoing() -> bool:
	return !_ongoing_acts.is_empty()
func get_all_acts() -> Dictionary[Act, bool]:
	return _all_acts.duplicate()


# Private Properties
var _all_acts: Dictionary[Act, bool] = {}  # (Treat as HashSet)
var _ongoing_acts: Dictionary[Act, bool] = {}  # (Treat as HashSet)
var _pending_mod_acts: Dictionary[Act, bool] = {}

var _staged_defer_acts: Dictionary[Act, Act.TickFlags] = {}
var _staged_tick_acts: Dictionary[Act, bool] = {}
var _staged_physics_tick_acts: Dictionary[Act, bool] = {}

var _acts_to_defer: Dictionary[Act, Act.TickFlags] = {}
var _acts_to_tick: Dictionary[Act, bool] = {}
var _acts_to_physics_tick: Dictionary[Act, bool] = {}

var _defer_filter_list: Array[Act] = []
var _tick_filter_list: Array[Act] = []
var _physics_tick_filter_list: Array[Act] = []

var _is_aborting_all := false
var _is_enabled := true


# Private Staging Methods
func _add_act(new_act: Act):

	# Return if null act
	if(new_act == null):
		return


	# Mark as pending if abort all is ongoing
	if(_is_aborting_all):
		_pending_mod_acts[new_act] = true
		return


	_all_acts[new_act] = true
func _remove_act(old_act: Act):

	# Return if null act
	if(old_act == null):
		return


	# Mark as pending if abort all is ongoing
	if(_is_aborting_all):
		_pending_mod_acts[old_act] = false
		return


	# Unstage from everything
	_unstage_deferred(old_act)
	_unstage_tick(old_act)
	_unstage_physics_tick(old_act)


	_all_acts.erase(old_act)
func _stage_ongoing(act: Act):

	# Return if invalid act or already ongoing
	if(act == null || _ongoing_acts.has(act)):
		return


	# Mark as ongoing act
	_ongoing_acts[act] = true


	# Broadcast act started
	on_perform_start.emit(self, act)
func _unstage_ongoing(act: Act):

	# Return if act is null or was never staged ongoing
	if(act == null || !_ongoing_acts.has(act)):
		return


	# Remove as ongoing act
	_ongoing_acts.erase(act)


	# Broadcast act ended
	on_perform_end.emit(self, act)


	# Broadcast all ended if none ongoing
	if(!are_any_ongoing()):
		on_all_perform_end.emit(self)
func _stage_deferred(act: Act, flag: Act.TickFlags):

	if(act == null || flag == Act.TickFlags.NONE):
		return

	_staged_defer_acts[act] = ((_staged_defer_acts[act] | flag) if _staged_defer_acts.has(act) else flag) as Act.TickFlags
func _unstage_deferred(act: Act):

	if(act == null):
		return

	_staged_defer_acts.erase(act)
func _stage_tick(act: Act):

	if(act == null):
		return

	_staged_tick_acts[act] = true
func _unstage_tick(act: Act):

	if(act == null):
		return


	# Mark as pending removal if reference swapped else Remove
	if(_acts_to_tick.has(act)):
		_staged_tick_acts[act] = false
	elif(_staged_tick_acts.has(act)):
		_staged_tick_acts.erase(act)
func _stage_physics_tick(act: Act):

	if(act == null):
		return

	_staged_physics_tick_acts[act] = true
func _unstage_physics_tick(act: Act):

	if(act == null):
		return


	# Remove if not reference swapped yet else mark as pending removal
	if(_acts_to_physics_tick.has(act)):
		_staged_physics_tick_acts[act] = false
	elif(_staged_physics_tick_acts.has(act)):
		_staged_physics_tick_acts.erase(act)


# Private Static Methods
static func _tick_acts(staged_acts: Dictionary[Act, bool], acts_to_tick: Dictionary[Act, bool], filter_list: Array[Act], flag: Act.TickFlags):
	
	# Return if no act to process
	if(staged_acts.is_empty()):
		return


	# Reference swap to avoid mutation
	acts_to_tick.merge(staged_acts, true)
	staged_acts.clear()


	# Tick all acts based on flag
	for act in acts_to_tick:
		if(flag == Act.TickFlags.TICK):
			act._tick_impl()
		elif(flag == Act.TickFlags.PHYSICS_TICK):
			act._physics_tick_impl()


	# Merge back & clear
	staged_acts.merge(acts_to_tick, false)
	acts_to_tick.clear()


	# Filter using reused list to avoid alloc
	filter_list.clear()
	for act in staged_acts:
		if(!staged_acts[act]):
			filter_list.append(act)
	for act in filter_list:
		staged_acts.erase(act)
static func _defer_acts(deferred_acts: Dictionary[Act, Act.TickFlags], acts_to_defer: Dictionary[Act, Act.TickFlags], filter_list: Array[Act], flag: Act.TickFlags):
	
	# Return if no acts to defer
	if(deferred_acts.is_empty()):
		return


	# Reference swap to avoid mutation
	acts_to_defer.merge(deferred_acts, true)
	deferred_acts.clear()


	# Defer perform acts using reused list to avoid alloc
	filter_list.clear()
	for act in acts_to_defer:
		if((acts_to_defer[act] & flag) != 0):
			act.perform()
			filter_list.append(act)


	# Filter out
	for act in filter_list:
		acts_to_defer.erase(act)


	# Merge back unperformed
	deferred_acts.merge(acts_to_defer, false)
	acts_to_defer.clear()


# Private Override Methods
func _process(_delta: float):
	_tick_acts(_staged_tick_acts, _acts_to_tick, _tick_filter_list, Act.TickFlags.TICK)
	_defer_acts(_staged_defer_acts, _acts_to_defer, _defer_filter_list, Act.TickFlags.TICK)
func _physics_process(_delta: float):
	_tick_acts(_staged_physics_tick_acts, _acts_to_physics_tick, _physics_tick_filter_list, Act.TickFlags.PHYSICS_TICK)
	_defer_acts(_staged_defer_acts, _acts_to_defer, _defer_filter_list, Act.TickFlags.PHYSICS_TICK)
