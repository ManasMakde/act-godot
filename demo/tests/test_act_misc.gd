extends GutTest


# 1. Is did_perform_in_tick() valid everywhere?
# 1. Is is_retrying() valid everywhere?
# 1. Is is_ongoing() valid everywhere?
# 1. Is is_active() valid everywhere?
# 1. Is is_enabled() valid in every combination?
# 1. Is is_blocked() valid in every combination?

# 1. Is can_tick() valid in every combination?
# 1. Is can_tick() false when no tick flags?

# 1. Is get_theater() return accurate theater?
# 1. Is get_theater() return null when no theater is assigned?

# 1. Is get_owner() return accurate owner?
# 1. Is get_owner() return null when no theater is assigned?

# 1. Is get_blocked_by_acts() return accurate acts?
# 1. Is get_acts_to_block() return accurate acts?

# 1. Is get_status() valid everywhere?
# 1. Is get_status() return NONE before and after perform?

# 1. Is get_outcome() return accurate outcome after exiting? (Check for all outcomes)

# 1. Is get_perform_count() give accurate perform counts?
# 1. Is get_tick_count() give accurate tick counts?
# 1. Is get_physics_tick_count() give accurate tick counts?

# 1. get_name() return accurate value?


func test_did_perform_in_tick_valid():

	# Tick
	var act_tick: Act = autofree(Act.new())
	act_tick.init()
	act_tick.perform()

	var performed_same_tick_1 := act_tick.did_perform_in_tick(Act.TickFlags.TICK)
	var performed_same_tick_2 := act_tick.did_perform_in_tick(Act.TickFlags.TICK)

	await wait_process_frames(1)

	var performed_next_1_tick := act_tick.did_perform_in_tick(Act.TickFlags.TICK)
	var performed_next_2_tick := act_tick.did_perform_in_tick(Act.TickFlags.TICK)


	# Assertions
	assert_true(performed_same_tick_1 && performed_same_tick_2, "did_perform_in_tick() invalid in same tick! performed_same_tick_1=%s  performed_same_tick_2=%s" % [performed_same_tick_1, performed_same_tick_2])
	assert_true(!performed_next_1_tick && !performed_next_2_tick, "did_perform_in_tick() invalid in next tick! performed_next_1_tick=%s  performed_next_2_tick=%s" % [performed_next_1_tick, performed_next_2_tick])

	await wait_process_frames(1)


	# Physics Tick
	var act_physics: Act = autofree(Act.new())
	act_physics.init()
	act_physics.perform()

	var performed_same_physics_tick_1 := act_physics.did_perform_in_tick(Act.TickFlags.PHYSICS_TICK)
	var performed_same_physics_tick_2 := act_physics.did_perform_in_tick(Act.TickFlags.PHYSICS_TICK)

	await wait_physics_frames(1)

	var performed_next_1_physics_tick := act_physics.did_perform_in_tick(Act.TickFlags.PHYSICS_TICK)
	var performed_next_2_physics_tick := act_physics.did_perform_in_tick(Act.TickFlags.PHYSICS_TICK)


	# Assertions
	assert_true(performed_same_physics_tick_1 && performed_same_physics_tick_2, "did_perform_in_tick() invalid in same physics tick! performed_same_physics_tick_1=%s  performed_same_physics_tick_2=%s" % [performed_same_physics_tick_1, performed_same_physics_tick_2])
	assert_true(!performed_next_1_physics_tick && !performed_next_2_physics_tick, "did_perform_in_tick() invalid in next physics tick! performed_next_1_physics_tick=%s  performed_next_2_physics_tick=%s" % [performed_next_1_physics_tick, performed_next_2_physics_tick])

	await wait_process_frames(1)
