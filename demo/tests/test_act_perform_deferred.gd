extends GutTest


# 1. Does perform deferred work?
# 1. Does perform deferred fail without theater?
# 1. Does perform deferred not immediately perform the act?
# 1. Does act perform once when deferred twice?
# 1. Does perform deferred combined tick flags fire once only for whichever comes first?
# 1. Does perform deferred with tick flag as none do nothing?
# 1. Is perform deferred cleared upon performing immediately?
# 1. Is perform deferred cleared on aborting?

# 1. Does perform deferred succeed from on_pre_setup?
# 1. Does perform deferred succeed from on_post_setup?
# 1. Does reperform deferred succeed from on_perform_start?
# 1. Does reperform deferred succeed from on_pre_prologue?
# 1. Does reperform deferred succeed from on_prologue_complete?
# 1. Does reperform deferred succeed from on_post_prologue?
# 1. Does reperform deferred succeed from on_pre_enter?
# 1. Does reperform deferred succeed from on_post_enter?
# 1. Does reperform deferred succeed from on_pre_tick?
# 1. Does reperform deferred succeed from on_post_tick?
# 1. Does reperform deferred succeed from on_pre_physics_tick?
# 1. Does reperform deferred succeed from on_post_physics_tick?
# 1. Does reperform deferred succeed from on_pre_exit?
# 1. Does reperform deferred succeed from on_post_exit?
# 1. Does perform deferred succeed from on_perform_end?
# 1. Does reperform deferred fail from on_pre_cleanup?
# 1. Does reperform deferred fail from on_post_cleanup?
# 1. Does perform deferred succeed from on_enable_changed?
# 1. Does perform deferred succeed from on_block_changed?


func test_perform_deferred_works():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Physics Tick Deferr Perform Act
	var physics_act: Act = autofree(Act.new())
	physics_act.init("Test Physics Act", theater)
	physics_act.perform_deferred(Act.TickFlags.PHYSICS_TICK)
	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Tick Deferr Perform Act
	var tick_act: Act = autofree(Act.new())
	tick_act.init("Test Tick Act", theater)
	tick_act.perform_deferred(Act.TickFlags.TICK)
	await wait_process_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(physics_act.get_perform_count() == 1, "Deferred act did not perform after physics tick!")
	assert_true(tick_act.get_perform_count() == 1, "Deferred act did not perform after tick!")


	theater.free()
func test_perform_defer_without_theater():

	# Perform Act
	var act: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act.init("Test Act")
	act.perform_deferred()

	await wait_process_frames(1)
	await wait_process_frames(1)
	await wait_physics_frames(1)
	await wait_physics_frames(1)


	# Assertions
	assert_true(!act.is_ongoing(), "Act is ongoing despite deferred performing without theater!")
	assert_true(act.get_perform_count() == 0, "Act performed despite missing theater! Perform Count='%d'" % [act.get_perform_count()])

	await wait_process_frames(1)
func test_perform_deferred_does_not_immediately_perform():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Perform Act
	var act: Act = autofree(Act.new())
	act.init("Test Act", theater)
	act.perform_deferred(Act.TickFlags.PHYSICS_TICK)


	# Assertions
	assert_true(act.get_perform_count() == 0, "Act performed immediately despite being deferred!")


	theater.free()
	await wait_process_frames(1)
func test_performs_once_when_deferred_twice():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Tick Deferred Perform
	var tick_deferred_count := 0
	var act_tick: Utilities.ReperformableInfiAct = autofree(Utilities.ReperformableInfiAct.new())
	act_tick.init("Test Act", theater)
	act_tick.perform_deferred(Act.TickFlags.TICK)
	act_tick.perform_deferred(Act.TickFlags.TICK)
	await wait_process_frames(1)
	await wait_process_frames(1)

	tick_deferred_count = act_tick.get_perform_count()


	# Physics Deferred Perform
	var physics_tick_deferred_count := 0
	var act_physics: Utilities.ReperformableInfiAct = autofree(Utilities.ReperformableInfiAct.new())
	act_physics.init("Test Act", theater)
	act_physics.perform_deferred(Act.TickFlags.PHYSICS_TICK)
	act_physics.perform_deferred(Act.TickFlags.PHYSICS_TICK)
	await wait_physics_frames(1)
	await wait_process_frames(1)

	physics_tick_deferred_count = act_physics.get_perform_count()


	# Assertions
	assert_true(tick_deferred_count == 1, "Act did not perform once despite being deferred twice! Count=%d" % [tick_deferred_count])
	assert_true(physics_tick_deferred_count == 1, "Act did not perform once despite being deferred twice! Count=%d" % [physics_tick_deferred_count])


	theater.free()
