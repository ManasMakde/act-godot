extends GutTest


# 1. Is enabled changed signal broadcasted with correct arguments?
# 1. Is perform start signal broadcasted with correct arguments?
# 1. Is perform end signal broadcasted with correct arguments?
# 1. Is all perform end signal broadcasted with correct arguments?

# 1. Does is_enabled() return correct state?
# 1. Does disabling theater abort all acts?
# 1. Can disabled theater acts perform?

# 1. Does abort_all() abort all acts?
# 1. Can all acts perform after abort_all() is invoked?

# 1. Does are_any_ongoing() return correct state?
# 1. Does get_all_acts() return all acts assigned to theater?


func test_enabled_changed():

	# Prerequisites
	var was_invoked := [false]
	var arg_1 := [null]
	var arg_2 := [false]

	# Setup Theater
	var theater: Theater = add_child_autofree(Theater.new())
	theater.on_enable_changed.connect(func(t, new_is_enabled):
		was_invoked[0] = true
		arg_1[0] = t
		arg_2[0] = new_is_enabled
	)

	theater.set_enabled(false)


	# Assertions
	assert_true(was_invoked[0], "on_enable_changed not invoked!")
	assert_true(arg_1[0] == theater, "on_enable_changed first argument is invalid! Arg1='%s'" % [arg_1[0]])
	assert_true(arg_2[0] == false, "on_enable_changed second argument is invalid! Arg2='%s'" % [arg_2[0]])

	await wait_process_frames(1)
func test_perform_start():

	# Prerequisites
	var was_invoked := [false]
	var arg_1 := [null]
	var arg_2 := [null]

	# Setup Theater
	var theater: Theater = add_child_autofree(Theater.new())
	theater.on_perform_start.connect(func(t, a):
		was_invoked[0] = true
		arg_1[0] = t
		arg_2[0] = a
	)

	# Perform Act
	var act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act.init("Test Act", theater)
	act.perform()


	# Assertions
	assert_true(was_invoked[0], "on_perform_start not invoked!")
	assert_true(arg_1[0] == theater, "on_perform_start first argument is invalid! Arg1='%s'" % [arg_1[0]])
	assert_true(arg_2[0] == act, "on_perform_start second argument is invalid! Arg2='%s'" % [arg_2[0]])

	await wait_process_frames(1)
func test_perform_end():

	# Prerequisites
	var was_invoked := [false]
	var arg_1 := [null]
	var arg_2 := [null]

	# Setup Theater
	var theater: Theater = add_child_autofree(Theater.new())
	theater.on_perform_end.connect(func(t, a):
		was_invoked[0] = true
		arg_1[0] = t
		arg_2[0] = a
	)

	# Perform Act
	var act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act.init("Test Act", theater)
	act.perform()
	act.manual_finish()


	# Assertions
	assert_true(was_invoked[0], "on_perform_end not invoked!")
	assert_true(arg_1[0] == theater, "on_perform_end first argument is invalid! Arg1='%s'" % [arg_1[0]])
	assert_true(arg_2[0] == act, "on_perform_end second argument is invalid! Arg2='%s'" % [arg_2[0]])

	await wait_process_frames(1)
func test_all_perform_end():

	# Prerequisites
	var invoke_count := [0]
	var arg_1 := [null]

	# Setup Theater
	var theater: Theater = add_child_autofree(Theater.new())
	theater.on_all_perform_end.connect(func(t):
		invoke_count[0] += 1
		arg_1[0] = t
	)

	# Perform Acts
	var act_a: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_a.init("Test Act A", theater)
	act_a.perform()
	var act_b: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_b.init("Test Act B", theater)
	act_b.perform()

	# Finish first act only
	act_a.manual_finish()


	# Assertions
	assert_true(invoke_count[0] == 0, "on_all_perform_end invoked despite one act still ongoing! Invoke Count='%d'" % [invoke_count[0]])

	# Finish second act
	act_b.manual_finish()


	# Assertions
	assert_true(invoke_count[0] == 1, "on_all_perform_end not invoked exactly once! Invoke Count='%d'" % [invoke_count[0]])
	assert_true(arg_1[0] == theater, "on_all_perform_end argument is invalid! Arg1='%s'" % [arg_1[0]])

	await wait_process_frames(1)


