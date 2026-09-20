extends GutTest


# 1. Does an ongoing act stop when abort() is invoked?
# 1. Does abort fail from on_pre_setup?
# 1. Does abort fail from on_post_setup?
# 1. Does abort succeed from on_perform_start?
# 1. Does abort succeed from on_pre_prologue?
# 1. Does abort succeed from on_prologue_complete?
# 1. Does abort succeed from on_post_prologue?
# 1. Does abort succeed from on_pre_enter?
# 1. Does abort succeed from on_post_enter?
# 1. Does abort succeed from on_pre_tick?
# 1. Does abort succeed from on_post_tick?
# 1. Does abort succeed from on_pre_physics_tick?
# 1. Does abort succeed from on_post_physics_tick?
# 1. Does abort fail from on_pre_exit?
# 1. Does abort fail from on_post_exit?
# 1. Does abort succeed from on_perform_end?
# 1. Does abort fail from on_pre_cleanup?
# 1. Does abort fail from on_post_cleanup?
# 1. Does abort succeed from on_enable_changed?
# 1. Does abort succeed from on_block_changed?


func test_abort_stops_ongoing_act():

	# Perform Act
	var act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act.init("Test Act")
	act.perform()

	var was_ongoing := act.is_ongoing()

	act.abort()


	# Assertions
	assert_true(was_ongoing, "Act was not ongoing before abort()!")
	assert_true(!act.is_ongoing() && act.get_outcome() == Act.Outcome.INTERRUPTED, "Act did not stop on abort()! is_ongoing=%s  outcome=%s" % [act.is_ongoing(), Act.Outcome.keys()[act.get_outcome()]])

	await wait_process_frames(1)
func test_abort_fails_from_on_pre_setup():

	# Perform Act
	var act: Utilities.ExitAct = autofree(Utilities.ExitAct.new())
	act.on_pre_setup.connect(func(a): act.abort())
	act.init("Test Act")


	# Assertions
	assert_true(act.call_count == 0 && !act.is_ongoing(), "Abort from on_pre_setup calling _exit()! call_count=%d  outcome=%s" % [act.call_count, Act.Outcome.keys()[act.get_outcome()]])

	await wait_process_frames(1)
func test_abort_fails_from_on_post_setup():

	# Perform Act
	var act: Utilities.ExitAct = autofree(Utilities.ExitAct.new())
	act.on_post_setup.connect(func(a): act.abort())
	act.init("Test Act")


	# Assertions
	assert_true(act.call_count == 0 && !act.is_ongoing(), "Abort from on_post_setup calling _exit()! call_count=%d  outcome=%s" % [act.call_count, Act.Outcome.keys()[act.get_outcome()]])

	await wait_process_frames(1)
func test_abort_succeeds_from_on_perform_start():

	# Perform Act
	var act: Utilities.EnterAct = autofree(Utilities.EnterAct.new())
	act.on_perform_start.connect(func(a): act.abort())
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(act.call_count == 0 && act.get_outcome() == Act.Outcome.INTERRUPTED, "Abort from on_perform_start did not cut perform short! call_count=%d  outcome=%s" % [act.call_count, Act.Outcome.keys()[act.get_outcome()]])

	await wait_process_frames(1)
func test_abort_succeeds_from_on_pre_prologue():

	# Perform Act
	var prologue_act: Act = autofree(Act.new())
	prologue_act.init("Prologue Act")

	var main_act: Utilities.EnterAct = autofree(Utilities.EnterAct.new())
	main_act.on_pre_prologue.connect(func(a): main_act.abort())
	main_act.prologue = func(a) -> Array[Act]: return [prologue_act]
	main_act.init("Main Act")

	main_act.perform()


	# Assertions
	assert_true(prologue_act.get_perform_count() == 0 && main_act.call_count == 0 && main_act.get_outcome() == Act.Outcome.INTERRUPTED, "Abort from on_pre_prologue did not cut prologue short! prologue_count=%d  call_count=%d  outcome=%s" % [prologue_act.get_perform_count(), main_act.call_count, Act.Outcome.keys()[main_act.get_outcome()]])

	await wait_process_frames(1)
