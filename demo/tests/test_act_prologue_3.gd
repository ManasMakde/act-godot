extends GutTest


# 1. Does prologue chain act_a1 act_a2 act_a3 work?
# 1. Does prologue chain act_a1 act_a2 act_a3 then act_b1 act_b2 act_b3 work?
# 1. Does prologue chain act_a1 act_a2 act_a3 then act_b1 act_b2 act_b3 then act_c1 act_c2 act_c3 work?


func test_prologue_instant_3():

	var execution_order := []
	var act_a1: Act = autofree(Act.new())
	act_a1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a1.init("ActA1")

	var act_a2: Act = autofree(Act.new())
	act_a2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a2.init("ActA2")

	var act_a3: Act = autofree(Act.new())
	act_a3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a3.init("ActA3")

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a) -> Array[Act]: return [act_a1, act_a2, act_a3]
	main_act.init("MainAct")

	main_act.perform()

	assert_true(act_a1.get_perform_count() == 1, "ActA1 did not perform exactly once, Perform Count=%d" % [act_a1.get_perform_count()])
	assert_true(act_a2.get_perform_count() == 1, "ActA2 did not perform exactly once, Perform Count=%d" % [act_a2.get_perform_count()])
	assert_true(act_a3.get_perform_count() == 1, "ActA3 did not perform exactly once, Perform Count=%d" % [act_a3.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "MainAct did not perform exactly once, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("MainAct") > execution_order.find("ActA1"), "MainAct performed before ActA1")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActA2"), "MainAct performed before ActA2")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActA3"), "MainAct performed before ActA3")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a1)
	Utilities.assert_chain_cleared(self, act_a2)
	Utilities.assert_chain_cleared(self, act_a3)
	Utilities.assert_chain_cleared(self, main_act)


	await wait_process_frames(1)
func test_prologue_seq_instant_3():

	var execution_order := []
	var act_a1: Act = autofree(Act.new())
	act_a1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a1.init("ActA1")

	var act_a2: Act = autofree(Act.new())
	act_a2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a2.init("ActA2")

	var act_a3: Act = autofree(Act.new())
	act_a3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a3.init("ActA3")

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a): return Act.seq([[act_a1, act_a2, act_a3]])
	main_act.init("MainAct")

	main_act.perform()

	assert_true(act_a1.get_perform_count() == 1, "ActA1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a1.get_perform_count()])
	assert_true(act_a2.get_perform_count() == 1, "ActA2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a2.get_perform_count()])
	assert_true(act_a3.get_perform_count() == 1, "ActA3 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a3.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "MainAct did not perform exactly once in seq() variation, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("MainAct") > execution_order.find("ActA1"), "MainAct performed before ActA1 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActA2"), "MainAct performed before ActA2 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActA3"), "MainAct performed before ActA3 in seq() variation")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a1, "", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_a2, "", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_a3, "", " in seq() variation")
	Utilities.assert_chain_cleared(self, main_act, "", " in seq() variation")


	await wait_process_frames(1)
