extends GutTest


# 1. Is block changed signal being broadcasted with correct arguments when blocked or unblocked?
# 1. Is block changed signal not being broadcasted when enabled or disabled?
# 1. Does blocking abort the act?
# 1. Can a persistently unblocked act perform?

# 1. Does interrupt block stop the act's ongoing perform?
# 1. Can a interrupt blocked act perform despite blocker act still ongoing?

# 1. Does adding an act to the main act (which is ongoing) block the act?
# 1. Does removing a blocked act from the main act (which is ongoing) unblock that act?
# 1. Does persistent blocking fail when adding self act to block?


func test_on_block_changed():

	# Prerequisites
	var was_block_changed_invoked := [false]
	var block_changed_arg_1 := [null]
	var block_changed_arg_2 := [null]
	var block_changed_arg_3 := [Act.BlockType.INTERRUPT]
	var block_changed_arg_4 := [false]


	# Setup main and target act
	var main_act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	var target_act: Act = autofree(Act.new())
	target_act.on_block_changed.connect(func(a, b_act, b_type, did_block):
		was_block_changed_invoked[0] = true
		block_changed_arg_1[0] = a
		block_changed_arg_2[0] = b_act
		block_changed_arg_3[0] = b_type
		block_changed_arg_4[0] = did_block
	)
	main_act.init("Main Act")
	target_act.init("Target Act")
	main_act.add_to_block([target_act])


	# Perform main act, Should block target act
	main_act.perform()


	# Assertions for block
	assert_true(was_block_changed_invoked[0], "on_block_changed not invoked on block!")
	assert_true(block_changed_arg_1[0] == target_act, "on_block_changed first argument is invalid! Arg1='%s'" % [block_changed_arg_1[0]])
	assert_true(block_changed_arg_2[0] == main_act, "on_block_changed second argument is invalid! Arg2='%s'" % [block_changed_arg_2[0]])
	assert_true(block_changed_arg_3[0] == Act.BlockType.PERSISTENT, "on_block_changed third argument is invalid! Arg3='%s'" % [Act.BlockType.keys()[block_changed_arg_3[0]]])
	assert_true(block_changed_arg_4[0] == true, "on_block_changed fourth argument is not true on block!")


	# Reset and finish main act, Should unblock target act
	was_block_changed_invoked[0] = false
	main_act.manual_finish()


	# Assertions for unblock
	assert_true(was_block_changed_invoked[0], "on_block_changed not invoked on unblock!")
	assert_true(block_changed_arg_1[0] == target_act, "on_block_changed first argument is invalid! Arg1='%s'" % [block_changed_arg_1[0]])
	assert_true(block_changed_arg_2[0] == main_act, "on_block_changed second argument is invalid! Arg2='%s'" % [block_changed_arg_2[0]])
	assert_true(block_changed_arg_3[0] == Act.BlockType.PERSISTENT, "on_block_changed third argument is invalid! Arg3='%s'" % [Act.BlockType.keys()[block_changed_arg_3[0]]])
	assert_true(block_changed_arg_4[0] == false, "on_block_changed fourth argument is not false on unblock!")


	await wait_process_frames(1)
func test_block_change_not_on_enable_disable():

	# Prerequisites
	var was_block_changed_invoked := [false]


	# Setup act
	var act: Act = autofree(Act.new())
	act.on_block_changed.connect(func(a, b_act, b_type, did_block): was_block_changed_invoked[0] = true)
	act.init("Test Act")


	# Disable and enable act
	act.set_enabled(false)
	act.set_enabled(true)


	# Assertions
	assert_true(!was_block_changed_invoked[0], "on_block_changed invoked despite enable disable!")


	await wait_process_frames(1)
func test_blocking_aborts_act():

	# Prerequisites
	var was_aborted := [false]
	var recived_outcome := [Act.Outcome.PENDING]


	# Setup main and target act
	var main_act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	var target_act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	target_act.on_pre_exit.connect(func(a):
		was_aborted[0] = true
		recived_outcome[0] = a.get_outcome()
	)
	main_act.init("Main Act")
	target_act.init("Target Act")
	main_act.add_to_block([target_act])


	# Perform target then main, Main should abort target
	target_act.perform()
	main_act.perform()


	# Assertions
	assert_true(was_aborted[0], "Target act did not go through exit despite getting blocked!")
	assert_true(recived_outcome[0] == Act.Outcome.INTERRUPTED, "Target act did not recieve 'INTERRUPTED' outcome on block! recived_outcome=%s" % [Act.Outcome.keys()[recived_outcome[0]]])
	assert_true(!target_act.is_ongoing(), "Target act is still ongoing despite getting blocked!")


	await wait_process_frames(1)