func test_abort_succeeds_from_on_prologue_complete():

	# Perform Act
	var prologue_act: Act = autofree(Act.new())
	prologue_act.init("Prologue Act")

	var main_act: Utilities.EnterAct = autofree(Utilities.EnterAct.new())
	main_act.prologue = func(a) -> Array[Act]: return [prologue_act]
	main_act.on_prologue_complete.connect(func(a, p_act, outcome): main_act.abort())
	main_act.init("Main Act")

	main_act.perform()


	# Assertions
	assert_true(main_act.call_count == 0 && main_act.get_outcome() == Act.Outcome.INTERRUPTED, "Abort from on_prologue_complete did not cut perform short! call_count=%d  outcome=%s" % [main_act.call_count, Act.Outcome.keys()[main_act.get_outcome()]])

	await wait_process_frames(1)
func test_abort_succeeds_from_on_post_prologue():

	# Perform Act
	var prologue_act: Act = autofree(Act.new())
	prologue_act.init("Prologue Act")

	var main_act: Utilities.EnterAct = autofree(Utilities.EnterAct.new())
	main_act.prologue = func(a) -> Array[Act]: return [prologue_act]
	main_act.on_post_prologue.connect(func(a): main_act.abort())
	main_act.init("Main Act")

	main_act.perform()


	# Assertions
	assert_true(main_act.call_count == 0 && main_act.get_outcome() == Act.Outcome.INTERRUPTED, "Abort from on_post_prologue did not cut perform short! call_count=%d  outcome=%s" % [main_act.call_count, Act.Outcome.keys()[main_act.get_outcome()]])

	await wait_process_frames(1)
func test_abort_succeeds_from_on_pre_enter():

	# Perform Act
	var act: Utilities.EnterAct = autofree(Utilities.EnterAct.new())
	act.on_pre_enter.connect(func(a): act.abort())
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(act.call_count == 0 && act.get_outcome() == Act.Outcome.INTERRUPTED, "Abort from on_pre_enter did not cut _enter() short! call_count=%d  outcome=%s" % [act.call_count, Act.Outcome.keys()[act.get_outcome()]])

	await wait_process_frames(1)
func test_abort_succeeds_from_on_post_enter():

	# Perform Act
	var act: Utilities.EnterAct = autofree(Utilities.EnterAct.new())
	act.on_post_enter.connect(func(a): act.abort())
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(act.call_count == 1 && act.get_outcome() == Act.Outcome.INTERRUPTED, "Abort from on_post_enter did not override natural outcome! call_count=%d  outcome=%s" % [act.call_count, Act.Outcome.keys()[act.get_outcome()]])

	await wait_process_frames(1)
func test_abort_succeeds_from_on_pre_tick():

	# Perform Act
	var theater: Theater = add_child_autofree(Theater.new())
	var act: Utilities.TickAct = autofree(Utilities.TickAct.new())
	act.on_pre_tick.connect(func(a): act.abort())
	act.init("Test Act", theater)

	act.perform()

	await wait_process_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.call_count == 0 && act.get_outcome() == Act.Outcome.INTERRUPTED, "Abort from on_pre_tick did not cut _tick() short! call_count=%d  outcome=%s" % [act.call_count, Act.Outcome.keys()[act.get_outcome()]])

	await wait_process_frames(1)
func test_abort_succeeds_from_on_post_tick():

	# Perform Act
	var theater: Theater = add_child_autofree(Theater.new())
	var act: Utilities.TickAct = autofree(Utilities.TickAct.new())
	act.on_post_tick.connect(func(a): act.abort())
	act.init("Test Act", theater)
	act.perform()

	await wait_process_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.call_count == 1 && act.get_outcome() == Act.Outcome.INTERRUPTED, "Abort from on_post_tick did not override natural outcome! call_count=%d  outcome=%s" % [act.call_count, Act.Outcome.keys()[act.get_outcome()]])

	await wait_process_frames(1)
func test_abort_succeeds_from_on_pre_physics_tick():

	# Perform Act
	var theater: Theater = add_child_autofree(Theater.new())
	var act: Utilities.PhysicsTickAct = autofree(Utilities.PhysicsTickAct.new())
	act.on_pre_physics_tick.connect(func(a): act.abort())
	act.init("Test Act", theater)
	act.perform()

	await wait_physics_frames(1)
	await wait_physics_frames(1)


	# Assertions
	assert_true(act.call_count == 0 && act.get_outcome() == Act.Outcome.INTERRUPTED, "Abort from on_pre_physics_tick did not cut _physics_tick() short! call_count=%d  outcome=%s" % [act.call_count, Act.Outcome.keys()[act.get_outcome()]])

	await wait_process_frames(1)