func test_is_retrying_valid():

	# Prerequisites
	var theater := Theater.new()
	theater.name = "Misc Retrying Theater"
	add_child(theater)
	var prologue_act: Act = autofree(Act.new())
	prologue_act.init("Prologue Act")

	var retrying_in_pre_setup := [false]
	var retrying_in_post_setup := [false]
	var retrying_in_perform_start := [false]
	var retrying_in_pre_prologue := [false]
	var retrying_in_prologue_complete := [false]
	var retrying_in_post_prologue := [false]
	var retrying_in_pre_enter := [false]
	var retrying_in_post_enter := [false]
	var retrying_in_pre_tick := [false]
	var retrying_in_post_tick := [false]
	var retrying_in_pre_physics_tick := [false]
	var retrying_in_post_physics_tick := [false]
	var retrying_in_pre_exit := [false]
	var retrying_in_post_exit := [false]
	var retrying_in_perform_end := [false]
	var retrying_in_pre_cleanup := [false]
	var retrying_in_post_cleanup := [false]
	var retrying_in_enable_changed := [false]
	var retrying_in_block_changed := [false]


	# Perform Act
	var act: Utilities.RetryingCheckAct = autofree(Utilities.RetryingCheckAct.new())
	act.on_pre_setup.connect(func(a): retrying_in_pre_setup[0] = a.is_retrying())
	act.on_post_setup.connect(func(a): retrying_in_post_setup[0] = a.is_retrying())
	act.on_perform_start.connect(func(a): retrying_in_perform_start[0] = a.is_retrying())
	act.on_pre_prologue.connect(func(a): retrying_in_pre_prologue[0] = a.is_retrying())
	act.on_prologue_complete.connect(func(a, p_act, p_outcome): retrying_in_prologue_complete[0] = a.is_retrying())
	act.on_post_prologue.connect(func(a): retrying_in_post_prologue[0] = a.is_retrying())
	act.on_pre_enter.connect(func(a): retrying_in_pre_enter[0] = a.is_retrying())
	act.on_post_enter.connect(func(a): retrying_in_post_enter[0] = a.is_retrying())
	act.on_pre_tick.connect(func(a): retrying_in_pre_tick[0] = a.is_retrying())
	act.on_post_tick.connect(func(a): retrying_in_post_tick[0] = a.is_retrying())
	act.on_pre_physics_tick.connect(func(a): retrying_in_pre_physics_tick[0] = a.is_retrying())
	act.on_post_physics_tick.connect(func(a): retrying_in_post_physics_tick[0] = a.is_retrying())
	act.on_pre_exit.connect(func(a): retrying_in_pre_exit[0] = a.is_retrying())
	act.on_post_exit.connect(func(a): retrying_in_post_exit[0] = a.is_retrying())
	act.on_perform_end.connect(func(a): retrying_in_perform_end[0] = a.is_retrying())
	act.on_pre_cleanup.connect(func(a): retrying_in_pre_cleanup[0] = a.is_retrying())
	act.on_post_cleanup.connect(func(a): retrying_in_post_cleanup[0] = a.is_retrying())
	act.on_enable_changed.connect(func(a, new_is_enabled): retrying_in_enable_changed[0] = a.is_retrying())
	act.on_block_changed.connect(func(a, blocking_act, block_type, did_block): retrying_in_block_changed[0] = a.is_retrying())
	act.prologue = func(a) -> Array[Act]: return [prologue_act]
	act.init("Misc Retrying Act", theater)

	act.perform()

	await wait_physics_frames(1)
	await wait_physics_frames(1)
	await wait_process_frames(1)
	await wait_process_frames(1)

	act.retry()

	await wait_physics_frames(1)
	await wait_physics_frames(1)
	await wait_process_frames(1)
	await wait_process_frames(1)

	act.abort()

	await wait_physics_frames(1)
	await wait_physics_frames(1)
	await wait_process_frames(1)
	await wait_process_frames(1)

	var retrying_after_finish := act.is_retrying()

	act.deinit()


	# Assertions
	assert_true(!retrying_in_pre_setup[0], "is_retrying() true in on_pre_setup!")
	assert_true(!act.retrying_in_setup, "is_retrying() true in _setup()!")
	assert_true(!retrying_in_post_setup[0], "is_retrying() true in on_post_setup!")

	assert_true(retrying_in_perform_start[0], "is_retrying() false in on_perform_start!")
	assert_true(retrying_in_pre_prologue[0], "is_retrying() false in on_pre_prologue!")
	assert_true(retrying_in_prologue_complete[0], "is_retrying() false in on_prologue_complete!")
	assert_true(retrying_in_post_prologue[0], "is_retrying() false in on_post_prologue!")

	assert_true(retrying_in_pre_enter[0], "is_retrying() false in on_pre_enter!")
	assert_true(act.retrying_in_enter, "is_retrying() false in _enter()!")
	assert_true(retrying_in_post_enter[0], "is_retrying() false in on_post_enter!")

	assert_true(retrying_in_pre_tick[0], "is_retrying() false in on_pre_tick!")
	assert_true(act.retrying_in_tick, "is_retrying() false in _tick()!")
	assert_true(retrying_in_post_tick[0], "is_retrying() false in on_post_tick!")

	assert_true(retrying_in_pre_physics_tick[0], "is_retrying() false in on_pre_physics_tick!")
	assert_true(act.retrying_in_physics_tick, "is_retrying() false in _physics_tick()!")
	assert_true(retrying_in_post_physics_tick[0], "is_retrying() false in on_post_physics_tick!")

	assert_true(retrying_in_pre_exit[0], "is_retrying() false in on_pre_exit!")
	assert_true(act.retrying_in_exit, "is_retrying() false in _exit()!")
	assert_true(retrying_in_post_exit[0], "is_retrying() false in on_post_exit!")

	assert_true(!retrying_in_perform_end[0], "is_retrying() true in on_perform_end!")

	assert_true(!retrying_after_finish, "is_retrying() true even after act has finished perform!")

	assert_true(!retrying_in_pre_cleanup[0], "is_retrying() true in on_pre_cleanup!")
	assert_true(!act.retrying_in_cleanup, "is_retrying() true in _cleanup()!")
	assert_true(!retrying_in_post_cleanup[0], "is_retrying() true in on_post_cleanup!")

	assert_true(!retrying_in_enable_changed[0], "is_retrying() true in on_enable_changed!")
	assert_true(!retrying_in_block_changed[0], "is_retrying() true in on_block_changed!")

	theater.free()

	await wait_process_frames(1)