func test_prologue_instant_3x3():

	var execution_order := []
	var act_a1: Act = autofree(Act.new())
	act_a1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a1.init("ActA1")

	var act_a2: Act = autofree(Act.new())
	act_a2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a2.init("ActA2")

	var act_a3: Act = autofree(Act.new())
	act_a3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a3.init("ActA3")

	var act_b1: Act = autofree(Act.new())
	act_b1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b1.prologue = func(a) -> Array[Act]: return [act_a1, act_a2, act_a3]
	act_b1.init("ActB1")

	var act_b2: Act = autofree(Act.new())
	act_b2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b2.prologue = func(a) -> Array[Act]: return [act_a1, act_a2, act_a3]
	act_b2.init("ActB2")

	var act_b3: Act = autofree(Act.new())
	act_b3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b3.prologue = func(a) -> Array[Act]: return [act_a1, act_a2, act_a3]
	act_b3.init("ActB3")

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a) -> Array[Act]: return [act_b1, act_b2, act_b3]
	main_act.init("MainAct")

	main_act.perform()

	assert_true(act_a1.get_perform_count() == 3, "Instant: ActA1 did not perform exactly once, Perform Count=%d" % [act_a1.get_perform_count()])
	assert_true(act_a2.get_perform_count() == 3, "Instant: ActA2 did not perform exactly once, Perform Count=%d" % [act_a2.get_perform_count()])
	assert_true(act_a3.get_perform_count() == 3, "Instant: ActA3 did not perform exactly once, Perform Count=%d" % [act_a3.get_perform_count()])
	assert_true(act_b1.get_perform_count() == 1, "Instant: ActB1 did not perform exactly once, Perform Count=%d" % [act_b1.get_perform_count()])
	assert_true(act_b2.get_perform_count() == 1, "Instant: ActB2 did not perform exactly once, Perform Count=%d" % [act_b2.get_perform_count()])
	assert_true(act_b3.get_perform_count() == 1, "Instant: ActB3 did not perform exactly once, Perform Count=%d" % [act_b3.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Instant: MainAct did not perform exactly once, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA1"), "Instant: ActB1 performed before ActA1")
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA2"), "Instant: ActB1 performed before ActA2")
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA3"), "Instant: ActB1 performed before ActA3")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA1"), "Instant: ActB2 performed before ActA1")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA2"), "Instant: ActB2 performed before ActA2")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA3"), "Instant: ActB2 performed before ActA3")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA1"), "Instant: ActB3 performed before ActA1")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA2"), "Instant: ActB3 performed before ActA2")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA3"), "Instant: ActB3 performed before ActA3")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB1"), "Instant: MainAct performed before ActB1")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB2"), "Instant: MainAct performed before ActB2")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB3"), "Instant: MainAct performed before ActB3")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a1, "Instant: ")
	Utilities.assert_chain_cleared(self, act_a2, "Instant: ")
	Utilities.assert_chain_cleared(self, act_a3, "Instant: ")
	Utilities.assert_chain_cleared(self, act_b1, "Instant: ")
	Utilities.assert_chain_cleared(self, act_b2, "Instant: ")
	Utilities.assert_chain_cleared(self, act_b3, "Instant: ")
	Utilities.assert_chain_cleared(self, main_act, "Instant: ")


	await wait_process_frames(1)
func test_prologue_timed_3x3():

	var theater: Theater = add_child_autofree(Theater.new())
	var execution_order := []
	var act_a1: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a1.init("ActA1", theater)

	var act_a2: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a2.init("ActA2", theater)

	var act_a3: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a3.init("ActA3", theater)

	var act_b1: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b1.prologue = func(a) -> Array[Act]: return [act_a1, act_a2, act_a3]
	act_b1.init("ActB1", theater)

	var act_b2: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b2.prologue = func(a) -> Array[Act]: return [act_a1, act_a2, act_a3]
	act_b2.init("ActB2", theater)

	var act_b3: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b3.prologue = func(a) -> Array[Act]: return [act_a1, act_a2, act_a3]
	act_b3.init("ActB3", theater)

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a) -> Array[Act]: return [act_b1, act_b2, act_b3]
	main_act.init("MainAct", theater)

	main_act.perform()

	await wait_process_frames(3)

	assert_true(act_a1.get_perform_count() == 1, "Timed: ActA1 did not perform exactly once, Perform Count=%d" % [act_a1.get_perform_count()])
	assert_true(act_a2.get_perform_count() == 1, "Timed: ActA2 did not perform exactly once, Perform Count=%d" % [act_a2.get_perform_count()])
	assert_true(act_a3.get_perform_count() == 1, "Timed: ActA3 did not perform exactly once, Perform Count=%d" % [act_a3.get_perform_count()])
	assert_true(act_b1.get_perform_count() == 1, "Timed: ActB1 did not perform exactly once, Perform Count=%d" % [act_b1.get_perform_count()])
	assert_true(act_b2.get_perform_count() == 1, "Timed: ActB2 did not perform exactly once, Perform Count=%d" % [act_b2.get_perform_count()])
	assert_true(act_b3.get_perform_count() == 1, "Timed: ActB3 did not perform exactly once, Perform Count=%d" % [act_b3.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Timed: MainAct did not perform exactly once, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA1"), "Timed: ActB1 performed before ActA1")
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA2"), "Timed: ActB1 performed before ActA2")
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA3"), "Timed: ActB1 performed before ActA3")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA1"), "Timed: ActB2 performed before ActA1")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA2"), "Timed: ActB2 performed before ActA2")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA3"), "Timed: ActB2 performed before ActA3")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA1"), "Timed: ActB3 performed before ActA1")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA2"), "Timed: ActB3 performed before ActA2")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA3"), "Timed: ActB3 performed before ActA3")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB1"), "Timed: MainAct performed before ActB1")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB2"), "Timed: MainAct performed before ActB2")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB3"), "Timed: MainAct performed before ActB3")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a1, "Timed: ")
	Utilities.assert_chain_cleared(self, act_a2, "Timed: ")
	Utilities.assert_chain_cleared(self, act_a3, "Timed: ")
	Utilities.assert_chain_cleared(self, act_b1, "Timed: ")
	Utilities.assert_chain_cleared(self, act_b2, "Timed: ")
	Utilities.assert_chain_cleared(self, act_b3, "Timed: ")
	Utilities.assert_chain_cleared(self, main_act, "Timed: ")
