extends GutTest


# 1. Are pre exit and post exit signals being broadcasted with correct arguments?
# 1. Is _exit() being invoked?
# 1. Does invoking abort() while exiting not exit the act again?
# 1. Is the status reset to None after exiting?
# 1. Is perform end signal being invoked after exiting?


func test_on_pre_and_post_exit():

	# Prerequisites
	var was_pre_exit_invoked := [false]
	var pre_exit_arg_1 := [null]
	var was_post_exit_invoked := [false]
	var post_exit_arg_1 := [null]


	# Perform Act
	var act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act.on_pre_exit.connect(func(a): was_pre_exit_invoked[0] = true; pre_exit_arg_1[0] = a)
	act.on_post_exit.connect(func(a): was_post_exit_invoked[0] = true; post_exit_arg_1[0] = a)
	act.init("Test Act")
	act.perform()
	act.manual_finish()


	# Assertions
	assert_true(was_pre_exit_invoked[0], "on_pre_exit not invoked!")
	assert_true(pre_exit_arg_1[0] == act, "on_pre_exit first argument is invalid! Arg1='%s'" % [pre_exit_arg_1[0]])
	assert_true(was_post_exit_invoked[0], "on_post_exit not invoked!")
	assert_true(post_exit_arg_1[0] == act, "on_post_exit first argument is invalid! Arg1='%s'" % [post_exit_arg_1[0]])


	await wait_process_frames(1)
func test_exit():

	# Perform Act
	var act: Utilities.ExitAct = autofree(Utilities.ExitAct.new())
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(act.call_count == 1, "_exit() not invoked exactly once! Call count='%d'" % [act.call_count])


	await wait_process_frames(1)
func test_perform_while_exiting_reperformable():

	# Perform Act
	var act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act.can_reperform_override = true
	act.on_pre_exit.connect(func(a): act.perform())
	act.init("Test Act")
	act.perform()
	act.manual_finish()


	# Assertions
	assert_true(act.get_perform_count() == 1, "Act reperformed while exiting despite can_reperform true! Perform Count=%d" % [act.get_perform_count()])


	await wait_process_frames(1)
func test_abort_while_exiting():

	# Perform Act
	var pre_exit_call_count := [0]
	var act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act.on_pre_exit.connect(func(a): pre_exit_call_count[0] += 1; act.abort())
	act.init("Test Act")
	act.perform()
	act.manual_finish()


	# Assertions
	assert_true(pre_exit_call_count[0] == 1, "Act exited more than once from calling abort() while exiting! Call count=%d" % [pre_exit_call_count[0]])


	await wait_process_frames(1)
func test_status_reset_after_exit():

	# Perform Act
	var act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act.init("Test Act")
	act.perform()
	act.manual_finish()

	var status_after_exit := act.get_status()


	# Assertions
	assert_true(status_after_exit == Act.Status.NONE, "Status did not reset to 'NONE' after exiting! Status='%s'" % [Act.Status.keys()[status_after_exit]])


	await wait_process_frames(1)
func test_on_perform_end_after_exit():

	# Prerequisites
	var was_perform_end_invoked := [false]
	var perform_end_arg_1 := [null]
	var status_during_on_perform_end := [Act.Status.ENTERING]


	# Perform Act
	var act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act.on_perform_end.connect(func(a):
		status_during_on_perform_end[0] = a.get_status()
		was_perform_end_invoked[0] = true
		perform_end_arg_1[0] = a
	)
	act.init("Test Act")
	act.perform()
	act.manual_finish()


	# Assertions
	assert_true(was_perform_end_invoked[0], "on_perform_end not invoked after exiting!")
	assert_true(status_during_on_perform_end[0] == Act.Status.NONE, "Incorrect status in on_perform_end! status=%s  expected status=%s" % [Act.Status.keys()[status_during_on_perform_end[0]], Act.Status.keys()[Act.Status.NONE]])
	assert_true(perform_end_arg_1[0] == act, "on_perform_end first argument is invalid! Arg1='%s'" % [perform_end_arg_1[0]])


	await wait_process_frames(1)