func test_is_ongoing_valid():

	# Prerequisites
	var theater := Theater.new()
	theater.name = "Misc Ongoing Theater"
	add_child(theater)
	var prologue_act: Act = autofree(Act.new())
	prologue_act.init("Prologue Act")

	var ongoing_in_pre_setup := [false]
	var ongoing_in_post_setup := [false]
	var ongoing_in_perform_start := [false]
	var ongoing_in_pre_prologue := [false]
	var ongoing_in_prologue_complete := [false]
	var ongoing_in_post_prologue := [false]
	var ongoing_in_pre_enter := [false]
	var ongoing_in_post_enter := [false]
	var ongoing_in_pre_tick := [false]
	var ongoing_in_post_tick := [false]
	var ongoing_in_pre_physics_tick := [false]
	var ongoing_in_post_physics_tick := [false]
	var ongoing_in_pre_exit := [false]
	var ongoing_in_post_exit := [false]
	var ongoing_in_perform_end := [false]
	var ongoing_in_pre_cleanup := [false]
	var ongoing_in_post_cleanup := [false]
	var ongoing_in_enable_changed := [false]
	var ongoing_in_block_changed := [false]


	# Perform Act
	var act: Utilities.OngoingCheckAct = autofree(Utilities.OngoingCheckAct.new())
	act.on_pre_setup.connect(func(a): ongoing_in_pre_setup[0] = a.is_ongoing())
	act.on_post_setup.connect(func(a): ongoing_in_post_setup[0] = a.is_ongoing())
	act.on_perform_start.connect(func(a): ongoing_in_perform_start[0] = a.is_ongoing())
	act.on_pre_prologue.connect(func(a): ongoing_in_pre_prologue[0] = a.is_ongoing())
	act.on_prologue_complete.connect(func(a, p_act, p_outcome): ongoing_in_prologue_complete[0] = a.is_ongoing())
	act.on_post_prologue.connect(func(a): ongoing_in_post_prologue[0] = a.is_ongoing())
	act.on_pre_enter.connect(func(a): ongoing_in_pre_enter[0] = a.is_ongoing())
	act.on_post_enter.connect(func(a): ongoing_in_post_enter[0] = a.is_ongoing())
	act.on_pre_tick.connect(func(a): ongoing_in_pre_tick[0] = a.is_ongoing())
	act.on_post_tick.connect(func(a): ongoing_in_post_tick[0] = a.is_ongoing())
	act.on_pre_physics_tick.connect(func(a): ongoing_in_pre_physics_tick[0] = a.is_ongoing())
	act.on_post_physics_tick.connect(func(a): ongoing_in_post_physics_tick[0] = a.is_ongoing())
	act.on_pre_exit.connect(func(a): ongoing_in_pre_exit[0] = a.is_ongoing())
	act.on_post_exit.connect(func(a): ongoing_in_post_exit[0] = a.is_ongoing())
	act.on_perform_end.connect(func(a): ongoing_in_perform_end[0] = a.is_ongoing())
	act.on_pre_cleanup.connect(func(a): ongoing_in_pre_cleanup[0] = a.is_ongoing())
	act.on_post_cleanup.connect(func(a): ongoing_in_post_cleanup[0] = a.is_ongoing())
	act.on_enable_changed.connect(func(a, new_is_enabled): ongoing_in_enable_changed[0] = a.is_ongoing())
	act.on_block_changed.connect(func(a, blocking_act, block_type, did_block): ongoing_in_block_changed[0] = a.is_ongoing())
	act.prologue = func(a) -> Array[Act]: return [prologue_act]
	act.init("Misc Ongoing Act", theater)

	act.perform()

	await wait_physics_frames(1)
	await wait_physics_frames(1)
	await wait_process_frames(1)
	await wait_process_frames(1)

	act.force_finish()
	var ongoing_after_finish := act.is_ongoing()

	act.deinit()


	# Assertions
	assert_true(!ongoing_in_pre_setup[0], "is_ongoing() true in on_pre_setup!")
	assert_true(!act.ongoing_in_setup, "is_ongoing() true in _setup()!")
	assert_true(!ongoing_in_post_setup[0], "is_ongoing() true in on_post_setup!")

	assert_true(ongoing_in_perform_start[0], "is_ongoing() false in on_perform_start!")
	assert_true(ongoing_in_pre_prologue[0], "is_ongoing() false in on_pre_prologue!")
	assert_true(ongoing_in_prologue_complete[0], "is_ongoing() false in on_prologue_complete!")
	assert_true(ongoing_in_post_prologue[0], "is_ongoing() false in on_post_prologue!")

	assert_true(ongoing_in_pre_enter[0], "is_ongoing() false in on_pre_enter!")
	assert_true(act.ongoing_in_enter, "is_ongoing() false in _enter()!")
	assert_true(ongoing_in_post_enter[0], "is_ongoing() false in on_post_enter!")

	assert_true(ongoing_in_pre_tick[0], "is_ongoing() false in on_pre_tick!")
	assert_true(act.ongoing_in_tick, "is_ongoing() false in _tick()!")
	assert_true(ongoing_in_post_tick[0], "is_ongoing() false in on_post_tick!")

	assert_true(ongoing_in_pre_physics_tick[0], "is_ongoing() false in on_pre_physics_tick!")
	assert_true(act.ongoing_in_physics_tick, "is_ongoing() false in _physics_tick()!")
	assert_true(ongoing_in_post_physics_tick[0], "is_ongoing() false in on_post_physics_tick!")

	assert_true(ongoing_in_pre_exit[0], "is_ongoing() false in on_pre_exit!")
	assert_true(act.ongoing_in_exit, "is_ongoing() false in _exit()!")
	assert_true(ongoing_in_post_exit[0], "is_ongoing() false in on_post_exit!")

	assert_true(!ongoing_in_perform_end[0], "is_ongoing() true in on_perform_end!")

	assert_true(!ongoing_after_finish, "is_ongoing() true even after act has finished perform!")

	assert_true(!ongoing_in_pre_cleanup[0], "is_ongoing() true in on_pre_cleanup!")
	assert_true(!act.ongoing_in_cleanup, "is_ongoing() true in _cleanup()!")
	assert_true(!ongoing_in_post_cleanup[0], "is_ongoing() true in on_post_cleanup!")

	assert_true(!ongoing_in_enable_changed[0], "is_ongoing() true in on_enable_changed!")
	assert_true(!ongoing_in_block_changed[0], "is_ongoing() true in on_block_changed!")

	theater.free()

	await wait_process_frames(1)