func test_prologue_seq_instant_3x3():

	var execution_order := []
	var act_a1: Act = autofree(Act.new())
	act_a1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a1.init("ActA1")

	var act_a2: Act = autofree(Act.new())
	act_a2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a2.init("ActA2")

	var act_a3: Act = autofree(Act.new())
	act_a3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a3.init("ActA3")

	var act_b1: Act = autofree(Act.new())
	act_b1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b1.init("ActB1")

	var act_b2: Act = autofree(Act.new())
	act_b2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b2.init("ActB2")

	var act_b3: Act = autofree(Act.new())
	act_b3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b3.init("ActB3")

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a): return Act.seq([[act_a1, act_a2, act_a3], [act_b1, act_b2, act_b3]])
	main_act.init("MainAct")

	main_act.perform()

	assert_true(act_a1.get_perform_count() == 1, "Instant: ActA1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a1.get_perform_count()])
	assert_true(act_a2.get_perform_count() == 1, "Instant: ActA2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a2.get_perform_count()])
	assert_true(act_a3.get_perform_count() == 1, "Instant: ActA3 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a3.get_perform_count()])
	assert_true(act_b1.get_perform_count() == 1, "Instant: ActB1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b1.get_perform_count()])
	assert_true(act_b2.get_perform_count() == 1, "Instant: ActB2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b2.get_perform_count()])
	assert_true(act_b3.get_perform_count() == 1, "Instant: ActB3 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b3.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Instant: MainAct did not perform exactly once in seq() variation, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA1"), "Instant: ActB1 performed before ActA1 in seq() variation")
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA2"), "Instant: ActB1 performed before ActA2 in seq() variation")
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA3"), "Instant: ActB1 performed before ActA3 in seq() variation")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA1"), "Instant: ActB2 performed before ActA1 in seq() variation")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA2"), "Instant: ActB2 performed before ActA2 in seq() variation")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA3"), "Instant: ActB2 performed before ActA3 in seq() variation")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA1"), "Instant: ActB3 performed before ActA1 in seq() variation")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA2"), "Instant: ActB3 performed before ActA2 in seq() variation")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA3"), "Instant: ActB3 performed before ActA3 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB1"), "Instant: MainAct performed before ActB1 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB2"), "Instant: MainAct performed before ActB2 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB3"), "Instant: MainAct performed before ActB3 in seq() variation")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a1, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_a2, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_a3, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b1, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b2, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b3, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, main_act, "Instant: ", " in seq() variation")


	await wait_process_frames(1)
