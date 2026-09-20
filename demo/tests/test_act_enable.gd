extends GutTest


# 1. Is enable changed signal broadcasted with correct arguments when enabled disabled?
# 1. Is enable changed signal not called when blocked unblocked?
# 1. Does disabling abort the act?


func test_on_enable_changed():

	# Prerequisites
	var was_enable_changed_invoked := [false]
	var enable_changed_arg_1 := [null]
	var enable_changed_arg_2 := [true]


	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_enable_changed.connect(func(a, new_is_enabled):
		was_enable_changed_invoked[0] = true
		enable_changed_arg_1[0] = a
		enable_changed_arg_2[0] = new_is_enabled
	)
	act.init("Test Act")
	act.set_enabled(false)


	# Assertions disable
	assert_true(was_enable_changed_invoked[0], "on_enable_changed not invoked on disable!")
	assert_true(enable_changed_arg_1[0] == act, "on_enable_changed first argument is invalid! Arg1='%s'" % [enable_changed_arg_1[0]])
	assert_true(enable_changed_arg_2[0] == false, "on_enable_changed second argument is invalid on disable! Arg2='%s'" % [enable_changed_arg_2[0]])


	# Reset and enable back
	was_enable_changed_invoked[0] = false
	act.set_enabled(true)


	# Assertions enable
	assert_true(was_enable_changed_invoked[0], "on_enable_changed not invoked on enable!")
	assert_true(enable_changed_arg_2[0] == true, "on_enable_changed second argument is invalid on enable! Arg2='%s'" % [enable_changed_arg_2[0]])


	await wait_process_frames(1)
func test_enable_changed_not_called_on_block():

	# Prerequisites
	var was_enable_changed_invoked := [false]


	# Perform Act
	var act: Act = autofree(Act.new())
	var blocker_act: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act.on_enable_changed.connect(func(a, new_is_enabled): was_enable_changed_invoked[0] = true)
	act.init("Test Act")
	blocker_act.init("Blocker Act")
	blocker_act.perform()


	# Block act using ongoing blocker
	blocker_act.add_to_block([act])


	# Assertions blocked
	assert_true(act.is_blocked(), "Act was not blocked!")
	assert_false(was_enable_changed_invoked[0], "on_enable_changed invoked on block!")


	# Unblock act
	blocker_act.remove_from_block([act])


	# Assertions unblocked
	assert_false(act.is_blocked(), "Act was not unblocked!")
	assert_false(was_enable_changed_invoked[0], "on_enable_changed invoked on unblock!")


	await wait_process_frames(1)
func test_disabling_aborts_act():

	# Perform Act
	var act: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act.init("Test Act")
	act.perform()

	var was_ongoing := act.is_ongoing()

	act.set_enabled(false)

	var is_ongoing_after_disable := act.is_ongoing()


	# Assertions
	assert_true(was_ongoing, "Act was not ongoing before disable!")
	assert_false(is_ongoing_after_disable, "Act was not aborted on disable!")


	await wait_process_frames(1)