func test_is_active_valid():

	# Prerequisites
	var theater := Theater.new()
	theater.name = "Misc Active Theater"
	add_child(theater)
	var prologue_act: Act = autofree(Act.new())
	prologue_act.init("Prologue Act")

	var active_in_pre_setup := [false]
	var active_in_post_setup := [false]
	var active_in_perform_start := [false]
	var active_in_pre_prologue := [false]
	var active_in_prologue_complete := [false]
	var active_in_post_prologue := [false]
	var active_in_pre_enter := [false]
	var active_in_post_enter := [false]
	var active_in_pre_tick := [false]
	var active_in_post_tick := [false]
	var active_in_pre_physics_tick := [false]
	var active_in_post_physics_tick := [false]
	var active_in_pre_exit := [false]
	var active_in_post_exit := [false]
	var active_in_perform_end := [false]
	var active_in_pre_cleanup := [false]
	var active_in_post_cleanup := [false]
	var active_in_enable_changed := [false]
	var active_in_block_changed := [false]


	# Perform Act
	var act: Utilities.ActiveCheckAct = autofree(Utilities.ActiveCheckAct.new())
	act.on_pre_setup.connect(func(a): active_in_pre_setup[0] = a.is_active())
	act.on_post_setup.connect(func(a): active_in_post_setup[0] = a.is_active())
	act.on_perform_start.connect(func(a): active_in_perform_start[0] = a.is_active())
	act.on_pre_prologue.connect(func(a): active_in_pre_prologue[0] = a.is_active())
	act.on_prologue_complete.connect(func(a, p_act, p_outcome): active_in_prologue_complete[0] = a.is_active())
	act.on_post_prologue.connect(func(a): active_in_post_prologue[0] = a.is_active())
	act.on_pre_enter.connect(func(a): active_in_pre_enter[0] = a.is_active())
	act.on_post_enter.connect(func(a): active_in_post_enter[0] = a.is_active())
	act.on_pre_tick.connect(func(a): active_in_pre_tick[0] = a.is_active())
	act.on_post_tick.connect(func(a): active_in_post_tick[0] = a.is_active())
	act.on_pre_physics_tick.connect(func(a): active_in_pre_physics_tick[0] = a.is_active())
	act.on_post_physics_tick.connect(func(a): active_in_post_physics_tick[0] = a.is_active())
	act.on_pre_exit.connect(func(a): active_in_pre_exit[0] = a.is_active())
	act.on_post_exit.connect(func(a): active_in_post_exit[0] = a.is_active())
	act.on_perform_end.connect(func(a): active_in_perform_end[0] = a.is_active())
	act.on_pre_cleanup.connect(func(a): active_in_pre_cleanup[0] = a.is_active())
	act.on_post_cleanup.connect(func(a): active_in_post_cleanup[0] = a.is_active())
	act.on_enable_changed.connect(func(a, new_is_enabled): active_in_enable_changed[0] = a.is_active())
	act.on_block_changed.connect(func(a, blocking_act, block_type, did_block): active_in_block_changed[0] = a.is_active())
	act.prologue = func(a) -> Array[Act]: return [prologue_act]
	act.init("Misc Active Act", theater)

	act.perform()

	await wait_physics_frames(1)
	await wait_physics_frames(1)
	await wait_process_frames(1)
	await wait_process_frames(1)

	act.force_finish()
	var active_after_finish := act.is_active()

	act.deinit()


	# Assertions
	assert_true(!active_in_pre_setup[0], "is_active() true in on_pre_setup!")
	assert_true(!act.active_in_setup, "is_active() true in _setup()!")
	assert_true(!active_in_post_setup[0], "is_active() true in on_post_setup!")

	assert_true(!active_in_perform_start[0], "is_active() true in on_perform_start!")
	assert_true(!active_in_pre_prologue[0], "is_active() true in on_pre_prologue!")
	assert_true(!active_in_prologue_complete[0], "is_active() true in on_prologue_complete!")
	assert_true(!active_in_post_prologue[0], "is_active() true in on_post_prologue!")

	assert_true(active_in_pre_enter[0], "is_active() false in on_pre_enter!")
	assert_true(act.active_in_enter, "is_active() false in _enter()!")
	assert_true(active_in_post_enter[0], "is_active() false in on_post_enter!")

	assert_true(active_in_pre_tick[0], "is_active() false in on_pre_tick!")
	assert_true(act.active_in_tick, "is_active() false in _tick()!")
	assert_true(active_in_post_tick[0], "is_active() false in on_post_tick!")

	assert_true(active_in_pre_physics_tick[0], "is_active() false in on_pre_physics_tick!")
	assert_true(act.active_in_physics_tick, "is_active() false in _physics_tick()!")
	assert_true(active_in_post_physics_tick[0], "is_active() false in on_post_physics_tick!")

	assert_true(active_in_pre_exit[0], "is_active() false in on_pre_exit!")
	assert_true(act.active_in_exit, "is_active() false in _exit()!")
	assert_true(active_in_post_exit[0], "is_active() false in on_post_exit!")

	assert_true(!active_in_perform_end[0], "is_active() true in on_perform_end!")

	assert_true(!active_after_finish, "is_active() true even after act has finished perform!")

	assert_true(!active_in_pre_cleanup[0], "is_active() true in on_pre_cleanup!")
	assert_true(!act.active_in_cleanup, "is_active() true in _cleanup()!")
	assert_true(!active_in_post_cleanup[0], "is_active() true in on_post_cleanup!")

	assert_true(!active_in_enable_changed[0], "is_active() true in on_enable_changed!")
	assert_true(!active_in_block_changed[0], "is_active() true in on_block_changed!")

	theater.free()

	await wait_process_frames(1)