func test_prologue_seq_timed_3x3():

	var theater: Theater = add_child_autofree(Theater.new())
	var execution_order := []
	var act_a1: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a1.init("ActA1", theater)

	var act_a2: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a2.init("ActA2", theater)

	var act_a3: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a3.init("ActA3", theater)

	var act_b1: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b1.init("ActB1", theater)

	var act_b2: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b2.init("ActB2", theater)

	var act_b3: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b3.init("ActB3", theater)

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a): return Act.seq([[act_a1, act_a2, act_a3], [act_b1, act_b2, act_b3]])
	main_act.init("MainAct", theater)

	main_act.perform()

	await wait_process_frames(3)

	assert_true(act_a1.get_perform_count() == 1, "Timed: ActA1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a1.get_perform_count()])
	assert_true(act_a2.get_perform_count() == 1, "Timed: ActA2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a2.get_perform_count()])
	assert_true(act_a3.get_perform_count() == 1, "Timed: ActA3 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a3.get_perform_count()])
	assert_true(act_b1.get_perform_count() == 1, "Timed: ActB1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b1.get_perform_count()])
	assert_true(act_b2.get_perform_count() == 1, "Timed: ActB2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b2.get_perform_count()])
	assert_true(act_b3.get_perform_count() == 1, "Timed: ActB3 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b3.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Timed: MainAct did not perform exactly once in seq() variation, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA1"), "Timed: ActB1 performed before ActA1 in seq() variation")
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA2"), "Timed: ActB1 performed before ActA2 in seq() variation")
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA3"), "Timed: ActB1 performed before ActA3 in seq() variation")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA1"), "Timed: ActB2 performed before ActA1 in seq() variation")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA2"), "Timed: ActB2 performed before ActA2 in seq() variation")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA3"), "Timed: ActB2 performed before ActA3 in seq() variation")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA1"), "Timed: ActB3 performed before ActA1 in seq() variation")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA2"), "Timed: ActB3 performed before ActA2 in seq() variation")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA3"), "Timed: ActB3 performed before ActA3 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB1"), "Timed: MainAct performed before ActB1 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB2"), "Timed: MainAct performed before ActB2 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB3"), "Timed: MainAct performed before ActB3 in seq() variation")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a1, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_a2, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_a3, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b1, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b2, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b3, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, main_act, "Timed: ", " in seq() variation")
func test_prologue_instant_3x3x3():

	var execution_order := []
	var act_a1: Act = autofree(Act.new())
	act_a1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a1.init("ActA1")

	var act_a2: Act = autofree(Act.new())
	act_a2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a2.init("ActA2")

	var act_a3: Act = autofree(Act.new())
	act_a3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a3.init("ActA3")

	var act_b1: Act = autofree(Act.new())
	act_b1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b1.prologue = func(a) -> Array[Act]: return [act_a1, act_a2, act_a3]
	act_b1.init("ActB1")

	var act_b2: Act = autofree(Act.new())
	act_b2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b2.prologue = func(a) -> Array[Act]: return [act_a1, act_a2, act_a3]
	act_b2.init("ActB2")

	var act_b3: Act = autofree(Act.new())
	act_b3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b3.prologue = func(a) -> Array[Act]: return [act_a1, act_a2, act_a3]
	act_b3.init("ActB3")

	var act_c1: Act = autofree(Act.new())
	act_c1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c1.prologue = func(a) -> Array[Act]: return [act_b1, act_b2, act_b3]
	act_c1.init("ActC1")

	var act_c2: Act = autofree(Act.new())
	act_c2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c2.prologue = func(a) -> Array[Act]: return [act_b1, act_b2, act_b3]
	act_c2.init("ActC2")

	var act_c3: Act = autofree(Act.new())
	act_c3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c3.prologue = func(a) -> Array[Act]: return [act_b1, act_b2, act_b3]
	act_c3.init("ActC3")

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a) -> Array[Act]: return [act_c1, act_c2, act_c3]
	main_act.init("MainAct")

	main_act.perform()

	assert_true(act_a1.get_perform_count() == 9, "Instant: ActA1 did not perform exactly once, Perform Count=%d" % [act_a1.get_perform_count()])
	assert_true(act_a2.get_perform_count() == 9, "Instant: ActA2 did not perform exactly once, Perform Count=%d" % [act_a2.get_perform_count()])
	assert_true(act_a3.get_perform_count() == 9, "Instant: ActA3 did not perform exactly once, Perform Count=%d" % [act_a3.get_perform_count()])
	assert_true(act_b1.get_perform_count() == 3, "Instant: ActB1 did not perform exactly once, Perform Count=%d" % [act_b1.get_perform_count()])
	assert_true(act_b2.get_perform_count() == 3, "Instant: ActB2 did not perform exactly once, Perform Count=%d" % [act_b2.get_perform_count()])
	assert_true(act_b3.get_perform_count() == 3, "Instant: ActB3 did not perform exactly once, Perform Count=%d" % [act_b3.get_perform_count()])
	assert_true(act_c1.get_perform_count() == 1, "Instant: ActC1 did not perform exactly once, Perform Count=%d" % [act_c1.get_perform_count()])
	assert_true(act_c2.get_perform_count() == 1, "Instant: ActC2 did not perform exactly once, Perform Count=%d" % [act_c2.get_perform_count()])
	assert_true(act_c3.get_perform_count() == 1, "Instant: ActC3 did not perform exactly once, Perform Count=%d" % [act_c3.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Instant: MainAct did not perform exactly once, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA1"), "Instant: ActB1 performed before ActA1")
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA2"), "Instant: ActB1 performed before ActA2")
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA3"), "Instant: ActB1 performed before ActA3")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA1"), "Instant: ActB2 performed before ActA1")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA2"), "Instant: ActB2 performed before ActA2")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA3"), "Instant: ActB2 performed before ActA3")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA1"), "Instant: ActB3 performed before ActA1")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA2"), "Instant: ActB3 performed before ActA2")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA3"), "Instant: ActB3 performed before ActA3")
	assert_true(execution_order.find("ActC1") > execution_order.find("ActB1"), "Instant: ActC1 performed before ActB1")
	assert_true(execution_order.find("ActC1") > execution_order.find("ActB2"), "Instant: ActC1 performed before ActB2")
	assert_true(execution_order.find("ActC1") > execution_order.find("ActB3"), "Instant: ActC1 performed before ActB3")
	assert_true(execution_order.find("ActC2") > execution_order.find("ActB1"), "Instant: ActC2 performed before ActB1")
	assert_true(execution_order.find("ActC2") > execution_order.find("ActB2"), "Instant: ActC2 performed before ActB2")
	assert_true(execution_order.find("ActC2") > execution_order.find("ActB3"), "Instant: ActC2 performed before ActB3")
	assert_true(execution_order.find("ActC3") > execution_order.find("ActB1"), "Instant: ActC3 performed before ActB1")
	assert_true(execution_order.find("ActC3") > execution_order.find("ActB2"), "Instant: ActC3 performed before ActB2")
	assert_true(execution_order.find("ActC3") > execution_order.find("ActB3"), "Instant: ActC3 performed before ActB3")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC1"), "Instant: MainAct performed before ActC1")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC2"), "Instant: MainAct performed before ActC2")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC3"), "Instant: MainAct performed before ActC3")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a1, "Instant: ")
	Utilities.assert_chain_cleared(self, act_a2, "Instant: ")
	Utilities.assert_chain_cleared(self, act_a3, "Instant: ")
	Utilities.assert_chain_cleared(self, act_b1, "Instant: ")
	Utilities.assert_chain_cleared(self, act_b2, "Instant: ")
	Utilities.assert_chain_cleared(self, act_b3, "Instant: ")
	Utilities.assert_chain_cleared(self, act_c1, "Instant: ")
	Utilities.assert_chain_cleared(self, act_c2, "Instant: ")
	Utilities.assert_chain_cleared(self, act_c3, "Instant: ")
	Utilities.assert_chain_cleared(self, main_act, "Instant: ")


	await wait_process_frames(1)
