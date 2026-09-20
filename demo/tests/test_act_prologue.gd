extends GutTest


# 1. Is on_pre_prologue signal being broadcasted with correct arguments?
# 1. Is on_pre_prologue signal not being broadcasted when no prologue acts assigned?
# 1. Is on_pre_prologue signal not being broadcasted when assigned empty prologue acts list?

# 1. Is on_post_prologue signal being broadcasted with correct arguments?
# 1. Is on_post_prologue signal not being broadcasted when no prologue acts assigned?
# 1. Is on_post_prologue signal not being broadcasted when assigned empty prologue acts list?
# 1. Is on_post_prologue signal not being broadcasted when null passed to prologue?
# 1. Is on_post_prologue signal not being broadcasted when any prologue act fails?

# 1. Is on_prologue_complete signal being broadcasted with correct arguments?
# 1. Is on_prologue_complete signal not being broadcasted when no prologue acts assigned?
# 1. Is on_prologue_complete signal not being broadcasted when assigned empty prologue acts list?
# 1. Is on_prologue_complete signal not being broadcasted when null passed to prologue?
# 1. Is on_prologue_complete signal not being broadcasted when any prologue act fails?

# 1. Does an act calling itself as one of the prologues get skipped?
# 1. Does an act only calling itself as prologue get skipped?

# 1. Does prologue null and null both fail the act?
# 1. Does seq() nested null null and null all fail the act?

# 1. Does main act perform when a prologue act blocks it?
# 1. Does prologue act perform when main act blocks it?
# 1. Does grandchild prologue act perform when main act blocks it?
# 1. Does main act perform when grandchild prologue act blocks it?
# 1. Do sibling acts perform when they block each other?


func test_on_pre_prologue():

	# Prerequisites
	var was_pre_prologue_invoked := [false]
	var pre_prologue_arg_1 := [null]

	var p_act: Act = autofree(Act.new())


	# Perform Act
	var act: Act = autofree(Act.new())
	act.prologue = func(a) -> Array[Act]: return [p_act]
	act.on_pre_prologue.connect(func(a): was_pre_prologue_invoked[0] = true; pre_prologue_arg_1[0] = a)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(was_pre_prologue_invoked[0], "on_pre_prologue not invoked!")
	assert_true(pre_prologue_arg_1[0] == act, "on_pre_prologue first argument is invalid! Arg1=`%s`" % [pre_prologue_arg_1[0]])

	await wait_process_frames(1)
func test_on_pre_prologue_broadcast_with_no_prologues():

	# Prerequisites
	var was_pre_prologue_invoked := [false]


	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_pre_prologue.connect(func(a): was_pre_prologue_invoked[0] = true)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(!was_pre_prologue_invoked[0], "on_pre_prologue invoked despite no prologue acts assigned!")

	await wait_process_frames(1)
func test_on_pre_prologue_broadcast_with_empty_prologues():

	# Prerequisites
	var was_pre_prologue_invoked := [false]


	# Perform Act
	var act: Act = autofree(Act.new())
	act.prologue = func(a) -> Array[Act]: return []
	act.on_pre_prologue.connect(func(a): was_pre_prologue_invoked[0] = true)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(!was_pre_prologue_invoked[0], "on_pre_prologue invoked despite empty prologue list assigned!")

	await wait_process_frames(1)



func test_on_post_prologue():

	# Prerequisites
	var was_post_prologue_invoked := [false]
	var post_prologue_arg_1 := [null]

	var p_act: Act = autofree(Act.new())


	# Perform Act
	var act: Act = autofree(Act.new())
	act.prologue = func(a) -> Array[Act]: return [p_act]
	act.on_post_prologue.connect(func(a): was_post_prologue_invoked[0] = true; post_prologue_arg_1[0] = a)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(was_post_prologue_invoked[0], "on_post_prologue not invoked!")
	assert_true(post_prologue_arg_1[0] == act, "on_post_prologue first argument is invalid! Arg1=`%s`" % [post_prologue_arg_1[0]])

	await wait_process_frames(1)
func test_on_post_prologue_with_no_prologues():

	# Prerequisites
	var was_post_prologue_invoked := [false]


	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_post_prologue.connect(func(a): was_post_prologue_invoked[0] = true)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(!was_post_prologue_invoked[0], "on_post_prologue invoked despite no prologue acts assigned!")

	await wait_process_frames(1)
func test_on_post_prologue_with_empty_prologues():

	# Prerequisites
	var was_post_prologue_invoked := [false]


	# Perform Act
	var act: Act = autofree(Act.new())
	act.prologue = func(a) -> Array[Act]: return []
	act.on_post_prologue.connect(func(a): was_post_prologue_invoked[0] = true)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(!was_post_prologue_invoked[0], "on_post_prologue invoked despite empty prologue list assigned!")

	await wait_process_frames(1)