func test_is_enabled_valid():

	# Enabled by default
	var enabled_act: Act = autofree(Act.new())
	enabled_act.init("Enabled Act")
	enabled_act.set_enabled(true)


	# Assertions
	assert_true(enabled_act.is_enabled(), "is_enabled() false despite never being disabled!")

	await wait_process_frames(1)


	# Disabled
	var disabled_act: Act = autofree(Act.new())
	disabled_act.init("Misc Disabled Act")
	disabled_act.set_enabled(false)


	# Assertions
	assert_false(disabled_act.is_enabled(), "is_enabled() true despite being disabled!")

	await wait_process_frames(1)


	# Disabled then enabled
	var re_enabled_act: Act = autofree(Act.new())
	re_enabled_act.init("Misc Reenabled Act")
	re_enabled_act.set_enabled(false)
	re_enabled_act.set_enabled(true)


	# Assertions
	assert_true(re_enabled_act.is_enabled(), "is_enabled() false despite being reenabled!")

	await wait_process_frames(1)
func test_is_blocked_valid():

	var blocked_act: Act = autofree(Act.new())
	blocked_act.init("Misc Target Act")

	var blocker: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	blocker.add_to_block([blocked_act], Act.BlockType.PERSISTENT)
	blocker.init("Misc Blocker Act")

	blocker.perform()

	var is_blocked_while_blocking := blocked_act.is_blocked()
	blocker.manual_finish()
	var is_blocked_after_unblock := blocked_act.is_blocked()


	# Assertions
	assert_true(is_blocked_while_blocking, "is_blocked() false while persistently blocked!")
	assert_true(!is_blocked_after_unblock, "is_blocked() true after persistently unblocked!")

	await wait_process_frames(1)


func test_can_tick_flag_combos():

	# Prerequisites
	var all_combos: Array[Act.TickFlags] = [
		Act.TickFlags.TICK,
		Act.TickFlags.PHYSICS_TICK,
		(Act.TickFlags.TICK | Act.TickFlags.PHYSICS_TICK) as Act.TickFlags,
	]

	# Perform Act
	for combo in all_combos:
		var act: Utilities.ReperformableInfiAct = autofree(Utilities.ReperformableInfiAct.new())
		act.override_tick_flag = combo
		act.init("Misc Tick Flag Act")

		var expect_tick := (combo & Act.TickFlags.TICK) != 0
		var expect_physics_tick := (combo & Act.TickFlags.PHYSICS_TICK) != 0


		# Assertions
		assert_true(act.can_tick(Act.TickFlags.TICK) == expect_tick, "can_tick(TICK) wrong for combo='%s'" % [combo])
		assert_true(act.can_tick(Act.TickFlags.PHYSICS_TICK) == expect_physics_tick, "can_tick(PHYSICS_TICK) wrong for combo='%s'" % [combo])

	await wait_process_frames(1)
