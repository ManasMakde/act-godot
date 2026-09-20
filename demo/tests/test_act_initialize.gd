extends GutTest


# 1. Are pre setup and post setup signals being broadcasted with correct arguments?
# 1. Is _setup() being invoked?
# 1. Does calling init() twice fail?
# 1. Is theater assigned after initialization?
# 1. Is name assigned after initialization?
# 1. Is initially enabled or disabled working?


func test_on_pre_and_post_setup():

	# Prerequisites
	var was_pre_setup_invoked := [false]
	var pre_setup_arg_1 := [null]
	var was_post_setup_invoked := [false]
	var post_setup_arg_1 := [null]


	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_pre_setup.connect(func(a): was_pre_setup_invoked[0] = true; pre_setup_arg_1[0] = a)
	act.on_post_setup.connect(func(a): was_post_setup_invoked[0] = true; post_setup_arg_1[0] = a)
	act.init("Test Act")


	# Assertions
	assert_true(was_pre_setup_invoked[0], "on_pre_setup not invoked!")
	assert_true(pre_setup_arg_1[0] == act, "on_pre_setup first argument is invalid! Arg1=`%s`" % [pre_setup_arg_1[0]])
	assert_true(was_post_setup_invoked[0], "on_post_setup not invoked!")
	assert_true(post_setup_arg_1[0] == act, "on_post_setup first argument is invalid! Arg1=`%s`" % [pre_setup_arg_1[0]])


	await wait_process_frames(1)
func test_setup():

	# Perform Act
	var act: Utilities.SetupAct = autofree(Utilities.SetupAct.new())
	act.init("Test Act")


	# Assertions
	assert_true(act.call_count == 1, "_setup() not invoked exactly once! Call count=%d" % [act.call_count])


	await wait_process_frames(1)
func test_init_called_twice():

	# Prerequisites
	var pre_setup_count := [0]
	var post_setup_count := [0]

	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_pre_setup.connect(func(a): pre_setup_count[0] += 1)
	act.on_post_setup.connect(func(a): post_setup_count[0] += 1)
	act.init("Test Act")
	act.init("Test Act")


	# Assertions
	assert_true(pre_setup_count[0] == 1, "on_pre_setup invoked more than once despite calling init() twice! Count=%d" % [pre_setup_count[0]])
	assert_true(post_setup_count[0] == 1, "on_post_setup invoked more than once despite calling init() twice! Count=%d" % [post_setup_count[0]])

	await wait_process_frames(1)
func test_theater_after_init():

	# Check if theater is invalid if not assigned in init
	var act_1: Act = autofree(Act.new())
	act_1.init("Test Act")
	var theater_1 := act_1.get_theater()


	# Check if theater is valid if assigned in init
	var valid_theater := Theater.new()
	add_child(valid_theater)
	var act_2: Act = autofree(Act.new())
	act_2.init("Test Act 2", valid_theater)
	var theater_2 := act_2.get_theater()


	# Assertions
	assert_true(theater_1 == null, "Theater is not null despite not being passed to init()! Theater='%s'" % [theater_1])
	assert_true(theater_2 == valid_theater, "Theater is null despite being passed to init()! Theater='%s'" % [theater_2])


	valid_theater.queue_free()
	await wait_process_frames(1)
func test_name_after_init():

	# Perform Act
	var act_name := "My Named Act"
	var act: Act = autofree(Act.new())
	act.init(act_name)


	# Assertions
	assert_true(act.get_name() == act_name, "Name is invalid after init()! Name='%s' Original Name='%s'" % [act.get_name(), act_name])


	await wait_process_frames(1)
func test_initially_enabled_or_disabled():

	# Perform Act
	var enabled_act: Act = autofree(Act.new())
	enabled_act.init("Enabled Act", null, true)

	var disabled_act: Act = autofree(Act.new())
	disabled_act.init("Disabled Act", null, false)


	# Assertions
	assert_true(enabled_act.is_enabled(), "Act is not enabled despite is_initially_enabled being true!")
	assert_true(!disabled_act.is_enabled(), "Act is enabled despite is_initially_enabled being false!")
	assert_true(!disabled_act.is_blocked(), "Initially disabled act is blocked!")


	await wait_process_frames(1)