func test_on_post_prologue_with_null_prologue():

	# Prerequisites
	var was_post_prologue_invoked := [false]


	# Perform Act
	var act: Act = autofree(Act.new())
	act.prologue = func(a): return [null]
	act.on_post_prologue.connect(func(a): was_post_prologue_invoked[0] = true)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(!was_post_prologue_invoked[0], "on_post_prologue invoked despite null prologue act!")
	assert_true(act.get_outcome() == Act.Outcome.FAILURE, "Act outcome is not failure despite null prologue act! Outcome=%s" % [Act.Outcome.keys()[act.get_outcome()]])

	await wait_process_frames(1)
func test_on_post_prologue_when_prologue_fails():

	# Prerequisites
	var was_post_prologue_invoked := [false]

	var p_act: Utilities.FailingAct = autofree(Utilities.FailingAct.new())


	# Perform Act
	var act: Act = autofree(Act.new())
	act.prologue = func(a) -> Array[Act]: return [p_act]
	act.on_post_prologue.connect(func(a): was_post_prologue_invoked[0] = true)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(!was_post_prologue_invoked[0], "on_post_prologue invoked despite prologue act failing!")
	assert_true(act.get_outcome() == Act.Outcome.FAILURE, "Act outcome is not failure despite prologue act failing! Outcome=%s" % [Act.Outcome.keys()[act.get_outcome()]])

	await wait_process_frames(1)



func test_on_prologue_complete():

	# Prerequisites
	var was_prologue_complete_invoked := [false]
	var prologue_complete_arg_1 := [null]
	var prologue_complete_arg_2 := [null]
	var prologue_complete_arg_3 := [Act.Outcome.PENDING]


	# Prologue Act
	var p_act: Act = autofree(Act.new())
	p_act.init("Prologue Act")


	# Perform Act
	var act: Act = autofree(Act.new())
	act.prologue = func(a) -> Array[Act]: return [p_act]
	act.on_prologue_complete.connect(func(a, p, o):
		was_prologue_complete_invoked[0] = true
		prologue_complete_arg_1[0] = a
		prologue_complete_arg_2[0] = p
		prologue_complete_arg_3[0] = o
	)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(was_prologue_complete_invoked[0], "on_prologue_complete not invoked!")
	assert_true(prologue_complete_arg_1[0] == act, "on_prologue_complete first argument is invalid! Arg1=`%s`" % [prologue_complete_arg_1[0]])
	assert_true(prologue_complete_arg_2[0] == p_act, "on_prologue_complete second argument is invalid! Arg2=`%s`" % [prologue_complete_arg_2[0]])
	assert_true(prologue_complete_arg_3[0] == Act.Outcome.SUCCESS, "on_prologue_complete third argument is invalid! Arg3=`%s`" % [Act.Outcome.keys()[prologue_complete_arg_3[0]]])

	await wait_process_frames(1)
func test_on_prologue_complete_with_no_prologues():

	# Prerequisites
	var was_prologue_complete_invoked := [false]


	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_prologue_complete.connect(func(a, p, o): was_prologue_complete_invoked[0] = true)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(!was_prologue_complete_invoked[0], "on_prologue_complete invoked despite no prologue acts assigned!")

	await wait_process_frames(1)
func test_on_prologue_complete_with_empty_prologues():

	# Prerequisites
	var was_prologue_complete_invoked := [false]


	# Perform Act
	var act: Act = autofree(Act.new())
	act.prologue = func(a) -> Array[Act]: return []
	act.on_prologue_complete.connect(func(a, p, o): was_prologue_complete_invoked[0] = true)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(!was_prologue_complete_invoked[0], "on_prologue_complete invoked despite empty prologue list assigned!")

	await wait_process_frames(1)
func test_on_prologue_complete_with_null_prologue():

	# Prerequisites
	var was_prologue_complete_invoked := [false]


	# Perform Act
	var act: Act = autofree(Act.new())
	act.prologue = func(a): return [null]
	act.on_prologue_complete.connect(func(a, p, o): was_prologue_complete_invoked[0] = true)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(!was_prologue_complete_invoked[0], "on_prologue_complete invoked despite null prologue act!")
	assert_true(act.get_outcome() == Act.Outcome.FAILURE, "Act outcome is not failure despite null prologue act! Outcome=%s" % [Act.Outcome.keys()[act.get_outcome()]])

	await wait_process_frames(1)