func test_unblocked_act_can_perform():

	# Setup main and target act
	var main_act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	var target_act: Act = autofree(Act.new())
	main_act.init("Main Act")
	target_act.init("Target Act")
	main_act.add_to_block([target_act])


	# Perform main act, Should block target act
	main_act.perform()


	# Finish main act, Should unblock target act
	main_act.manual_finish()
	target_act.perform()


	# Assertions
	assert_true(!target_act.is_blocked(), "Target act is still blocked despite main act finishing!")
	assert_true(target_act.get_perform_count() == 1, "Target act did not perform despite getting unblocked! Perform Count=%d" % [target_act.get_perform_count()])


	await wait_process_frames(1)
func test_interrupt_blocked_act_ends_perform():

	# Prerequisites
	var was_aborted := [false]


	# Setup main and target act
	var main_act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	var target_act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	target_act.on_pre_exit.connect(func(a): was_aborted[0] = true)
	main_act.init("Main Act")
	target_act.init("Target Act")
	main_act.add_to_block([target_act], Act.BlockType.INTERRUPT)


	# Perform target then main, Main should end target via interrupt block
	target_act.perform()
	main_act.perform()


	# Assertions
	assert_true(was_aborted[0], "Target act did not go through exit despite interrupt block!")
	assert_true(!target_act.is_ongoing(), "Target act is still ongoing despite interrupt block!")


	await wait_process_frames(1)
func test_interrupt_blocked_act_can_reperform():

	# Setup main and target act
	var main_act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	var target_act: Act = autofree(Act.new())
	main_act.init("Main Act")
	target_act.init("Target Act")
	main_act.add_to_block([target_act], Act.BlockType.INTERRUPT)


	# Perform main act, Should interrupt block target act once
	main_act.perform()
	target_act.perform()


	# Assertions
	assert_true(main_act.is_ongoing(), "Main act is not ongoing!")
	assert_true(!target_act.is_blocked(), "Target act is still blocked despite interrupt block!")
	assert_true(target_act.get_perform_count() == 1, "Target act did not perform despite interrupt block being one time only! Perform Count=%d" % [target_act.get_perform_count()])


	await wait_process_frames(1)
func test_add_to_block_while_ongoing():

	# Setup main and target act
	var main_act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	var target_act: Act = autofree(Act.new())
	main_act.init("Main Act")
	target_act.init("Target Act")


	# Perform main act first, Then add target to block
	main_act.perform()
	main_act.add_to_block([target_act])


	# Assertions
	assert_true(target_act.is_blocked(), "Target act is not blocked despite being added while main act is ongoing!")


	await wait_process_frames(1)
func test_remove_from_block_while_ongoing():

	# Setup main and target act
	var main_act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	var target_act: Act = autofree(Act.new())
	main_act.init("Main Act")
	target_act.init("Target Act")
	main_act.add_to_block([target_act])


	# Perform main act, Should block target act
	main_act.perform()


	# Remove target from block while main act still ongoing
	main_act.remove_from_block([target_act])


	# Assertions
	assert_true(main_act.is_ongoing(), "Main act is not ongoing!")
	assert_true(!target_act.is_blocked(), "Target act is still blocked despite being removed while main act is ongoing!")


	await wait_process_frames(1)
func test_add_self_to_block():

	# Setup main act
	var main_act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	main_act.init("Main Act")


	# Try adding self to block list
	main_act.add_to_block([main_act])
	main_act.perform()


	# Assertions
	assert_true(main_act.is_ongoing(), "Main act did not perform despite trying to add self to block being a no op!")
	assert_true(!main_act.is_blocked(), "Main act got blocked despite trying to add self to block being reserved for enable disable!")


	await wait_process_frames(1)