func test_can_tick_no_flags():

	# Perform Act
	var act: Utilities.ReperformableInfiAct = autofree(Utilities.ReperformableInfiAct.new())
	act.override_tick_flag = Act.TickFlags.NONE
	act.init("Misc No Tick Flag Act")


	# Assertions
	assert_false(act.can_tick(Act.TickFlags.TICK), "can_tick(TICK) true despite no flags assigned!")
	assert_false(act.can_tick(Act.TickFlags.PHYSICS_TICK), "can_tick(PHYSICS_TICK) true despite no flags assigned!")

	await wait_process_frames(1)


func test_get_theater_accurate():

	# Prerequisites
	var theater := Theater.new()
	theater.name = "Misc Theater Get Theater"
	add_child(theater)
	var act: Act = autofree(Act.new())
	act.init("Misc Theater Act", theater)


	# Assertions
	assert_true(act.get_theater() == theater, "get_theater() did not return assigned theater!")

	theater.free()

	await wait_process_frames(1)
func test_get_theater_null_when_not_assigned():

	# Perform Act
	var act: Act = autofree(Act.new())
	act.init("Misc No Theater Act")


	# Assertions
	assert_true(act.get_theater() == null, "get_theater() not null despite no theater assigned!")

	await wait_process_frames(1)


func test_get_owner_accurate():

	# Prerequisites
	var theater_owner := Node.new()
	theater_owner.name = "Misc Owner Get Theater"
	add_child(theater_owner)
	var theater := Theater.new()
	theater_owner.add_child(theater)

	# Perform Act
	var act: Act = autofree(Act.new())
	act.init("Misc Owner Act", theater)


	# Assertions
	assert_true(act.get_owner() == theater_owner, "get_owner() did not return theater owner node!")

	theater_owner.free()

	await wait_process_frames(1)
func test_get_owner_null_when_not_assigned():

	# Perform Act
	var act: Act = autofree(Act.new())
	act.init("Misc No Owner Act")


	# Assertions
	assert_true(act.get_owner() == null, "get_owner() not null despite no theater assigned!")

	await wait_process_frames(1)


func test_get_blocked_by_acts_valid():

	# Prerequisites
	var blocked_act: Act = autofree(Act.new())
	var blocker_act_1: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	var blocker_act_2: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())

	blocked_act.init("Blocked Act")
	blocker_act_1.init("Blocker Act 1")
	blocker_act_2.init("Blocker Act 2")
	blocker_act_1.add_to_block([blocked_act])
	blocker_act_2.add_to_block([blocked_act])

	# Perform Act
	blocker_act_1.perform()
	blocker_act_2.perform()

	var blocked_by_acts := blocked_act.get_blocked_by_acts()


	# Assertions
	assert_true(blocked_by_acts.has(blocker_act_1), "get_blocked_by_acts() does not contain blocker_act_1!")
	assert_true(blocked_by_acts.has(blocker_act_2), "get_blocked_by_acts() does not contain blocker_act_2!")
	assert_true(blocked_by_acts.size() == 2, "get_blocked_by_acts() returned incorrect count! Count=%d" % [blocked_by_acts.size()])

	await wait_process_frames(1)
func test_get_acts_to_block_valid():

	# Prerequisites
	var target_act_1: Act = autofree(Act.new())
	var target_act_2: Act = autofree(Act.new())
	var main_act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())

	target_act_1.init("Target Act 1")
	target_act_2.init("Target Act 2")
	main_act.init("Main Act")
	main_act.add_to_block([target_act_1], Act.BlockType.PERSISTENT)
	main_act.add_to_block([target_act_2], Act.BlockType.INTERRUPT)

	# Perform Act
	var acts_to_block := main_act.get_acts_to_block()


	# Assertions
	assert_true(acts_to_block.has(target_act_1) && acts_to_block[target_act_1] == Act.BlockType.PERSISTENT, "get_acts_to_block() invalid for persistent entry!")
	assert_true(acts_to_block.has(target_act_2) && acts_to_block[target_act_2] == Act.BlockType.INTERRUPT, "get_acts_to_block() invalid for interrupt entry!")
	assert_true(acts_to_block.size() == 2, "get_acts_to_block() returned incorrect count! Count=%d" % [acts_to_block.size()])

	await wait_process_frames(1)