func test_prologue_timed_3x3x3():

	var theater: Theater = add_child_autofree(Theater.new())
	var execution_order := []
	var act_a1: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a1.init("ActA1", theater)

	var act_a2: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a2.init("ActA2", theater)

	var act_a3: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a3.init("ActA3", theater)

	var act_b1: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b1.prologue = func(a) -> Array[Act]: return [act_a1, act_a2, act_a3]
	act_b1.init("ActB1", theater)

	var act_b2: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b2.prologue = func(a) -> Array[Act]: return [act_a1, act_a2, act_a3]
	act_b2.init("ActB2", theater)

	var act_b3: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b3.prologue = func(a) -> Array[Act]: return [act_a1, act_a2, act_a3]
	act_b3.init("ActB3", theater)

	var act_c1: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_c1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c1.prologue = func(a) -> Array[Act]: return [act_b1, act_b2, act_b3]
	act_c1.init("ActC1", theater)

	var act_c2: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_c2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c2.prologue = func(a) -> Array[Act]: return [act_b1, act_b2, act_b3]
	act_c2.init("ActC2", theater)

	var act_c3: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_c3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c3.prologue = func(a) -> Array[Act]: return [act_b1, act_b2, act_b3]
	act_c3.init("ActC3", theater)

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a) -> Array[Act]: return [act_c1, act_c2, act_c3]
	main_act.init("MainAct", theater)

	main_act.perform()

	await wait_process_frames(4)

	assert_true(act_a1.get_perform_count() == 1, "Timed: ActA1 did not perform exactly once, Perform Count=%d" % [act_a1.get_perform_count()])
	assert_true(act_a2.get_perform_count() == 1, "Timed: ActA2 did not perform exactly once, Perform Count=%d" % [act_a2.get_perform_count()])
	assert_true(act_a3.get_perform_count() == 1, "Timed: ActA3 did not perform exactly once, Perform Count=%d" % [act_a3.get_perform_count()])
	assert_true(act_b1.get_perform_count() == 1, "Timed: ActB1 did not perform exactly once, Perform Count=%d" % [act_b1.get_perform_count()])
	assert_true(act_b2.get_perform_count() == 1, "Timed: ActB2 did not perform exactly once, Perform Count=%d" % [act_b2.get_perform_count()])
	assert_true(act_b3.get_perform_count() == 1, "Timed: ActB3 did not perform exactly once, Perform Count=%d" % [act_b3.get_perform_count()])
	assert_true(act_c1.get_perform_count() == 1, "Timed: ActC1 did not perform exactly once, Perform Count=%d" % [act_c1.get_perform_count()])
	assert_true(act_c2.get_perform_count() == 1, "Timed: ActC2 did not perform exactly once, Perform Count=%d" % [act_c2.get_perform_count()])
	assert_true(act_c3.get_perform_count() == 1, "Timed: ActC3 did not perform exactly once, Perform Count=%d" % [act_c3.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Timed: MainAct did not perform exactly once, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA1"), "Timed: ActB1 performed before ActA1")
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA2"), "Timed: ActB1 performed before ActA2")
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA3"), "Timed: ActB1 performed before ActA3")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA1"), "Timed: ActB2 performed before ActA1")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA2"), "Timed: ActB2 performed before ActA2")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA3"), "Timed: ActB2 performed before ActA3")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA1"), "Timed: ActB3 performed before ActA1")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA2"), "Timed: ActB3 performed before ActA2")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA3"), "Timed: ActB3 performed before ActA3")
	assert_true(execution_order.find("ActC1") > execution_order.find("ActB1"), "Timed: ActC1 performed before ActB1")
	assert_true(execution_order.find("ActC1") > execution_order.find("ActB2"), "Timed: ActC1 performed before ActB2")
	assert_true(execution_order.find("ActC1") > execution_order.find("ActB3"), "Timed: ActC1 performed before ActB3")
	assert_true(execution_order.find("ActC2") > execution_order.find("ActB1"), "Timed: ActC2 performed before ActB1")
	assert_true(execution_order.find("ActC2") > execution_order.find("ActB2"), "Timed: ActC2 performed before ActB2")
	assert_true(execution_order.find("ActC2") > execution_order.find("ActB3"), "Timed: ActC2 performed before ActB3")
	assert_true(execution_order.find("ActC3") > execution_order.find("ActB1"), "Timed: ActC3 performed before ActB1")
	assert_true(execution_order.find("ActC3") > execution_order.find("ActB2"), "Timed: ActC3 performed before ActB2")
	assert_true(execution_order.find("ActC3") > execution_order.find("ActB3"), "Timed: ActC3 performed before ActB3")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC1"), "Timed: MainAct performed before ActC1")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC2"), "Timed: MainAct performed before ActC2")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC3"), "Timed: MainAct performed before ActC3")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a1, "Timed: ")
	Utilities.assert_chain_cleared(self, act_a2, "Timed: ")
	Utilities.assert_chain_cleared(self, act_a3, "Timed: ")
	Utilities.assert_chain_cleared(self, act_b1, "Timed: ")
	Utilities.assert_chain_cleared(self, act_b2, "Timed: ")
	Utilities.assert_chain_cleared(self, act_b3, "Timed: ")
	Utilities.assert_chain_cleared(self, act_c1, "Timed: ")
	Utilities.assert_chain_cleared(self, act_c2, "Timed: ")
	Utilities.assert_chain_cleared(self, act_c3, "Timed: ")
	Utilities.assert_chain_cleared(self, main_act, "Timed: ")