func test_is_enabled():

	# Setup Theater
	var theater: Theater = add_child_autofree(Theater.new())

	var is_enabled_0 := theater.is_enabled()
	theater.set_enabled(true)
	var is_enabled_1 := theater.is_enabled()
	theater.set_enabled(false)
	var is_enabled_2 := theater.is_enabled()
	theater.set_enabled(true)
	var is_enabled_3 := theater.is_enabled()


	# Assertions
	assert_true(is_enabled_0, "is_enabled() is false despite theater being enabled by default!")
	assert_true(is_enabled_1, "is_enabled() is false despite theater being set enabled!")
	assert_true(!is_enabled_2, "is_enabled() is true despite theater being set disabled!")
	assert_true(is_enabled_3, "is_enabled() is false despite theater being set enabled again!")

	await wait_process_frames(1)
func test_disabling_theater_aborts_all_acts():

	# Setup Theater
	var theater: Theater = add_child_autofree(Theater.new())

	# Perform Acts
	var act_a: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act_a.init("Test Act A", theater)

	var act_b: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act_b.init("Test Act B", theater)

	var act_c: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act_c.init("Test Act C", theater)


	act_a.perform()
	act_b.perform()
	act_c.perform()

	# Disable Theater
	theater.set_enabled(false)


	# Assertions
	assert_true(!act_a.is_ongoing(), "Act A still ongoing despite theater being disabled!")
	assert_true(!act_b.is_ongoing(), "Act B still ongoing despite theater being disabled!")
	assert_true(!act_c.is_ongoing(), "Act C still ongoing despite theater being disabled!")

	await wait_process_frames(1)
func test_disabled_theater_acts_cannot_perform():

	# Setup Theater
	var theater: Theater = add_child_autofree(Theater.new())
	theater.set_enabled(false)

	# Perform Acts
	var act_a: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act_a.init("Test Act A", theater)

	var act_b: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act_b.init("Test Act B", theater)

	var act_c: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act_c.init("Test Act C", theater)


	act_a.perform()
	act_b.perform()
	act_c.perform()


	# Assertions
	assert_true(!act_a.is_ongoing(), "Act A is ongoing despite theater being disabled!")
	assert_true(!act_b.is_ongoing(), "Act B is ongoing despite theater being disabled!")
	assert_true(!act_c.is_ongoing(), "Act C is ongoing despite theater being disabled!")

	await wait_process_frames(1)


func test_abort_all():

	# Setup Theater
	var theater: Theater = add_child_autofree(Theater.new())

	# Perform Acts
	var act_a: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act_a.init("Test Act A", theater)

	var act_b: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act_b.init("Test Act B", theater)

	var act_c: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act_c.init("Test Act C", theater)


	act_a.perform()
	act_b.perform()
	act_c.perform()


	# Abort All
	theater.abort_all()


	# Assertions
	assert_true(!act_a.is_ongoing(), "Act A still ongoing despite abort_all() being invoked!")
	assert_true(!act_b.is_ongoing(), "Act B still ongoing despite abort_all() being invoked!")
	assert_true(!act_c.is_ongoing(), "Act C still ongoing despite abort_all() being invoked!")

	await wait_process_frames(1)
func test_perform_after_abort_all():

	# Setup Theater
	var theater: Theater = add_child_autofree(Theater.new())

	# Perform Acts
	var act_a: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act_a.init("Test Act A", theater)
	var act_b: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act_b.init("Test Act B", theater)
	var act_c: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act_c.init("Test Act C", theater)

	act_a.perform()
	act_b.perform()
	act_c.perform()


	# Abort All
	theater.abort_all()


	# Reperform Acts
	act_a.perform()
	act_b.perform()
	act_c.perform()


	# Assertions
	assert_true(act_a.is_ongoing(), "Act A did not perform after abort_all() was invoked!")
	assert_true(act_b.is_ongoing(), "Act B did not perform after abort_all() was invoked!")
	assert_true(act_c.is_ongoing(), "Act C did not perform after abort_all() was invoked!")

	await wait_process_frames(1)