func test_on_prologue_complete_when_prologue_fails():

	# Prerequisites
	var was_prologue_complete_invoked := [false]
	var prologue_complete_outcome := [Act.Outcome.PENDING]

	var p_act: Utilities.FailingAct = autofree(Utilities.FailingAct.new())


	# Perform Act
	var act: Act = autofree(Act.new())
	act.prologue = func(a) -> Array[Act]: return [p_act]
	act.on_prologue_complete.connect(func(a, p, o): was_prologue_complete_invoked[0] = true; prologue_complete_outcome[0] = o)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(was_prologue_complete_invoked[0], "on_prologue_complete not invoked despite prologue act failing!")
	assert_true(prologue_complete_outcome[0] == Act.Outcome.FAILURE, "on_prologue_complete outcome is not failure! Outcome=%s" % [Act.Outcome.keys()[prologue_complete_outcome[0]]])
	assert_true(act.get_outcome() == Act.Outcome.FAILURE, "Act outcome is not failure despite prologue act failing! Outcome=%s" % [Act.Outcome.keys()[act.get_outcome()]])

	await wait_process_frames(1)



func test_self_as_only_prologue_skipped():

	# Perform Act
	var act: Act = autofree(Act.new())
	act.prologue = func(a) -> Array[Act]: return [a]
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(act.get_outcome() == Act.Outcome.SUCCESS, "Act could not perform when passing only itself as prologue!")

	await wait_process_frames(1)
func test_self_as_prologue_skipped():

	# Prologue Act
	var did_prologue_perform := [false]
	var p_act: Act = autofree(Act.new())
	p_act.on_pre_enter.connect(func(a): did_prologue_perform[0] = true)
	p_act.init("Prologue Act")


	# Perform Act
	var did_enter := [false]
	var act: Act = autofree(Act.new())
	act.prologue = func(a) -> Array[Act]: return [a, p_act]
	act.on_pre_enter.connect(func(a): did_enter[0] = true)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(did_enter[0], "Act could not perform when passing itself as one of the prologues!")
	assert_true(did_prologue_perform[0], "Passing self as prologue interfered with other prologue")

	await wait_process_frames(1)



func test_prologue_null():

	# Null prologue list
	var act_1: Act = autofree(Act.new())
	act_1.prologue = func(a): return null
	act_1.init("Test Act")
	act_1.perform()

	# Assertions
	assert_true(act_1.get_outcome() == Act.Outcome.FAILURE, "Act did not fail when prologue returned null! Outcome=%s" % [Act.Outcome.keys()[act_1.get_outcome()]])


	# Prologue list containing null
	var act_2: Act = autofree(Act.new())
	act_2.prologue = func(a): return [null]
	act_2.init("Test Act")
	act_2.perform()

	# Assertions
	assert_true(act_2.get_outcome() == Act.Outcome.FAILURE, "Act did not fail when prologue list contained null! Outcome=%s" % [Act.Outcome.keys()[act_2.get_outcome()]])

	await wait_process_frames(1)
func test_seq_prologue_null():

	# Seq with inner list containing null
	var act_1: Act = autofree(Act.new())
	act_1.prologue = func(a): return Act.seq([[null]])
	act_1.init("Test Act")
	act_1.perform()

	# Assertions
	assert_true(act_1.get_outcome() == Act.Outcome.FAILURE, "Act did not fail for seq() with inner null! Outcome=%s" % [Act.Outcome.keys()[act_1.get_outcome()]])


	# Seq with null inner list
	var act_2: Act = autofree(Act.new())
	act_2.prologue = func(a): return Act.seq([null])
	act_2.init("Test Act")
	act_2.perform()

	# Assertions
	assert_true(act_2.get_outcome() == Act.Outcome.FAILURE, "Act did not fail for seq() with null inner list! Outcome=%s" % [Act.Outcome.keys()[act_2.get_outcome()]])


	# Seq with null passed directly
	var act_3: Act = autofree(Act.new())
	act_3.prologue = func(a): return Act.seq(null)
	act_3.init("Test Act")
	act_3.perform()

	# Assertions
	assert_true(act_3.get_outcome() == Act.Outcome.FAILURE, "Act did not fail for seq(null)! Outcome=%s" % [Act.Outcome.keys()[act_3.get_outcome()]])

	await wait_process_frames(1)



