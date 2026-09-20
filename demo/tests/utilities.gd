class_name Utilities extends RefCounted


# Not const to avoid enum cast warning
static var all_tick_flags: int = Act.TickFlags.TICK | Act.TickFlags.PHYSICS_TICK


static func assert_chain_cleared(test: GutTest, act: Act, prefix: String = "", suffix: String = ""):

	var act_name := act.get_name()
	test.assert_true(act._epilogue_acts.size() == 0, "%s%s epilogue acts not cleared%s! epilogue acts count=%d" % [prefix, act_name, suffix, act._epilogue_acts.size()])
	test.assert_true(act._pending_epilogue_acts.size() == 0, "%s%s pending epilogue acts not cleared%s! pending epilogue acts count=%d" % [prefix, act_name, suffix, act._pending_epilogue_acts.size()])
	test.assert_true(act._prologue_acts.size() == 0, "%s%s prologue acts not cleared%s! prologue acts count=%d" % [prefix, act_name, suffix, act._prologue_acts.size()])
	test.assert_true(act._pending_prologue_acts.size() == 0, "%s%s pending prologue acts not cleared%s! pending prologue acts count=%d" % [prefix, act_name, suffix, act._pending_prologue_acts.size()])
	test.assert_true(act._completed_prologue_acts.size() == 0, "%s%s completed prologue acts not cleared%s! completed prologue acts count=%d" % [prefix, act_name, suffix, act._completed_prologue_acts.size()])
class SetupAct extends Act:
	var call_count := 0
	func _setup():
		call_count += 1
class CanPerformAct extends Act:
	var call_count := 0
	func _can_perform() -> bool:
		call_count += 1
		return super()
class EnterAct extends Act:
	var call_count := 0
	func _enter() -> Outcome:
		call_count += 1
		return super()
class TickAct extends Act:
	var call_count := 0
	func _setup():
		_tick_flags = TickFlags.TICK
	func _tick() -> Outcome:
		call_count += 1
		return Outcome.PENDING
class PhysicsTickAct extends Act:
	var call_count := 0
	func _setup():
		_tick_flags = TickFlags.PHYSICS_TICK
	func _physics_tick() -> Outcome:
		call_count += 1
		return Outcome.PENDING
class ExitAct extends Act:
	var call_count := 0
	func _exit():
		call_count += 1
class CleanupAct extends Act:
	var call_count := 0
	func _cleanup():
		call_count += 1
class WaitInfiniAct extends Act:
	func _enter() -> Outcome:
		return Outcome.PENDING
class ReperformableAct extends Act:
	func _setup():
		_can_reperform = true
class NonReperformableInfiAct extends Act:
	func _setup():
		_can_reperform = false
	func _enter() -> Outcome:
		return Outcome.PENDING
class ReperformableInfiAct extends Act:
	var override_tick_flag: Act.TickFlags = Act.TickFlags.NONE
	func _setup():
		_can_reperform = true
		_tick_flags = override_tick_flag
	func _enter() -> Outcome:
		return Outcome.PENDING
class FalseCanPerformAct extends Act:
	func _can_perform() -> bool:
		return false
	func _enter() -> Outcome:
		return Outcome.PENDING
class FailingAct extends Act:
	func _enter() -> Outcome:
		return Outcome.FAILURE
class SingleTickAct extends Act:
	func _setup():
		_tick_flags = TickFlags.TICK
	func _tick() -> Outcome:
		return Outcome.SUCCESS if get_tick_count() >= 1 else Outcome.PENDING
class ManualFinishAct extends Act:
	var can_reperform_override := false
	var override_tick_flags: Act.TickFlags = Act.TickFlags.NONE
	func manual_finish(outcome: Outcome = Outcome.SUCCESS):
		_finish(outcome)
	func _setup():
		_can_reperform = can_reperform_override
		_tick_flags = override_tick_flags
	func _enter() -> Outcome:
		return Outcome.PENDING
class NoneTickAct extends Act:
	func _setup():
		_tick_flags = TickFlags.NONE