func test_perform_deferred_combined_flags_fire_on_first_and_clear_other():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Tick and PhysicsTick combo
	var act: Act = autofree(Act.new())
	act.init("Test Act", theater)
	act.perform_deferred((Act.TickFlags.TICK | Act.TickFlags.PHYSICS_TICK) as Act.TickFlags)

	await wait_physics_frames(1)

	var perform_count_after_physics_tick := act.get_perform_count()

	await wait_process_frames(1)

	var perform_count_after_tick := act.get_perform_count()


	# Assertions
	assert_true(perform_count_after_physics_tick == 1, "Tick|PhysicsTick: Act did not perform on first tick type to fire! Perform Count=%d" % [perform_count_after_physics_tick])
	assert_true(perform_count_after_tick == 1, "Tick|PhysicsTick: Act performed again on second tick type despite being cleared! Perform Count=%d" % [perform_count_after_tick])


	theater.free()
func test_perform_deferred_with_none_flag_does_nothing():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Perform Act
	var act: Act = autofree(Act.new())
	act.init("Test Act", theater)
	act.perform_deferred(Act.TickFlags.NONE)
	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 0, "Act performed despite tick flag being none!")


	theater.free()
func test_perform_deferred_cleared_upon_performing_immediately():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Perform Act
	var act: Act = autofree(Act.new())
	act.init("Test Act", theater)
	act.perform_deferred(Act.TickFlags.PHYSICS_TICK)
	act.perform()
	var perform_count_after_immediate := act.get_perform_count()
	await wait_physics_frames(1)
	await wait_process_frames(1)
	var perform_count_after_tick := act.get_perform_count()


	# Assertions
	assert_true(perform_count_after_immediate == 1, "Act did not perform immediately!")
	assert_true(perform_count_after_tick == 1, "Deferred perform was not cleared after performing immediately!")


	theater.free()
func test_perform_deferred_cleared_on_abort():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Perform Act
	var act: Act = autofree(Act.new())
	act.init("Test Act", theater)
	act.perform_deferred()
	act.abort()
	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 0, "Act deferred performed despite being aborted!")


	theater.free()



func test_perform_deferred_from_on_pre_setup():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_pre_setup.connect(func(a):
		a.perform_deferred()
	)
	act.init("Test Act", theater)

	await wait_process_frames(1)
	await wait_physics_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 1, "Act did not perform deferred from on_pre_setup! Perform Count=%d" % [act.get_perform_count()])


	theater.free()
	await wait_process_frames(1)
func test_perform_deferred_from_on_post_setup():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_post_setup.connect(func(a):
		a.perform_deferred()
	)
	act.init("Test Act", theater)

	await wait_process_frames(1)
	await wait_physics_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 1, "Act did not perform deferred from on_post_setup! Perform Count=%d" % [act.get_perform_count()])


	theater.free()
	await wait_process_frames(1)
func test_perform_deferred_from_on_perform_start():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_perform_start.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform_deferred()
	)
	act.init("Test Act", theater)
	act.perform()


	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform deferred thrice from on_perform_start! Perform Count=%d" % [act.get_perform_count()])

	theater.free()
func test_perform_deferred_from_on_pre_prologue():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Prologue act so the prologue signal actually fires
	var prologue_act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	prologue_act.init("Prologue Act")


	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.prologue = func(a) -> Array[Act]: return [prologue_act]
	act.on_pre_prologue.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform_deferred()
	)
	act.init("Test Act", theater)
	act.perform()


	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform deferred thrice from on_pre_prologue! Perform Count=%d" % [act.get_perform_count()])


	theater.free()
