extends GutTest


# 1. Are pre cleanup and post cleanup signals being broadcasted with correct arguments?
# 1. Is _cleanup() being invoked?
# 1. Does calling deinit() twice fail?
# 1. Is theater set to null after deinitialization?
# 1. Does act abort on deinitialization?
# 1. Does prologue act abort on deinitialization?
# 1. Does get_perform_count() reset to 0 after deinitialization?
# 1. After deinit() is the act removed from the theater's all acts and ongoing acts?


func test_on_pre_and_post_cleanup():

	# Prerequisites
	var was_pre_cleanup_invoked := [false]
	var pre_cleanup_arg_1 := [null]
	var was_post_cleanup_invoked := [false]
	var post_cleanup_arg_1 := [null]


	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_pre_cleanup.connect(func(a): was_pre_cleanup_invoked[0] = true; pre_cleanup_arg_1[0] = a)
	act.on_post_cleanup.connect(func(a): was_post_cleanup_invoked[0] = true; post_cleanup_arg_1[0] = a)
	act.init("Test Act")
	act.deinit()


	# Assertions
	assert_true(was_pre_cleanup_invoked[0], "on_pre_cleanup not invoked!")
	assert_true(pre_cleanup_arg_1[0] == act, "on_pre_cleanup first argument is invalid! Arg1=`%s`" % [pre_cleanup_arg_1[0]])
	assert_true(was_post_cleanup_invoked[0], "on_post_cleanup not invoked!")
	assert_true(post_cleanup_arg_1[0] == act, "on_post_cleanup first argument is invalid! Arg1=`%s`" % [pre_cleanup_arg_1[0]])


	await wait_process_frames(1)
func test_cleanup():

	# Perform Act
	var act: Utilities.CleanupAct = autofree(Utilities.CleanupAct.new())
	act.init("Test Act")
	act.deinit()


	# Assertions
	assert_true(act.call_count == 1, "_cleanup() not invoked exactly once! Call count=%d" % [act.call_count])


	await wait_process_frames(1)
func test_deinit_called_twice_fails():

	# Prerequisites
	var pre_cleanup_count := [0]
	var post_cleanup_count := [0]

	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_pre_cleanup.connect(func(a): pre_cleanup_count[0] += 1)
	act.on_post_cleanup.connect(func(a): post_cleanup_count[0] += 1)
	act.init("Test Act")
	act.deinit()
	act.deinit()


	# Assertions
	assert_true(pre_cleanup_count[0] == 1, "on_pre_cleanup invoked more than once despite calling deinit() twice! Count=%d" % [pre_cleanup_count[0]])
	assert_true(post_cleanup_count[0] == 1, "on_post_cleanup invoked more than once despite calling deinit() twice! Count=%d" % [post_cleanup_count[0]])

	await wait_process_frames(1)
func test_theater_null_after_deinit():

	# Perform Act
	var theater: Theater = add_child_autofree(Theater.new())
	var act: Act = autofree(Act.new())
	act.init("Test Act", theater)
	act.deinit()


	# Assertions
	assert_true(act.get_theater() == null, "Theater is not null after deinit()! Theater='%s'" % [act.get_theater()])


	await wait_process_frames(1)
func test_abort_on_deinit():

	# Perform Act
	var act: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act.init("Test Act")
	act.perform()
	act.deinit()


	# Assertions
	assert_true(!act.is_ongoing(), "Act is still ongoing after deinit()!")


	await wait_process_frames(1)
func test_abort_prologue_on_deinit():

	# Prerequisites
	var prologue_act: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	prologue_act.init("Prologue Act")


	# Perform Act
	var main_act: Act = autofree(Act.new())
	main_act.init("Main Act")
	main_act.prologue = func(a) -> Array[Act]: return [prologue_act]
	main_act.perform()
	prologue_act.deinit()


	# Assertions
	assert_true(!main_act.is_ongoing(), "Main act is still ongoing after deinit()!")
	assert_true(!prologue_act.is_ongoing(), "Prologue act is still ongoing after deinit()!")


	await wait_process_frames(1)
func test_perform_count_reset_after_deinit():

	# Perform Act
	var act: Act = autofree(Act.new())
	act.init("Test Act")
	act.perform()
	var perform_count_before_deinit := act.get_perform_count()
	act.deinit()
	var perform_count_after_deinit := act.get_perform_count()


	# Assertions
	assert_true(perform_count_before_deinit == 1, "Act did not perform exactly once before deinit, Perform Count=%d" % [perform_count_before_deinit])
	assert_true(perform_count_after_deinit == 0, "Perform count did not reset after deinit, Perform Count=%d" % [perform_count_after_deinit])


	await wait_process_frames(1)
func test_removed_from_theater_after_deinit():

	# Prerequisites
	var theater_obj := Theater.new()
	add_child(theater_obj)


	# Perform Act
	var act: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act.init("Test Act", theater_obj)
	act.perform()
	var was_in_all_acts := theater_obj.get_all_acts().has(act)
	act.deinit()


	# Assertions
	assert_true(was_in_all_acts, "Act was never added to theater's all acts!")
	assert_false(theater_obj.get_all_acts().has(act), "Act still present in theater's all acts after deinit()!")
	assert_false(theater_obj.are_any_ongoing(), "Theater still reports act as ongoing after deinit()!")


	theater_obj.queue_free()
	await wait_process_frames(1)