func test_main_act_blocking_prologue():

	# Prerequisites
	var prologue_act: Act = autofree(Act.new())
	prologue_act.init("Prologue Act")


	# Perform Act
	var main_act: Act = autofree(Act.new())
	main_act.prologue = func(a) -> Array[Act]: return [prologue_act]
	main_act.add_to_block([prologue_act])
	main_act.init("Main Act")

	main_act.perform()


	# Assertions
	assert_true(prologue_act.get_perform_count() == 1, "prologue_act did not perform exactly once, Perform Count=%d" % [prologue_act.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "main_act did not perform exactly once, Perform Count=%d" % [main_act.get_perform_count()])

	await wait_process_frames(1)
func test_prologue_blocking_main_chain():

	# Prerequisites
	var main_act: Act = autofree(Act.new())


	# Perform Act
	var prologue_act: Act = autofree(Act.new())
	prologue_act.add_to_block([main_act])
	prologue_act.init("Prologue Act")

	main_act.prologue = func(a) -> Array[Act]: return [prologue_act]
	main_act.init("Main Act")
	main_act.perform()


	# Assertions
	assert_true(prologue_act.get_perform_count() == 1, "prologue_act did not perform exactly once, Perform Count=%d" % [prologue_act.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "main_act did not perform exactly once, Perform Count=%d" % [main_act.get_perform_count()])

	await wait_process_frames(1)
func test_main_act_blocking_grandchild_prologue():

	var grandchild_act: Act = autofree(Act.new())
	grandchild_act.init("Grandchild Act")

	var child_act: Act = autofree(Act.new())
	child_act.prologue = func(a) -> Array[Act]: return [grandchild_act]
	child_act.init("Child Act")

	var main_act: Act = autofree(Act.new())
	main_act.prologue = func(a) -> Array[Act]: return [child_act]
	main_act.add_to_block([grandchild_act])
	main_act.init("Main Act")

	main_act.perform()


	# Assertions
	assert_true(grandchild_act.get_perform_count() == 1, "grandchild_act did not perform exactly once, Perform Count=%d" % [grandchild_act.get_perform_count()])
	assert_true(child_act.get_perform_count() == 1, "child_act did not perform exactly once, Perform Count=%d" % [child_act.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "main_act did not perform exactly once, Perform Count=%d" % [main_act.get_perform_count()])

	await wait_process_frames(1)
func test_grandchild_prologue_blocking_main_act():

	# Prerequisites
	var main_act: Act = autofree(Act.new())
	var child_act: Act = autofree(Act.new())
	var grandchild_act: Act = autofree(Act.new())


	main_act.prologue = func(a) -> Array[Act]: return [child_act]
	main_act.init("Main Act")

	child_act.prologue = func(a) -> Array[Act]: return [grandchild_act]
	child_act.init("Child Act")

	grandchild_act.add_to_block([main_act])
	grandchild_act.init("Grandchild Act")

	main_act.perform()


	# Assertions
	assert_true(grandchild_act.get_perform_count() == 1, "grandchild_act did not perform exactly once, Perform Count=%d" % [grandchild_act.get_perform_count()])
	assert_true(child_act.get_perform_count() == 1, "child_act did not perform exactly once, Perform Count=%d" % [child_act.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "main_act did not perform exactly once, Perform Count=%d" % [main_act.get_perform_count()])

	await wait_process_frames(1)
func test_prologues_blocking_siblings():

	# One sibling blocks other
	var sibling_act_b_1: Act = autofree(Act.new())
	sibling_act_b_1.init("Sibling Act B")

	var sibling_act_a_1: Act = autofree(Act.new())
	sibling_act_a_1.add_to_block([sibling_act_b_1])
	sibling_act_a_1.init("Sibling Act A")

	var main_act_1: Act = autofree(Act.new())
	main_act_1.prologue = func(a) -> Array[Act]: return [sibling_act_a_1, sibling_act_b_1]
	main_act_1.init("Main Act")

	main_act_1.perform()


	# Assertions
	assert_true(sibling_act_a_1.get_perform_count() == 1, "sibling_act_a did not perform exactly once, Perform Count=%d" % [sibling_act_a_1.get_perform_count()])
	assert_true(sibling_act_b_1.get_perform_count() == 1, "sibling_act_b did not perform exactly once, Perform Count=%d" % [sibling_act_b_1.get_perform_count()])
	assert_true(main_act_1.get_perform_count() == 1, "main_act did not perform exactly once, Perform Count=%d" % [main_act_1.get_perform_count()])


	# Both siblings blocks each other
	var sibling_act_a_2: Act = autofree(Act.new())
	var sibling_act_b_2: Act = autofree(Act.new())
	sibling_act_b_2.add_to_block([sibling_act_a_2])
	sibling_act_b_2.init("Sibling Act B")

	sibling_act_a_2.add_to_block([sibling_act_b_2])
	sibling_act_a_2.init("Sibling Act A")

	var main_act_2: Act = autofree(Act.new())
	main_act_2.prologue = func(a) -> Array[Act]: return [sibling_act_a_2, sibling_act_b_2]
	main_act_2.init("Main Act")

	main_act_2.perform()


	# Assertions
	assert_true(sibling_act_a_2.get_perform_count() == 1, "sibling_act_a did not perform exactly once (both siblings block each other), Perform Count=%d" % [sibling_act_a_2.get_perform_count()])
	assert_true(sibling_act_b_2.get_perform_count() == 1, "sibling_act_b did not perform exactly once (both siblings block each other), Perform Count=%d" % [sibling_act_b_2.get_perform_count()])
	assert_true(main_act_2.get_perform_count() == 1, "main_act did not perform exactly once, Perform Count=%d" % [main_act_2.get_perform_count()])

	await wait_process_frames(1)