func test_perform_deferred_from_on_prologue_complete():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Prologue act
	var prologue_1_act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	prologue_1_act.init("Prologue 1 Act")

	var prologue_2_act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	prologue_2_act.init("Prologue 2 Act")


	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.prologue = func(a) -> Array[Act]: return [prologue_1_act, prologue_2_act]
	act.on_prologue_complete.connect(func(a, p_a, p_o):
		if(p_o != Act.Outcome.SUCCESS):
			return

		if(act.get_perform_count() <= 2):
			act.perform_deferred()
	)
	act.init("Test Act", theater)
	act.perform()


	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform deferred thrice from on_prologue_complete! Perform Count=%d" % [act.get_perform_count()])


	theater.free()
func test_perform_deferred_from_on_post_prologue():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Prologue act so the prologue signal actually fires
	var prologue_act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	prologue_act.init("Prologue Act")


	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.prologue = func(a) -> Array[Act]: return [prologue_act]
	act.on_post_prologue.connect(func(a):
		if(act.get_perform_count() <= 2):
			act.perform_deferred()
	)
	act.init("Test Act", theater)
	act.perform()


	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform deferred thrice from on_post_prologue! Perform Count=%d" % [act.get_perform_count()])


	theater.free()
func test_perform_deferred_from_on_pre_enter():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.on_pre_enter.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform_deferred()
	)
	act.init("Test Act", theater)
	act.perform()


	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform deferred thrice from on_pre_enter! Perform Count=%d" % [act.get_perform_count()])


	theater.free()
func test_perform_deferred_from_on_post_enter():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.on_post_enter.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform_deferred()
	)
	act.init("Test Act", theater)
	act.perform()


	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform deferred thrice from on_post_enter! Perform Count=%d" % [act.get_perform_count()])


	theater.free()
func test_perform_deferred_from_on_pre_tick():

	# Real theater needed to drive ticks
	var theater := Theater.new()
	theater.name = "TestTheater"
	add_child(theater)


	# Perform Act
	var act: Utilities.ReperformableInfiAct = autofree(Utilities.ReperformableInfiAct.new())
	act.override_tick_flag = Act.TickFlags.TICK
	act.on_pre_tick.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform_deferred(Act.TickFlags.TICK)
	)
	act.init("Test Act", theater)
	act.perform()


	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform deferred thrice from on_pre_tick! Perform Count=%d" % [act.get_perform_count()])


	# Cleanup
	theater.free()
func test_perform_deferred_from_on_post_tick():

	# Real theater needed to drive ticks
	var theater := Theater.new()
	theater.name = "TestTheater"
	add_child(theater)


	# Perform Act
	var act: Utilities.ReperformableInfiAct = autofree(Utilities.ReperformableInfiAct.new())
	act.override_tick_flag = Act.TickFlags.TICK
	act.on_post_tick.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform_deferred(Act.TickFlags.TICK)
	)
	act.init("Test Act", theater)
	act.perform()


	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform deferred thrice from on_post_tick! Perform Count=%d" % [act.get_perform_count()])


	# Cleanup
	theater.free()
func test_perform_deferred_from_on_pre_physics_tick():

	# Real theater needed to drive ticks
	var theater := Theater.new()
	theater.name = "TestTheater"
	add_child(theater)


	# Perform Act
	var act: Utilities.ReperformableInfiAct = autofree(Utilities.ReperformableInfiAct.new())
	act.override_tick_flag = Act.TickFlags.PHYSICS_TICK
	act.on_pre_physics_tick.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform_deferred(Act.TickFlags.PHYSICS_TICK)
	)
	act.init("Test Act", theater)
	act.perform()


	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform deferred thrice from on_pre_physics_tick! Perform Count=%d" % [act.get_perform_count()])


	# Cleanup
	theater.free()