func test_prologue_seq_instant_3x3x3():

	var execution_order := []
	var act_a1: Act = autofree(Act.new())
	act_a1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a1.init("ActA1")

	var act_a2: Act = autofree(Act.new())
	act_a2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a2.init("ActA2")

	var act_a3: Act = autofree(Act.new())
	act_a3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a3.init("ActA3")

	var act_b1: Act = autofree(Act.new())
	act_b1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b1.init("ActB1")

	var act_b2: Act = autofree(Act.new())
	act_b2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b2.init("ActB2")

	var act_b3: Act = autofree(Act.new())
	act_b3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b3.init("ActB3")

	var act_c1: Act = autofree(Act.new())
	act_c1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c1.init("ActC1")

	var act_c2: Act = autofree(Act.new())
	act_c2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c2.init("ActC2")

	var act_c3: Act = autofree(Act.new())
	act_c3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c3.init("ActC3")

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a): return Act.seq([[act_a1, act_a2, act_a3], [act_b1, act_b2, act_b3], [act_c1, act_c2, act_c3]])
	main_act.init("MainAct")

	main_act.perform()

	assert_true(act_a1.get_perform_count() == 1, "Instant: ActA1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a1.get_perform_count()])
	assert_true(act_a2.get_perform_count() == 1, "Instant: ActA2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a2.get_perform_count()])
	assert_true(act_a3.get_perform_count() == 1, "Instant: ActA3 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a3.get_perform_count()])
	assert_true(act_b1.get_perform_count() == 1, "Instant: ActB1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b1.get_perform_count()])
	assert_true(act_b2.get_perform_count() == 1, "Instant: ActB2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b2.get_perform_count()])
	assert_true(act_b3.get_perform_count() == 1, "Instant: ActB3 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b3.get_perform_count()])
	assert_true(act_c1.get_perform_count() == 1, "Instant: ActC1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_c1.get_perform_count()])
	assert_true(act_c2.get_perform_count() == 1, "Instant: ActC2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_c2.get_perform_count()])
	assert_true(act_c3.get_perform_count() == 1, "Instant: ActC3 did not perform exactly once in seq() variation, Perform Count=%d" % [act_c3.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Instant: MainAct did not perform exactly once in seq() variation, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA1"), "Instant: ActB1 performed before ActA1 in seq() variation")
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA2"), "Instant: ActB1 performed before ActA2 in seq() variation")
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA3"), "Instant: ActB1 performed before ActA3 in seq() variation")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA1"), "Instant: ActB2 performed before ActA1 in seq() variation")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA2"), "Instant: ActB2 performed before ActA2 in seq() variation")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA3"), "Instant: ActB2 performed before ActA3 in seq() variation")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA1"), "Instant: ActB3 performed before ActA1 in seq() variation")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA2"), "Instant: ActB3 performed before ActA2 in seq() variation")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA3"), "Instant: ActB3 performed before ActA3 in seq() variation")
	assert_true(execution_order.find("ActC1") > execution_order.find("ActB1"), "Instant: ActC1 performed before ActB1 in seq() variation")
	assert_true(execution_order.find("ActC1") > execution_order.find("ActB2"), "Instant: ActC1 performed before ActB2 in seq() variation")
	assert_true(execution_order.find("ActC1") > execution_order.find("ActB3"), "Instant: ActC1 performed before ActB3 in seq() variation")
	assert_true(execution_order.find("ActC2") > execution_order.find("ActB1"), "Instant: ActC2 performed before ActB1 in seq() variation")
	assert_true(execution_order.find("ActC2") > execution_order.find("ActB2"), "Instant: ActC2 performed before ActB2 in seq() variation")
	assert_true(execution_order.find("ActC2") > execution_order.find("ActB3"), "Instant: ActC2 performed before ActB3 in seq() variation")
	assert_true(execution_order.find("ActC3") > execution_order.find("ActB1"), "Instant: ActC3 performed before ActB1 in seq() variation")
	assert_true(execution_order.find("ActC3") > execution_order.find("ActB2"), "Instant: ActC3 performed before ActB2 in seq() variation")
	assert_true(execution_order.find("ActC3") > execution_order.find("ActB3"), "Instant: ActC3 performed before ActB3 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC1"), "Instant: MainAct performed before ActC1 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC2"), "Instant: MainAct performed before ActC2 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC3"), "Instant: MainAct performed before ActC3 in seq() variation")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a1, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_a2, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_a3, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b1, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b2, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b3, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_c1, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_c2, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_c3, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, main_act, "Instant: ", " in seq() variation")


	await wait_process_frames(1)