func test_are_any_ongoing():

	# All acts ongoing
	var theater_1: Theater = add_child_autofree(Theater.new())

	var act_a_1: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act_a_1.init("Test Act A", theater_1)
	act_a_1.perform()

	var act_b_1: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act_b_1.init("Test Act B", theater_1)
	act_b_1.perform()

	var act_c_1: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act_c_1.init("Test Act C", theater_1)
	act_c_1.perform()


	# Assertions
	assert_true(theater_1.are_any_ongoing(), "are_any_ongoing() is false despite all acts ongoing!")


	# One act ongoing rest not
	var theater_2: Theater = add_child_autofree(Theater.new())

	var act_a_2: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act_a_2.init("Test Act A", theater_2)
	act_a_2.perform()

	var act_b_2: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_b_2.init("Test Act B", theater_2)
	act_b_2.perform()
	act_b_2.manual_finish()

	var act_c_2: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_c_2.init("Test Act C", theater_2)
	act_c_2.perform()
	act_c_2.manual_finish()


	# Assertions
	assert_true(theater_2.are_any_ongoing(), "are_any_ongoing() is false despite one act still ongoing!")


	# No acts ongoing
	var theater_3: Theater = add_child_autofree(Theater.new())

	var act_a_3: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_a_3.init("Test Act A", theater_3)
	act_a_3.perform()
	act_a_3.manual_finish()

	var act_b_3: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_b_3.init("Test Act B", theater_3)
	act_b_3.perform()
	act_b_3.manual_finish()

	var act_c_3: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_c_3.init("Test Act C", theater_3)
	act_c_3.perform()
	act_c_3.manual_finish()


	# Assertions
	assert_false(theater_3.are_any_ongoing(), "are_any_ongoing() is true despite no acts ongoing!")

	await wait_process_frames(1)
func test_get_all_acts_returns_all_acts():

	# Only 1 act passed
	var theater_1: Theater = add_child_autofree(Theater.new())

	var act_a_1: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_a_1.init("Test Act A", theater_1)

	var all_acts_1 := theater_1.get_all_acts()


	# Assertions
	assert_true(all_acts_1.has(act_a_1), "get_all_acts() does not contain Act A!")
	assert_true(all_acts_1.size() == 1, "get_all_acts() returned incorrect count! Count='%d'" % [all_acts_1.size()])


	# 2 acts passed
	var theater_2: Theater = add_child_autofree(Theater.new())

	var act_a_2: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_a_2.init("Test Act A", theater_2)

	var act_b_2: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_b_2.init("Test Act B", theater_2)

	var all_acts_2 := theater_2.get_all_acts()


	# Assertions
	assert_true(all_acts_2.has(act_a_2), "get_all_acts() does not contain Act A!")
	assert_true(all_acts_2.has(act_b_2), "get_all_acts() does not contain Act B!")
	assert_true(all_acts_2.size() == 2, "get_all_acts() returned incorrect count! Count='%d'" % [all_acts_2.size()])


	# 3 acts passed
	var theater_3: Theater = add_child_autofree(Theater.new())

	var act_a_3: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_a_3.init("Test Act A", theater_3)

	var act_b_3: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_b_3.init("Test Act B", theater_3)

	var act_c_3: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	act_c_3.init("Test Act C", theater_3)

	var all_acts_3 := theater_3.get_all_acts()


	# Assertions
	assert_true(all_acts_3.has(act_a_3), "get_all_acts() does not contain Act A!")
	assert_true(all_acts_3.has(act_b_3), "get_all_acts() does not contain Act B!")
	assert_true(all_acts_3.has(act_c_3), "get_all_acts() does not contain Act C!")
	assert_true(all_acts_3.size() == 3, "get_all_acts() returned incorrect count! Count='%d'" % [all_acts_3.size()])

	await wait_process_frames(1)