func test_get_status():

	# Prerequisites
	var theater := Theater.new()
	theater.name = "Misc Status Theater"
	add_child(theater)

	var prologue_act: Act = autofree(Act.new())
	prologue_act.init("Prologue Act")

	var status_before_perform := Act.Status.NONE
	var status_after_perform := Act.Status.NONE
	var status_in_pre_setup := [Act.Status.NONE]
	var status_in_post_setup := [Act.Status.NONE]
	var status_in_perform_start := [Act.Status.NONE]
	var status_in_pre_prologue := [Act.Status.NONE]
	var status_in_prologue_complete := [Act.Status.NONE]
	var status_in_post_prologue := [Act.Status.NONE]
	var status_in_pre_enter := [Act.Status.NONE]
	var status_in_post_enter := [Act.Status.NONE]
	var status_in_pre_tick := [Act.Status.NONE]
	var status_in_post_tick := [Act.Status.NONE]
	var status_in_pre_physics_tick := [Act.Status.NONE]
	var status_in_post_physics_tick := [Act.Status.NONE]
	var status_in_pre_exit := [Act.Status.NONE]
	var status_in_post_exit := [Act.Status.NONE]
	var status_in_perform_end := [Act.Status.NONE]
	var status_in_pre_cleanup := [Act.Status.NONE]
	var status_in_post_cleanup := [Act.Status.NONE]


	var act: Utilities.StatusCheckAct = autofree(Utilities.StatusCheckAct.new())
	act.on_pre_setup.connect(func(a): status_in_pre_setup[0] = a.get_status())
	act.on_post_setup.connect(func(a): status_in_post_setup[0] = a.get_status())
	act.on_perform_start.connect(func(a): status_in_perform_start[0] = a.get_status())
	act.on_pre_prologue.connect(func(a): status_in_pre_prologue[0] = a.get_status())
	act.on_prologue_complete.connect(func(a, p_act, p_outcome): status_in_prologue_complete[0] = a.get_status())
	act.on_post_prologue.connect(func(a): status_in_post_prologue[0] = a.get_status())
	act.on_pre_enter.connect(func(a): status_in_pre_enter[0] = a.get_status())
	act.on_post_enter.connect(func(a): status_in_post_enter[0] = a.get_status())
	act.on_pre_tick.connect(func(a): status_in_pre_tick[0] = a.get_status())
	act.on_post_tick.connect(func(a): status_in_post_tick[0] = a.get_status())
	act.on_pre_physics_tick.connect(func(a): status_in_pre_physics_tick[0] = a.get_status())
	act.on_post_physics_tick.connect(func(a): status_in_post_physics_tick[0] = a.get_status())
	act.on_pre_exit.connect(func(a): status_in_pre_exit[0] = a.get_status())
	act.on_post_exit.connect(func(a): status_in_post_exit[0] = a.get_status())
	act.on_perform_end.connect(func(a): status_in_perform_end[0] = a.get_status())
	act.on_pre_cleanup.connect(func(a): status_in_pre_cleanup[0] = a.get_status())
	act.on_post_cleanup.connect(func(a): status_in_post_cleanup[0] = a.get_status())
	act.prologue = func(a) -> Array[Act]: return [prologue_act]
	act.init("Misc Status Act", theater)

	status_before_perform = act.get_status()
	act.perform()

	await wait_physics_frames(1)
	await wait_physics_frames(1)
	await wait_process_frames(1)

	act.force_finish()

	status_after_perform = act.get_status()


	# Assertions
	assert_true(status_in_pre_setup[0] == Act.Status.NONE, "Status wrong in on_pre_setup! Status='%s'" % [Act.Status.keys()[status_in_pre_setup[0]]])
	assert_true(status_in_post_setup[0] == Act.Status.NONE, "Status wrong in on_post_setup! Status='%s'" % [Act.Status.keys()[status_in_post_setup[0]]])
	assert_true(status_before_perform == Act.Status.NONE, "Status should be NONE before perform() is called. Status='%s'" % [Act.Status.keys()[status_before_perform]])
	assert_true(status_in_perform_start[0] == Act.Status.PROLOGUING, "Status wrong in on_perform_start! Status='%s'" % [Act.Status.keys()[status_in_perform_start[0]]])
	assert_true(status_in_pre_prologue[0] == Act.Status.PROLOGUING, "Status wrong in on_pre_prologue! Status='%s'" % [Act.Status.keys()[status_in_pre_prologue[0]]])
	assert_true(status_in_prologue_complete[0] == Act.Status.PROLOGUING, "Status wrong in on_prologue_complete! Status='%s'" % [Act.Status.keys()[status_in_prologue_complete[0]]])
	assert_true(status_in_post_prologue[0] == Act.Status.PROLOGUING, "Status wrong in on_post_prologue! Status='%s'" % [Act.Status.keys()[status_in_post_prologue[0]]])
	assert_true(status_in_pre_enter[0] == Act.Status.ENTERING, "Status wrong in on_pre_enter! Status='%s'" % [Act.Status.keys()[status_in_pre_enter[0]]])
	assert_true(status_in_post_enter[0] == Act.Status.ENTERING, "Status wrong in on_post_enter! Status='%s'" % [Act.Status.keys()[status_in_post_enter[0]]])
	assert_true(status_in_pre_tick[0] == Act.Status.TICKING, "Status wrong in on_pre_tick! Status='%s'" % [Act.Status.keys()[status_in_pre_tick[0]]])
	assert_true(status_in_post_tick[0] == Act.Status.TICKING, "Status wrong in on_post_tick! Status='%s'" % [Act.Status.keys()[status_in_post_tick[0]]])
	assert_true(status_in_pre_physics_tick[0] == Act.Status.TICKING, "Status wrong in on_pre_physics_tick! Status='%s'" % [Act.Status.keys()[status_in_pre_physics_tick[0]]])
	assert_true(status_in_post_physics_tick[0] == Act.Status.TICKING, "Status wrong in on_post_physics_tick! Status='%s'" % [Act.Status.keys()[status_in_post_physics_tick[0]]])
	assert_true(status_in_pre_exit[0] == Act.Status.EXITING, "Status wrong in on_pre_exit! Status='%s'" % [Act.Status.keys()[status_in_pre_exit[0]]])
	assert_true(status_in_post_exit[0] == Act.Status.EXITING, "Status wrong in on_post_exit! Status='%s'" % [Act.Status.keys()[status_in_post_exit[0]]])
	assert_true(status_after_perform == Act.Status.NONE, "Status should be NONE after perform() has ended. Status='%s'" % [Act.Status.keys()[status_after_perform]])
	assert_true(status_in_pre_cleanup[0] == Act.Status.NONE, "Status wrong in on_pre_cleanup! Status='%s'" % [Act.Status.keys()[status_in_pre_cleanup[0]]])
	assert_true(status_in_post_cleanup[0] == Act.Status.NONE, "Status wrong in on_post_cleanup! Status='%s'" % [Act.Status.keys()[status_in_post_cleanup[0]]])

	theater.free()

	await wait_process_frames(1)
