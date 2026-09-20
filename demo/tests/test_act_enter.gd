extends GutTest


# 1. Are pre enter and post enter signals being broadcasted with correct arguments?
# 1. Is _enter() being invoked?
# 1. Does returning outcome pending make the act wait until _finish() is invoked?
# 1. Does using _finish() pass accurate outcomes to _exit()?


func test_on_pre_and_post_enter():

	# Prerequisites
	var was_pre_enter_invoked := [false]
	var pre_enter_arg_1 := [null]
	var was_post_enter_invoked := [false]
	var post_enter_arg_1 := [null]


	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_pre_enter.connect(func(a): was_pre_enter_invoked[0] = true; pre_enter_arg_1[0] = a)
	act.on_post_enter.connect(func(a): was_post_enter_invoked[0] = true; post_enter_arg_1[0] = a)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(was_pre_enter_invoked[0], "on_pre_enter not invoked!")
	assert_true(pre_enter_arg_1[0] == act, "on_pre_enter first argument is invalid! Arg1='%s'" % [pre_enter_arg_1[0]])
	assert_true(was_post_enter_invoked[0], "on_post_enter not invoked!")
	assert_true(post_enter_arg_1[0] == act, "on_post_enter first argument is invalid! Arg1='%s'" % [post_enter_arg_1[0]])


	await wait_process_frames(1)
func test_enter():

	# Perform Act
	var act: Utilities.EnterAct = autofree(Utilities.EnterAct.new())
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(act.call_count == 1, "_enter() not invoked exactly once! Call count='%d'" % [act.call_count])


	await wait_process_frames(1)
func test_enter_finish():

	# Perform Act
	var went_through_exit := [false]
	var act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act.on_pre_exit.connect(func(a): went_through_exit[0] = true)
	act.init("Test Act")
	act.perform()

	var act_status := act.get_status()
	var was_ongoing := act.is_ongoing()

	act.manual_finish()

	var did_complete := !act.is_ongoing()


	# Assertions
	assert_true(act_status == Act.Status.ENTERING, "Act did not have status 'ENTERING' despite pending outcome! Status='%s'" % [Act.Status.keys()[act_status]])
	assert_true(was_ongoing, "Act is not ongoing despite pending outcome!")
	assert_true(did_complete && act.get_perform_count() == 1, "Act is not exit despite calling _finish()! Perform Count=%d" % [act.get_perform_count()])
	assert_true(went_through_exit[0], "Act is not go through exit on calling _finish()!")

	await wait_process_frames(1)
func test_finish_passes_accurate_outcome():

	# Interrupted outcome
	var given_outcome_interrupted := Act.Outcome.INTERRUPTED
	var recived_outcome_interrupted := [Act.Outcome.PENDING]
	var act_interrupted: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_interrupted.on_pre_exit.connect(func(a): recived_outcome_interrupted[0] = a.get_outcome())
	act_interrupted.init("Test Act")
	act_interrupted.perform()
	act_interrupted.manual_finish(given_outcome_interrupted)


	# Assertions
	assert_true(recived_outcome_interrupted[0] == given_outcome_interrupted, "Failed to pass 'INTERRUPTED' outcome to _exit()! given_outcome=%s  recived_outcome=%s" % [Act.Outcome.keys()[given_outcome_interrupted], Act.Outcome.keys()[recived_outcome_interrupted[0]]])


	# Failure outcome
	var given_outcome_failure := Act.Outcome.FAILURE
	var recived_outcome_failure := [Act.Outcome.PENDING]
	var act_failure: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_failure.on_pre_exit.connect(func(a): recived_outcome_failure[0] = a.get_outcome())
	act_failure.init("Test Act")
	act_failure.perform()
	act_failure.manual_finish(given_outcome_failure)


	# Assertions
	assert_true(recived_outcome_failure[0] == given_outcome_failure, "Failed to pass 'FAILURE' outcome to _exit()! given_outcome=%s  recived_outcome=%s" % [Act.Outcome.keys()[given_outcome_failure], Act.Outcome.keys()[recived_outcome_failure[0]]])


	# Success outcome
	var given_outcome_success := Act.Outcome.SUCCESS
	var recived_outcome_success := [Act.Outcome.PENDING]
	var act_success: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_success.on_pre_exit.connect(func(a): recived_outcome_success[0] = a.get_outcome())
	act_success.init("Test Act")
	act_success.perform()
	act_success.manual_finish(given_outcome_success)


	# Assertions
	assert_true(recived_outcome_success[0] == given_outcome_success, "Failed to pass 'SUCCESS' outcome to _exit()! given_outcome=%s  recived_outcome=%s" % [Act.Outcome.keys()[given_outcome_success], Act.Outcome.keys()[recived_outcome_success[0]]])


	# Retry outcome
	var given_outcome_retry := Act.Outcome.RETRY
	var recived_outcome_retry := [Act.Outcome.PENDING]
	var act_retry: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_retry.on_pre_exit.connect(func(a): recived_outcome_retry[0] = a.get_outcome())
	act_retry.init("Test Act")
	act_retry.perform()
	act_retry.manual_finish(given_outcome_retry)


	# Assertions
	assert_true(recived_outcome_retry[0] == given_outcome_retry, "Failed to pass 'RETRY' outcome to _exit()! given_outcome=%s  recived_outcome=%s" % [Act.Outcome.keys()[given_outcome_retry], Act.Outcome.keys()[recived_outcome_retry[0]]])


	await wait_process_frames(1)