func test_perform_deferred_from_on_post_physics_tick():

	# Real theater needed to drive ticks
	var theater := Theater.new()
	theater.name = "TestTheater"
	add_child(theater)


	# Perform Act
	var act: Utilities.ReperformableInfiAct = autofree(Utilities.ReperformableInfiAct.new())
	act.override_tick_flag = Act.TickFlags.PHYSICS_TICK
	act.on_post_physics_tick.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform_deferred(Act.TickFlags.PHYSICS_TICK)
	)
	act.init("Test Act", theater)
	act.perform()


	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform deferred thrice from on_post_physics_tick! Perform Count=%d" % [act.get_perform_count()])


	# Cleanup
	theater.free()
func test_perform_deferred_from_on_pre_exit():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.on_pre_exit.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform_deferred()
	)
	act.init("Test Act", theater)
	act.perform()


	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform deferred thrice from on_pre_exit! Perform Count=%d" % [act.get_perform_count()])


	theater.free()
func test_perform_deferred_from_on_post_exit():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.on_post_exit.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform_deferred()
	)
	act.init("Test Act", theater)
	act.perform()


	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform deferred thrice from on_post_exit! Perform Count=%d" % [act.get_perform_count()])


	theater.free()
func test_perform_deferred_from_on_perform_end():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.on_perform_end.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform_deferred()
	)
	act.init("Test Act", theater)
	act.perform()


	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform deferred thrice from on_perform_end! Perform Count=%d" % [act.get_perform_count()])

	theater.free()
func test_perform_deferred_from_on_pre_cleanup():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.on_pre_cleanup.connect(func(a):
		a.perform_deferred()
	)
	act.init("Test Act", theater)
	act.deinit()

	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 0, "Act performed from on_pre_cleanup! Perform Count=%d" % [act.get_perform_count()])

	theater.free()
func test_perform_deferred_from_on_post_cleanup():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.on_post_cleanup.connect(func(a):
		a.perform_deferred()
	)
	act.init("Test Act", theater)
	act.deinit()


	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 0, "Act performed from on_post_cleanup! Perform Count=%d" % [act.get_perform_count()])

	theater.free()
func test_perform_deferred_from_on_enable_changed():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_enable_changed.connect(func(a, new_enabled):
		if(act.get_perform_count() <= 2):
			a.perform_deferred()
	)
	act.init("Test Act", theater)


	# Toggle with a wait between each, so all deferred performs should happen before next toggle
	act.set_enabled(false)
	await wait_physics_frames(1)
	await wait_process_frames(1)
	act.set_enabled(true)
	await wait_physics_frames(1)
	await wait_process_frames(1)
	act.set_enabled(false)
	await wait_physics_frames(1)
	await wait_process_frames(1)
	act.set_enabled(true)
	await wait_physics_frames(1)
	await wait_process_frames(1)
	act.set_enabled(false)
	await wait_physics_frames(1)
	await wait_process_frames(1)
	act.set_enabled(true)
	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform deferred thrice from on_enable_changed! Perform Count=%d" % [act.get_perform_count()])


	theater.free()
func test_perform_deferred_from_on_block_changed():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_block_changed.connect(func(a, by_act, block_type, did_block):
		if(act.get_perform_count() <= 2):
			a.perform_deferred()
	)
	act.init("Test Act", theater)


	var blocker: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	blocker.init("Blocker Act")
	blocker.add_to_block([act])


	# Toggle with a wait between each, so all deferred performs should happen before next toggle
	blocker.perform()
	await wait_physics_frames(1)
	await wait_process_frames(1)
	blocker.abort()
	await wait_physics_frames(1)
	await wait_process_frames(1)
	blocker.perform()
	await wait_physics_frames(1)
	await wait_process_frames(1)
	blocker.abort()
	await wait_physics_frames(1)
	await wait_process_frames(1)
	blocker.perform()
	await wait_physics_frames(1)
	await wait_process_frames(1)
	blocker.abort()
	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform deferred thrice from on_block_changed! Perform Count=%d" % [act.get_perform_count()])


	theater.free()