func test_prologue_seq_timed_3x3x3():

	var theater: Theater = add_child_autofree(Theater.new())
	var execution_order := []
	var act_a1: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a1.init("ActA1", theater)

	var act_a2: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a2.init("ActA2", theater)

	var act_a3: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a3.init("ActA3", theater)

	var act_b1: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b1.init("ActB1", theater)

	var act_b2: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b2.init("ActB2", theater)

	var act_b3: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b3.init("ActB3", theater)

	var act_c1: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_c1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c1.init("ActC1", theater)

	var act_c2: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_c2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c2.init("ActC2", theater)

	var act_c3: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_c3.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c3.init("ActC3", theater)

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a): return Act.seq([[act_a1, act_a2, act_a3], [act_b1, act_b2, act_b3], [act_c1, act_c2, act_c3]])
	main_act.init("MainAct", theater)

	main_act.perform()

	await wait_process_frames(4)

	assert_true(act_a1.get_perform_count() == 1, "Timed: ActA1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a1.get_perform_count()])
	assert_true(act_a2.get_perform_count() == 1, "Timed: ActA2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a2.get_perform_count()])
	assert_true(act_a3.get_perform_count() == 1, "Timed: ActA3 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a3.get_perform_count()])
	assert_true(act_b1.get_perform_count() == 1, "Timed: ActB1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b1.get_perform_count()])
	assert_true(act_b2.get_perform_count() == 1, "Timed: ActB2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b2.get_perform_count()])
	assert_true(act_b3.get_perform_count() == 1, "Timed: ActB3 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b3.get_perform_count()])
	assert_true(act_c1.get_perform_count() == 1, "Timed: ActC1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_c1.get_perform_count()])
	assert_true(act_c2.get_perform_count() == 1, "Timed: ActC2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_c2.get_perform_count()])
	assert_true(act_c3.get_perform_count() == 1, "Timed: ActC3 did not perform exactly once in seq() variation, Perform Count=%d" % [act_c3.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Timed: MainAct did not perform exactly once in seq() variation, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA1"), "Timed: ActB1 performed before ActA1 in seq() variation")
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA2"), "Timed: ActB1 performed before ActA2 in seq() variation")
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA3"), "Timed: ActB1 performed before ActA3 in seq() variation")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA1"), "Timed: ActB2 performed before ActA1 in seq() variation")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA2"), "Timed: ActB2 performed before ActA2 in seq() variation")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA3"), "Timed: ActB2 performed before ActA3 in seq() variation")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA1"), "Timed: ActB3 performed before ActA1 in seq() variation")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA2"), "Timed: ActB3 performed before ActA2 in seq() variation")
	assert_true(execution_order.find("ActB3") > execution_order.find("ActA3"), "Timed: ActB3 performed before ActA3 in seq() variation")
	assert_true(execution_order.find("ActC1") > execution_order.find("ActB1"), "Timed: ActC1 performed before ActB1 in seq() variation")
	assert_true(execution_order.find("ActC1") > execution_order.find("ActB2"), "Timed: ActC1 performed before ActB2 in seq() variation")
	assert_true(execution_order.find("ActC1") > execution_order.find("ActB3"), "Timed: ActC1 performed before ActB3 in seq() variation")
	assert_true(execution_order.find("ActC2") > execution_order.find("ActB1"), "Timed: ActC2 performed before ActB1 in seq() variation")
	assert_true(execution_order.find("ActC2") > execution_order.find("ActB2"), "Timed: ActC2 performed before ActB2 in seq() variation")
	assert_true(execution_order.find("ActC2") > execution_order.find("ActB3"), "Timed: ActC2 performed before ActB3 in seq() variation")
	assert_true(execution_order.find("ActC3") > execution_order.find("ActB1"), "Timed: ActC3 performed before ActB1 in seq() variation")
	assert_true(execution_order.find("ActC3") > execution_order.find("ActB2"), "Timed: ActC3 performed before ActB2 in seq() variation")
	assert_true(execution_order.find("ActC3") > execution_order.find("ActB3"), "Timed: ActC3 performed before ActB3 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC1"), "Timed: MainAct performed before ActC1 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC2"), "Timed: MainAct performed before ActC2 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC3"), "Timed: MainAct performed before ActC3 in seq() variation")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a1, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_a2, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_a3, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b1, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b2, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b3, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_c1, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_c2, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_c3, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, main_act, "Timed: ", " in seq() variation")
