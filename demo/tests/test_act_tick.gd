extends GutTest


# 1. Are all pre tick and post tick signals being broadcasted with correct arguments?
# 1. Are all _tick() methods being invoked?
# 1. Is ticking not being invoked when tick flag is set to none?
# 1. Does ticking fail if no theater is assigned?
# 1. Does get_delta() and get_physics_delta() return accurate values?


func test_on_pre_and_post_tick():

	# Tick
	var was_pre_tick_invoked := [false]
	var pre_tick_arg_1 := [null]
	var was_post_tick_invoked := [false]
	var post_tick_arg_1 := [null]

	var theater_tick: Theater = Theater.new()
	theater_tick.name = "Test Theater"
	add_child_autofree(theater_tick)
	var act_tick: Utilities.TickAct = autofree(Utilities.TickAct.new())
	act_tick.on_pre_tick.connect(func(a): was_pre_tick_invoked[0] = true; pre_tick_arg_1[0] = a)
	act_tick.on_post_tick.connect(func(a): was_post_tick_invoked[0] = true; post_tick_arg_1[0] = a)
	act_tick.init("Test Act", theater_tick)
	act_tick.perform()

	await wait_process_frames(1)

	# Assertions
	assert_true(was_pre_tick_invoked[0], "on_pre_tick not invoked!")
	assert_true(pre_tick_arg_1[0] == act_tick, "on_pre_tick first argument is invalid! Arg1='%s'" % [pre_tick_arg_1[0]])
	assert_true(was_post_tick_invoked[0], "on_post_tick not invoked!")
	assert_true(post_tick_arg_1[0] == act_tick, "on_post_tick first argument is invalid! Arg1='%s'" % [post_tick_arg_1[0]])


	# PhysicsTick
	var was_pre_physics_tick_invoked := [false]
	var pre_physics_tick_arg_1 := [null]
	var was_post_physics_tick_invoked := [false]
	var post_physics_tick_arg_1 := [null]

	var theater_physics: Theater = Theater.new()
	theater_physics.name = "Test Theater"
	add_child_autofree(theater_physics)
	var act_physics: Utilities.PhysicsTickAct = autofree(Utilities.PhysicsTickAct.new())
	act_physics.on_pre_physics_tick.connect(func(a): was_pre_physics_tick_invoked[0] = true; pre_physics_tick_arg_1[0] = a)
	act_physics.on_post_physics_tick.connect(func(a): was_post_physics_tick_invoked[0] = true; post_physics_tick_arg_1[0] = a)
	act_physics.init("Test Act", theater_physics)
	act_physics.perform()

	await wait_physics_frames(1)

	# Assertions
	assert_true(was_pre_physics_tick_invoked[0], "on_pre_physics_tick not invoked!")
	assert_true(pre_physics_tick_arg_1[0] == act_physics, "on_pre_physics_tick first argument is invalid! Arg1='%s'" % [pre_physics_tick_arg_1[0]])
	assert_true(was_post_physics_tick_invoked[0], "on_post_physics_tick not invoked!")
	assert_true(post_physics_tick_arg_1[0] == act_physics, "on_post_physics_tick first argument is invalid! Arg1='%s'" % [post_physics_tick_arg_1[0]])
func test_tick():

	# Tick
	var theater_tick: Theater = Theater.new()
	theater_tick.name = "Test Theater"
	add_child_autofree(theater_tick)
	var act_tick: Utilities.TickAct = autofree(Utilities.TickAct.new())
	act_tick.init("Test Act", theater_tick)
	act_tick.perform()

	await wait_process_frames(1)

	# Assertions
	assert_true(1 <= act_tick.call_count, "_tick() not invoked! Call count='%d'" % [act_tick.call_count])


	# PhysicsTick
	var theater_physics: Theater = Theater.new()
	theater_physics.name = "Test Theater"
	add_child_autofree(theater_physics)
	var act_physics: Utilities.PhysicsTickAct = autofree(Utilities.PhysicsTickAct.new())
	act_physics.init("Test Act", theater_physics)
	act_physics.perform()

	await wait_physics_frames(1)

	# Assertions
	assert_true(1 <= act_physics.call_count, "_physics_tick() not invoked! Call count='%d'" % [act_physics.call_count])
func test_tick_with_flag_none():

	# Prerequisites
	var was_pre_tick_invoked := [false]
	var was_pre_physics_tick_invoked := [false]

	# Perform Act
	var theater: Theater = Theater.new()
	theater.name = "Test Theater"
	add_child_autofree(theater)
	var act: Utilities.NoneTickAct = autofree(Utilities.NoneTickAct.new())
	act.on_pre_tick.connect(func(a): was_pre_tick_invoked[0] = true)
	act.on_pre_physics_tick.connect(func(a): was_pre_physics_tick_invoked[0] = true)
	act.init("Test Act", theater)
	act.perform()

	await wait_physics_frames(1)
	await wait_process_frames(1)

	# Assertions
	assert_true(act.get_status() == Act.Status.NONE, "Act status is not 'NONE' despite TickFlags.NONE! Status='%s'" % [Act.Status.keys()[act.get_status()]])
	assert_false(was_pre_tick_invoked[0], "on_pre_tick invoked despite TickFlags.NONE!")
	assert_false(was_pre_physics_tick_invoked[0], "on_pre_physics_tick invoked despite TickFlags.NONE!")
func test_tick_without_theater():

	# Tick type
	var act_tick: Utilities.TickAct = autofree(Utilities.TickAct.new())
	act_tick.init("Test Act")
	act_tick.perform()

	var act_status_tick := act_tick.get_status()

	# Assertions
	assert_true(act_status_tick == Act.Status.ENTERING, "Act did not stay 'ENTERING' when ticking without theater! Status='%s'" % [Act.Status.keys()[act_status_tick]])
	assert_true(act_tick.call_count == 0, "_tick() invoked despite missing theater! Call count='%d'" % [act_tick.call_count])


	# PhysicsTick type
	var act_physics: Utilities.PhysicsTickAct = autofree(Utilities.PhysicsTickAct.new())
	act_physics.init("Test Act")
	act_physics.perform()

	var act_status_physics := act_physics.get_status()

	# Assertions
	assert_true(act_status_physics == Act.Status.ENTERING, "Act did not stay 'ENTERING' when physics ticking without theater! Status='%s'" % [Act.Status.keys()[act_status_physics]])
	assert_true(act_physics.call_count == 0, "_physics_tick() invoked despite missing theater! Call count='%d'" % [act_physics.call_count])


	await wait_process_frames(1)
func test_get_delta_and_physics_delta():

	# Prerequisites
	var theater: Theater = Theater.new()
	add_child_autofree(theater)
	var act: Act = autofree(Act.new())
	act.init("Test Act", theater)

	await wait_process_frames(1)

	# Assertions
	assert_true(act.get_delta() == get_process_delta_time(), "get_delta() does not match get_process_delta_time()! get_delta=%s  get_process_delta_time=%s" % [act.get_delta(), get_process_delta_time()])
	assert_true(act.get_physics_delta() == get_physics_process_delta_time(), "get_physics_delta() does not match get_physics_process_delta_time()! get_physics_delta=%s  get_physics_process_delta_time=%s" % [act.get_physics_delta(), get_physics_process_delta_time()])