func test_get_outcome_accurate_for_all_outcomes():

	# Interrupted outcome
	var act_interrupted: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_interrupted.init("Misc Outcome Act")
	act_interrupted.perform()
	act_interrupted.manual_finish(Act.Outcome.INTERRUPTED)

	assert_true(act_interrupted.get_outcome() == Act.Outcome.INTERRUPTED, "get_outcome() wrong for INTERRUPTED! Outcome='%s'" % [Act.Outcome.keys()[act_interrupted.get_outcome()]])


	# Failure outcome
	var act_failure: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_failure.init("Misc Outcome Act")
	act_failure.perform()
	act_failure.manual_finish(Act.Outcome.FAILURE)

	assert_true(act_failure.get_outcome() == Act.Outcome.FAILURE, "get_outcome() wrong for FAILURE! Outcome='%s'" % [Act.Outcome.keys()[act_failure.get_outcome()]])


	# Success outcome
	var act_success: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_success.init("Misc Outcome Act")
	act_success.perform()
	act_success.manual_finish(Act.Outcome.SUCCESS)

	assert_true(act_success.get_outcome() == Act.Outcome.SUCCESS, "get_outcome() wrong for SUCCESS! Outcome='%s'" % [Act.Outcome.keys()[act_success.get_outcome()]])


	# Retry outcome, captured during exit since retry auto reperforms
	var recived_outcome := [Act.Outcome.PENDING]
	var act_retry: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_retry.on_pre_exit.connect(func(a): recived_outcome[0] = a.get_outcome())
	act_retry.init("Misc Outcome Act")
	act_retry.perform()
	act_retry.manual_finish(Act.Outcome.RETRY)

	assert_true(recived_outcome[0] == Act.Outcome.RETRY, "get_outcome() wrong for RETRY! Outcome='%s'" % [Act.Outcome.keys()[recived_outcome[0]]])


	await wait_process_frames(1)


func test_get_perform_count_accurate():

	# Perform Act
	var act: Act = autofree(Act.new())
	act.init("Misc Perform Count Act")

	act.perform()
	act.perform()
	act.perform()


	# Assertions
	assert_true(act.get_perform_count() == 3, "get_perform_count() inaccurate! Count='%d'" % [act.get_perform_count()])

	await wait_process_frames(1)
func test_get_tick_count_accurate():

	var theater := Theater.new()
	theater.name = "Misc Tick Count Theater"
	add_child(theater)

	var tick_event_count := [0]

	var act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act.override_tick_flags = Act.TickFlags.TICK
	act.on_post_tick.connect(func(a): tick_event_count[0] += 1)
	act.init("Misc Tick Count Act", theater)
	act.perform()

	await wait_physics_frames(1)
	await wait_physics_frames(1)
	await wait_process_frames(1)

	act.manual_finish()

	assert_true(act.get_tick_count() == tick_event_count[0] && tick_event_count[0] > 0, "get_tick_count() inaccurate! Count='%d' Expected='%d'" % [act.get_tick_count(), tick_event_count[0]])

	theater.free()
	await wait_process_frames(1)
func test_get_physics_tick_count_accurate():

	var theater := Theater.new()
	theater.name = "Misc Tick Count Theater"
	add_child(theater)

	var physics_tick_event_count := [0]

	var act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act.override_tick_flags = Act.TickFlags.PHYSICS_TICK
	act.on_post_physics_tick.connect(func(a): physics_tick_event_count[0] += 1)
	act.init("Misc Tick Count Act", theater)
	act.perform()

	await wait_physics_frames(1)
	await wait_physics_frames(1)
	await wait_process_frames(1)

	act.manual_finish()

	assert_true(act.get_physics_tick_count() == physics_tick_event_count[0] && physics_tick_event_count[0] > 0, "get_physics_tick_count() inaccurate! Count='%d' Expected='%d'" % [act.get_physics_tick_count(), physics_tick_event_count[0]])

	theater.free()
	await wait_process_frames(1)


func test_get_name_accurate():

	# Perform Act
	var act_name := "Misc Name Act"
	var act: Act = autofree(Act.new())
	act.init(act_name)


	# Assertions
	assert_true(act.get_name() == act_name, "get_name() inaccurate! Name='%s'  Expected name='%s'" % [act.get_name(), act_name])

	await wait_process_frames(1)