func test_abort_succeeds_from_on_post_physics_tick():

	# Perform Act
	var theater: Theater = add_child_autofree(Theater.new())
	var act: Utilities.PhysicsTickAct = autofree(Utilities.PhysicsTickAct.new())
	act.on_post_physics_tick.connect(func(a): act.abort())
	act.init("Test Act", theater)
	act.perform()

	await wait_physics_frames(1)
	await wait_physics_frames(1)


	# Assertions
	assert_true(act.call_count == 1 && act.get_outcome() == Act.Outcome.INTERRUPTED, "Abort from on_post_physics_tick did not override natural outcome! call_count=%d  outcome=%s" % [act.call_count, Act.Outcome.keys()[act.get_outcome()]])

	await wait_process_frames(1)
func test_abort_fails_from_on_pre_exit():

	# Perform Act
	var act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act.on_pre_exit.connect(func(a): act.abort())
	act.init("Test Act")
	act.perform()

	act.manual_finish(Act.Outcome.SUCCESS)


	# Assertions
	assert_true(!act.is_ongoing() && act.get_outcome() == Act.Outcome.SUCCESS, "Abort from on_pre_exit wrongly overrode outcome! outcome=%s" % [Act.Outcome.keys()[act.get_outcome()]])

	await wait_process_frames(1)
func test_abort_fails_from_on_post_exit():

	# Perform Act
	var act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act.on_post_exit.connect(func(a): act.abort())
	act.init("Test Act")
	act.perform()

	act.manual_finish(Act.Outcome.SUCCESS)


	# Assertions
	assert_true(!act.is_ongoing() && act.get_outcome() == Act.Outcome.SUCCESS, "Abort from on_post_exit wrongly overrode outcome! outcome=%s" % [Act.Outcome.keys()[act.get_outcome()]])

	await wait_process_frames(1)
func test_abort_succeeds_from_on_perform_end():

	# Perform Act
	var main_act: Act = autofree(Act.new())
	main_act.on_perform_end.connect(func(a): main_act.abort())
	main_act.init("Main Act")

	main_act.perform()


	# Assertions
	assert_true(!main_act.is_ongoing() && main_act.get_outcome() == Act.Outcome.SUCCESS, "Abort from on_perform_end overrode outcome! is_ongoing=%s  outcome=%s" % [main_act.is_ongoing(), Act.Outcome.keys()[main_act.get_outcome()]])

	await wait_process_frames(1)
func test_abort_fails_from_on_pre_cleanup():

	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_pre_cleanup.connect(func(a): act.abort())
	act.init("Test Act")
	act.deinit()


	# Assertions
	assert_true(!act.is_ongoing(), "Abort from on_pre_cleanup wrongly made act ongoing! ongoing=%s" % [act.is_ongoing()])

	await wait_process_frames(1)
func test_abort_fails_from_on_post_cleanup():

	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_post_cleanup.connect(func(a): act.abort())
	act.init("Test Act")
	act.deinit()


	# Assertions
	assert_true(!act.is_ongoing(), "Abort from on_post_cleanup wrongly made act ongoing! ongoing=%s" % [act.is_ongoing()])

	await wait_process_frames(1)
func test_abort_succeeds_from_on_enable_changed():

	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_enable_changed.connect(func(a, e): act.abort())
	act.init("Test Act")

	act.set_enabled(false)
	var is_ongoing_after_disable := act.is_ongoing()
	act.set_enabled(true)
	var is_ongoing_after_enable := act.is_ongoing()


	# Assertions
	assert_true(!is_ongoing_after_disable, "Abort from on_enable_changed false made act ongoing! is_ongoing_after_disable=%s" % [is_ongoing_after_disable])
	assert_true(!is_ongoing_after_enable, "Abort from on_enable_changed true made act ongoing! is_ongoing_after_enable=%s" % [is_ongoing_after_enable])

	await wait_process_frames(1)
func test_abort_succeeds_from_on_block_changed():

	var blocked_act: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	blocked_act.on_block_changed.connect(func(a, by_act, block_type, did_block): blocked_act.abort())
	blocked_act.init("Blocked Act")
	blocked_act.perform()

	var blocker_act: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	blocker_act.add_to_block([blocked_act])
	blocker_act.init("Blocker Act")

	blocker_act.perform()


	# Assertions
	assert_true(!blocked_act.is_ongoing(), "Abort from on_block_changed made act ongoing! is_ongoing=%s" % [blocked_act.is_ongoing()])

	await wait_process_frames(1)