class RetryAct extends Act:
	var enter_call_count := 0
	var retry_limit := 1
	func _enter() -> Outcome:
		enter_call_count += 1
		return Outcome.RETRY if enter_call_count <= retry_limit else Outcome.SUCCESS
class RetryOnceThenFailAct extends Act:
	var enter_call_count := 0
	func _enter() -> Outcome:
		enter_call_count += 1
		return Outcome.RETRY if enter_call_count == 1 else Outcome.SUCCESS
	func _can_perform() -> bool:
		return enter_call_count == 0  # Block retry attempt after first enter
class RetryingCheckAct extends Act:
	var retrying_in_setup := false
	var retrying_in_enter := false
	var retrying_in_tick := false
	var retrying_in_physics_tick := false
	var retrying_in_exit := false
	var retrying_in_cleanup := false

	func _setup():
		_can_reperform = true
		_tick_flags = Utilities.all_tick_flags as TickFlags
		retrying_in_setup = is_retrying()
	func _enter() -> Outcome:
		retrying_in_enter = is_retrying()
		return Outcome.PENDING
	func _tick() -> Outcome:
		retrying_in_tick = is_retrying()
		return Outcome.PENDING
	func _physics_tick() -> Outcome:
		retrying_in_physics_tick = is_retrying()
		return Outcome.PENDING
	func _exit():
		retrying_in_exit = is_retrying()
	func _cleanup():
		retrying_in_cleanup = is_retrying()
class OngoingCheckAct extends Act:
	var ongoing_in_setup := false
	var ongoing_in_enter := false
	var ongoing_in_tick := false
	var ongoing_in_physics_tick := false
	var ongoing_in_exit := false
	var ongoing_in_cleanup := false

	func force_finish(outcome: Outcome = Outcome.SUCCESS):
		_finish(outcome)
	func _setup():
		_tick_flags = Utilities.all_tick_flags as TickFlags
		ongoing_in_setup = is_ongoing()
	func _enter() -> Outcome:
		ongoing_in_enter = is_ongoing()
		return Outcome.PENDING
	func _tick() -> Outcome:
		ongoing_in_tick = is_ongoing()
		return Outcome.PENDING
	func _physics_tick() -> Outcome:
		ongoing_in_physics_tick = is_ongoing()
		return Outcome.PENDING
	func _exit():
		ongoing_in_exit = is_ongoing()
	func _cleanup():
		ongoing_in_cleanup = is_ongoing()
class ActiveCheckAct extends Act:
	var active_in_setup := false
	var active_in_enter := false
	var active_in_tick := false
	var active_in_physics_tick := false
	var active_in_exit := false
	var active_in_cleanup := false

	func force_finish(outcome: Outcome = Outcome.SUCCESS):
		_finish(outcome)
	func _setup():
		_tick_flags = Utilities.all_tick_flags as TickFlags
		active_in_setup = is_active()
	func _enter() -> Outcome:
		active_in_enter = is_active()
		return Outcome.PENDING
	func _tick() -> Outcome:
		active_in_tick = is_active()
		return Outcome.PENDING
	func _physics_tick() -> Outcome:
		active_in_physics_tick = is_active()
		return Outcome.PENDING
	func _exit():
		active_in_exit = is_active()
	func _cleanup():
		active_in_cleanup = is_active()
class StatusCheckAct extends Act:
	var status_in_setup := Status.NONE
	var status_in_enter := Status.NONE
	var status_in_tick := Status.NONE
	var status_in_physics_tick := Status.NONE
	var status_in_exit := Status.NONE
	var status_in_cleanup := Status.NONE

	func force_finish(outcome: Outcome = Outcome.SUCCESS):
		_finish(outcome)
	func _setup():
		_tick_flags = Utilities.all_tick_flags as TickFlags
		status_in_setup = get_status()
	func _enter() -> Outcome:
		status_in_enter = get_status()
		return Outcome.PENDING
	func _tick() -> Outcome:
		status_in_tick = get_status()
		return Outcome.PENDING
	func _physics_tick() -> Outcome:
		status_in_physics_tick = get_status()
		return Outcome.PENDING
	func _exit():
		status_in_exit = get_status()
	func _cleanup():
		status_in_cleanup = get_status()
