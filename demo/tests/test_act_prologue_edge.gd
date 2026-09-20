extends GutTest


# 1. Does prologue chain act_a then act_b1 act_b2 work?
# 1. Does prologue chain act_a then act_b1 act_b2 then act_c work?
# 1. Does prologue chain act_a1 act_a2 then act_b then act_c1 act_c2 work?


func test_prologue_instant_1x2():

	var execution_order := []
	var act_a: Act = autofree(Act.new())
	act_a.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a.init("ActA")

	var act_b1: Act = autofree(Act.new())
	act_b1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b1.prologue = func(a) -> Array[Act]: return [act_a]
	act_b1.init("ActB1")

	var act_b2: Act = autofree(Act.new())
	act_b2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b2.init("ActB2")

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a) -> Array[Act]: return [act_b1, act_b2]
	main_act.init("MainAct")

	main_act.perform()

	assert_true(act_a.get_perform_count() == 1, "Instant: ActA did not perform exactly once, Perform Count=%d" % [act_a.get_perform_count()])
	assert_true(act_b1.get_perform_count() == 1, "Instant: ActB1 did not perform exactly once, Perform Count=%d" % [act_b1.get_perform_count()])
	assert_true(act_b2.get_perform_count() == 1, "Instant: ActB2 did not perform exactly once, Perform Count=%d" % [act_b2.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Instant: MainAct did not perform exactly once, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA"), "Instant: ActB1 performed before ActA")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA"), "Instant: ActB2 performed before ActA")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB1"), "Instant: MainAct performed before ActB1")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB2"), "Instant: MainAct performed before ActB2")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a, "Instant: ")
	Utilities.assert_chain_cleared(self, act_b1, "Instant: ")
	Utilities.assert_chain_cleared(self, act_b2, "Instant: ")
	Utilities.assert_chain_cleared(self, main_act, "Instant: ")


	await wait_process_frames(1)
func test_prologue_timed_1x2():

	var theater: Theater = add_child_autofree(Theater.new())
	var execution_order := []
	var act_a: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a.init("ActA", theater)

	var act_b1: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b1.prologue = func(a) -> Array[Act]: return [act_a]
	act_b1.init("ActB1", theater)

	var act_b2: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b2.init("ActB2", theater)

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a) -> Array[Act]: return [act_b1, act_b2]
	main_act.init("MainAct", theater)

	main_act.perform()

	await wait_process_frames(3)

	assert_true(act_a.get_perform_count() == 1, "Timed: ActA did not perform exactly once, Perform Count=%d" % [act_a.get_perform_count()])
	assert_true(act_b1.get_perform_count() == 1, "Timed: ActB1 did not perform exactly once, Perform Count=%d" % [act_b1.get_perform_count()])
	assert_true(act_b2.get_perform_count() == 1, "Timed: ActB2 did not perform exactly once, Perform Count=%d" % [act_b2.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Timed: MainAct did not perform exactly once, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA"), "Timed: ActB1 performed before ActA")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA"), "Timed: ActB2 performed before ActA")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB1"), "Timed: MainAct performed before ActB1")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB2"), "Timed: MainAct performed before ActB2")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a, "Timed: ")
	Utilities.assert_chain_cleared(self, act_b1, "Timed: ")
	Utilities.assert_chain_cleared(self, act_b2, "Timed: ")
	Utilities.assert_chain_cleared(self, main_act, "Timed: ")
func test_prologue_seq_instant_1x2():

	var execution_order := []
	var act_a: Act = autofree(Act.new())
	act_a.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a.init("ActA")

	var act_b1: Act = autofree(Act.new())
	act_b1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b1.init("ActB1")

	var act_b2: Act = autofree(Act.new())
	act_b2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b2.init("ActB2")

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a): return Act.seq([[act_a], [act_b1, act_b2]])
	main_act.init("MainAct")

	main_act.perform()

	assert_true(act_a.get_perform_count() == 1, "Instant: ActA did not perform exactly once in seq() variation, Perform Count=%d" % [act_a.get_perform_count()])
	assert_true(act_b1.get_perform_count() == 1, "Instant: ActB1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b1.get_perform_count()])
	assert_true(act_b2.get_perform_count() == 1, "Instant: ActB2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b2.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Instant: MainAct did not perform exactly once in seq() variation, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA"), "Instant: ActB1 performed before ActA in seq() variation")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA"), "Instant: ActB2 performed before ActA in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB1"), "Instant: MainAct performed before ActB1 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB2"), "Instant: MainAct performed before ActB2 in seq() variation")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b1, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b2, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, main_act, "Instant: ", " in seq() variation")


	await wait_process_frames(1)
func test_prologue_seq_timed_1x2():

	var theater: Theater = add_child_autofree(Theater.new())
	var execution_order := []
	var act_a: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a.init("ActA", theater)

	var act_b1: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b1.init("ActB1", theater)

	var act_b2: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b2.init("ActB2", theater)

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a): return Act.seq([[act_a], [act_b1, act_b2]])
	main_act.init("MainAct", theater)

	main_act.perform()

	await wait_process_frames(3)

	assert_true(act_a.get_perform_count() == 1, "Timed: ActA did not perform exactly once in seq() variation, Perform Count=%d" % [act_a.get_perform_count()])
	assert_true(act_b1.get_perform_count() == 1, "Timed: ActB1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b1.get_perform_count()])
	assert_true(act_b2.get_perform_count() == 1, "Timed: ActB2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b2.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Timed: MainAct did not perform exactly once in seq() variation, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA"), "Timed: ActB1 performed before ActA in seq() variation")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA"), "Timed: ActB2 performed before ActA in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB1"), "Timed: MainAct performed before ActB1 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActB2"), "Timed: MainAct performed before ActB2 in seq() variation")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b1, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b2, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, main_act, "Timed: ", " in seq() variation")
func test_prologue_instant_1x2x1():

	var execution_order := []
	var act_a: Act = autofree(Act.new())
	act_a.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a.init("ActA")

	var act_b1: Act = autofree(Act.new())
	act_b1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b1.prologue = func(a) -> Array[Act]: return [act_a]
	act_b1.init("ActB1")

	var act_b2: Act = autofree(Act.new())
	act_b2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b2.prologue = func(a) -> Array[Act]: return [act_a]
	act_b2.init("ActB2")

	var act_c: Act = autofree(Act.new())
	act_c.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c.prologue = func(a) -> Array[Act]: return [act_b1, act_b2]
	act_c.init("ActC")

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a) -> Array[Act]: return [act_c]
	main_act.init("MainAct")

	main_act.perform()

	assert_true(act_a.get_perform_count() == 2, "Instant: ActA did not perform exactly once, Perform Count=%d" % [act_a.get_perform_count()])
	assert_true(act_b1.get_perform_count() == 1, "Instant: ActB1 did not perform exactly once, Perform Count=%d" % [act_b1.get_perform_count()])
	assert_true(act_b2.get_perform_count() == 1, "Instant: ActB2 did not perform exactly once, Perform Count=%d" % [act_b2.get_perform_count()])
	assert_true(act_c.get_perform_count() == 1, "Instant: ActC did not perform exactly once, Perform Count=%d" % [act_c.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Instant: MainAct did not perform exactly once, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA"), "Instant: ActB1 performed before ActA")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA"), "Instant: ActB2 performed before ActA")
	assert_true(execution_order.find("ActC") > execution_order.find("ActB1"), "Instant: ActC performed before ActB1")
	assert_true(execution_order.find("ActC") > execution_order.find("ActB2"), "Instant: ActC performed before ActB2")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC"), "Instant: MainAct performed before ActC")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a, "Instant: ")
	Utilities.assert_chain_cleared(self, act_b1, "Instant: ")
	Utilities.assert_chain_cleared(self, act_b2, "Instant: ")
	Utilities.assert_chain_cleared(self, act_c, "Instant: ")
	Utilities.assert_chain_cleared(self, main_act, "Instant: ")


	await wait_process_frames(1)
func test_prologue_timed_1x2x1():

	var theater: Theater = add_child_autofree(Theater.new())
	var execution_order := []
	var act_a: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a.init("ActA", theater)

	var act_b1: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b1.prologue = func(a) -> Array[Act]: return [act_a]
	act_b1.init("ActB1", theater)

	var act_b2: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b2.prologue = func(a) -> Array[Act]: return [act_a]
	act_b2.init("ActB2", theater)

	var act_c: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_c.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c.prologue = func(a) -> Array[Act]: return [act_b1, act_b2]
	act_c.init("ActC", theater)

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a) -> Array[Act]: return [act_c]
	main_act.init("MainAct", theater)

	main_act.perform()

	await wait_process_frames(4)

	assert_true(act_a.get_perform_count() == 1, "Timed: ActA did not perform exactly once, Perform Count=%d" % [act_a.get_perform_count()])
	assert_true(act_b1.get_perform_count() == 1, "Timed: ActB1 did not perform exactly once, Perform Count=%d" % [act_b1.get_perform_count()])
	assert_true(act_b2.get_perform_count() == 1, "Timed: ActB2 did not perform exactly once, Perform Count=%d" % [act_b2.get_perform_count()])
	assert_true(act_c.get_perform_count() == 1, "Timed: ActC did not perform exactly once, Perform Count=%d" % [act_c.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Timed: MainAct did not perform exactly once, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA"), "Timed: ActB1 performed before ActA")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA"), "Timed: ActB2 performed before ActA")
	assert_true(execution_order.find("ActC") > execution_order.find("ActB1"), "Timed: ActC performed before ActB1")
	assert_true(execution_order.find("ActC") > execution_order.find("ActB2"), "Timed: ActC performed before ActB2")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC"), "Timed: MainAct performed before ActC")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a, "Timed: ")
	Utilities.assert_chain_cleared(self, act_b1, "Timed: ")
	Utilities.assert_chain_cleared(self, act_b2, "Timed: ")
	Utilities.assert_chain_cleared(self, act_c, "Timed: ")
	Utilities.assert_chain_cleared(self, main_act, "Timed: ")
func test_prologue_seq_instant_1x2x1():

	var execution_order := []
	var act_a: Act = autofree(Act.new())
	act_a.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a.init("ActA")

	var act_b1: Act = autofree(Act.new())
	act_b1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b1.init("ActB1")

	var act_b2: Act = autofree(Act.new())
	act_b2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b2.init("ActB2")

	var act_c: Act = autofree(Act.new())
	act_c.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c.init("ActC")

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a): return Act.seq([[act_a], [act_b1, act_b2], [act_c]])
	main_act.init("MainAct")

	main_act.perform()

	assert_true(act_a.get_perform_count() == 1, "Instant: ActA did not perform exactly once in seq() variation, Perform Count=%d" % [act_a.get_perform_count()])
	assert_true(act_b1.get_perform_count() == 1, "Instant: ActB1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b1.get_perform_count()])
	assert_true(act_b2.get_perform_count() == 1, "Instant: ActB2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b2.get_perform_count()])
	assert_true(act_c.get_perform_count() == 1, "Instant: ActC did not perform exactly once in seq() variation, Perform Count=%d" % [act_c.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Instant: MainAct did not perform exactly once in seq() variation, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA"), "Instant: ActB1 performed before ActA in seq() variation")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA"), "Instant: ActB2 performed before ActA in seq() variation")
	assert_true(execution_order.find("ActC") > execution_order.find("ActB1"), "Instant: ActC performed before ActB1 in seq() variation")
	assert_true(execution_order.find("ActC") > execution_order.find("ActB2"), "Instant: ActC performed before ActB2 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC"), "Instant: MainAct performed before ActC in seq() variation")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b1, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b2, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_c, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, main_act, "Instant: ", " in seq() variation")


	await wait_process_frames(1)
func test_prologue_seq_timed_1x2x1():

	var theater: Theater = add_child_autofree(Theater.new())
	var execution_order := []
	var act_a: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a.init("ActA", theater)

	var act_b1: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b1.init("ActB1", theater)

	var act_b2: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b2.init("ActB2", theater)

	var act_c: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_c.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c.init("ActC", theater)

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a): return Act.seq([[act_a], [act_b1, act_b2], [act_c]])
	main_act.init("MainAct", theater)

	main_act.perform()

	await wait_process_frames(4)

	assert_true(act_a.get_perform_count() == 1, "Timed: ActA did not perform exactly once in seq() variation, Perform Count=%d" % [act_a.get_perform_count()])
	assert_true(act_b1.get_perform_count() == 1, "Timed: ActB1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b1.get_perform_count()])
	assert_true(act_b2.get_perform_count() == 1, "Timed: ActB2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_b2.get_perform_count()])
	assert_true(act_c.get_perform_count() == 1, "Timed: ActC did not perform exactly once in seq() variation, Perform Count=%d" % [act_c.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Timed: MainAct did not perform exactly once in seq() variation, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB1") > execution_order.find("ActA"), "Timed: ActB1 performed before ActA in seq() variation")
	assert_true(execution_order.find("ActB2") > execution_order.find("ActA"), "Timed: ActB2 performed before ActA in seq() variation")
	assert_true(execution_order.find("ActC") > execution_order.find("ActB1"), "Timed: ActC performed before ActB1 in seq() variation")
	assert_true(execution_order.find("ActC") > execution_order.find("ActB2"), "Timed: ActC performed before ActB2 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC"), "Timed: MainAct performed before ActC in seq() variation")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b1, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b2, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_c, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, main_act, "Timed: ", " in seq() variation")
func test_prologue_instant_2x1x2():

	var execution_order := []
	var act_a1: Act = autofree(Act.new())
	act_a1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a1.init("ActA1")

	var act_a2: Act = autofree(Act.new())
	act_a2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a2.init("ActA2")

	var act_b: Act = autofree(Act.new())
	act_b.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b.prologue = func(a) -> Array[Act]: return [act_a1, act_a2]
	act_b.init("ActB")

	var act_c1: Act = autofree(Act.new())
	act_c1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c1.prologue = func(a) -> Array[Act]: return [act_b]
	act_c1.init("ActC1")

	var act_c2: Act = autofree(Act.new())
	act_c2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c2.prologue = func(a) -> Array[Act]: return [act_b]
	act_c2.init("ActC2")

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a) -> Array[Act]: return [act_c1, act_c2]
	main_act.init("MainAct")

	main_act.perform()

	assert_true(act_a1.get_perform_count() == 2, "Instant: ActA1 did not perform exactly once, Perform Count=%d" % [act_a1.get_perform_count()])
	assert_true(act_a2.get_perform_count() == 2, "Instant: ActA2 did not perform exactly once, Perform Count=%d" % [act_a2.get_perform_count()])
	assert_true(act_b.get_perform_count() == 2, "Instant: ActB did not perform exactly once, Perform Count=%d" % [act_b.get_perform_count()])
	assert_true(act_c1.get_perform_count() == 1, "Instant: ActC1 did not perform exactly once, Perform Count=%d" % [act_c1.get_perform_count()])
	assert_true(act_c2.get_perform_count() == 1, "Instant: ActC2 did not perform exactly once, Perform Count=%d" % [act_c2.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Instant: MainAct did not perform exactly once, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB") > execution_order.find("ActA1"), "Instant: ActB performed before ActA1")
	assert_true(execution_order.find("ActB") > execution_order.find("ActA2"), "Instant: ActB performed before ActA2")
	assert_true(execution_order.find("ActC1") > execution_order.find("ActB"), "Instant: ActC1 performed before ActB")
	assert_true(execution_order.find("ActC2") > execution_order.find("ActB"), "Instant: ActC2 performed before ActB")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC1"), "Instant: MainAct performed before ActC1")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC2"), "Instant: MainAct performed before ActC2")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a1, "Instant: ")
	Utilities.assert_chain_cleared(self, act_a2, "Instant: ")
	Utilities.assert_chain_cleared(self, act_b, "Instant: ")
	Utilities.assert_chain_cleared(self, act_c1, "Instant: ")
	Utilities.assert_chain_cleared(self, act_c2, "Instant: ")
	Utilities.assert_chain_cleared(self, main_act, "Instant: ")


	await wait_process_frames(1)
func test_prologue_timed_2x1x2():

	var theater: Theater = add_child_autofree(Theater.new())
	var execution_order := []
	var act_a1: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a1.init("ActA1", theater)

	var act_a2: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a2.init("ActA2", theater)

	var act_b: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b.prologue = func(a) -> Array[Act]: return [act_a1, act_a2]
	act_b.init("ActB", theater)

	var act_c1: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_c1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c1.prologue = func(a) -> Array[Act]: return [act_b]
	act_c1.init("ActC1", theater)

	var act_c2: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_c2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c2.prologue = func(a) -> Array[Act]: return [act_b]
	act_c2.init("ActC2", theater)

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a) -> Array[Act]: return [act_c1, act_c2]
	main_act.init("MainAct", theater)

	main_act.perform()

	await wait_process_frames(4)

	assert_true(act_a1.get_perform_count() == 1, "Timed: ActA1 did not perform exactly once, Perform Count=%d" % [act_a1.get_perform_count()])
	assert_true(act_a2.get_perform_count() == 1, "Timed: ActA2 did not perform exactly once, Perform Count=%d" % [act_a2.get_perform_count()])
	assert_true(act_b.get_perform_count() == 1, "Timed: ActB did not perform exactly once, Perform Count=%d" % [act_b.get_perform_count()])
	assert_true(act_c1.get_perform_count() == 1, "Timed: ActC1 did not perform exactly once, Perform Count=%d" % [act_c1.get_perform_count()])
	assert_true(act_c2.get_perform_count() == 1, "Timed: ActC2 did not perform exactly once, Perform Count=%d" % [act_c2.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Timed: MainAct did not perform exactly once, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB") > execution_order.find("ActA1"), "Timed: ActB performed before ActA1")
	assert_true(execution_order.find("ActB") > execution_order.find("ActA2"), "Timed: ActB performed before ActA2")
	assert_true(execution_order.find("ActC1") > execution_order.find("ActB"), "Timed: ActC1 performed before ActB")
	assert_true(execution_order.find("ActC2") > execution_order.find("ActB"), "Timed: ActC2 performed before ActB")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC1"), "Timed: MainAct performed before ActC1")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC2"), "Timed: MainAct performed before ActC2")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a1, "Timed: ")
	Utilities.assert_chain_cleared(self, act_a2, "Timed: ")
	Utilities.assert_chain_cleared(self, act_b, "Timed: ")
	Utilities.assert_chain_cleared(self, act_c1, "Timed: ")
	Utilities.assert_chain_cleared(self, act_c2, "Timed: ")
	Utilities.assert_chain_cleared(self, main_act, "Timed: ")
func test_prologue_seq_instant_2x1x2():

	var execution_order := []
	var act_a1: Act = autofree(Act.new())
	act_a1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a1.init("ActA1")

	var act_a2: Act = autofree(Act.new())
	act_a2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a2.init("ActA2")

	var act_b: Act = autofree(Act.new())
	act_b.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b.init("ActB")

	var act_c1: Act = autofree(Act.new())
	act_c1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c1.init("ActC1")

	var act_c2: Act = autofree(Act.new())
	act_c2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c2.init("ActC2")

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a): return Act.seq([[act_a1, act_a2], [act_b], [act_c1, act_c2]])
	main_act.init("MainAct")

	main_act.perform()

	assert_true(act_a1.get_perform_count() == 1, "Instant: ActA1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a1.get_perform_count()])
	assert_true(act_a2.get_perform_count() == 1, "Instant: ActA2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a2.get_perform_count()])
	assert_true(act_b.get_perform_count() == 1, "Instant: ActB did not perform exactly once in seq() variation, Perform Count=%d" % [act_b.get_perform_count()])
	assert_true(act_c1.get_perform_count() == 1, "Instant: ActC1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_c1.get_perform_count()])
	assert_true(act_c2.get_perform_count() == 1, "Instant: ActC2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_c2.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Instant: MainAct did not perform exactly once in seq() variation, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB") > execution_order.find("ActA1"), "Instant: ActB performed before ActA1 in seq() variation")
	assert_true(execution_order.find("ActB") > execution_order.find("ActA2"), "Instant: ActB performed before ActA2 in seq() variation")
	assert_true(execution_order.find("ActC1") > execution_order.find("ActB"), "Instant: ActC1 performed before ActB in seq() variation")
	assert_true(execution_order.find("ActC2") > execution_order.find("ActB"), "Instant: ActC2 performed before ActB in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC1"), "Instant: MainAct performed before ActC1 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC2"), "Instant: MainAct performed before ActC2 in seq() variation")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a1, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_a2, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_c1, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_c2, "Instant: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, main_act, "Instant: ", " in seq() variation")


	await wait_process_frames(1)
func test_prologue_seq_timed_2x1x2():

	var theater: Theater = add_child_autofree(Theater.new())
	var execution_order := []
	var act_a1: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a1.init("ActA1", theater)

	var act_a2: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_a2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a2.init("ActA2", theater)

	var act_b: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_b.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b.init("ActB", theater)

	var act_c1: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_c1.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c1.init("ActC1", theater)

	var act_c2: Utilities.SingleTickAct = autofree(Utilities.SingleTickAct.new())
	act_c2.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c2.init("ActC2", theater)

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a): return Act.seq([[act_a1, act_a2], [act_b], [act_c1, act_c2]])
	main_act.init("MainAct", theater)

	main_act.perform()

	await wait_process_frames(4)

	assert_true(act_a1.get_perform_count() == 1, "Timed: ActA1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a1.get_perform_count()])
	assert_true(act_a2.get_perform_count() == 1, "Timed: ActA2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_a2.get_perform_count()])
	assert_true(act_b.get_perform_count() == 1, "Timed: ActB did not perform exactly once in seq() variation, Perform Count=%d" % [act_b.get_perform_count()])
	assert_true(act_c1.get_perform_count() == 1, "Timed: ActC1 did not perform exactly once in seq() variation, Perform Count=%d" % [act_c1.get_perform_count()])
	assert_true(act_c2.get_perform_count() == 1, "Timed: ActC2 did not perform exactly once in seq() variation, Perform Count=%d" % [act_c2.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "Timed: MainAct did not perform exactly once in seq() variation, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.find("ActB") > execution_order.find("ActA1"), "Timed: ActB performed before ActA1 in seq() variation")
	assert_true(execution_order.find("ActB") > execution_order.find("ActA2"), "Timed: ActB performed before ActA2 in seq() variation")
	assert_true(execution_order.find("ActC1") > execution_order.find("ActB"), "Timed: ActC1 performed before ActB in seq() variation")
	assert_true(execution_order.find("ActC2") > execution_order.find("ActB"), "Timed: ActC2 performed before ActB in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC1"), "Timed: MainAct performed before ActC1 in seq() variation")
	assert_true(execution_order.find("MainAct") > execution_order.find("ActC2"), "Timed: MainAct performed before ActC2 in seq() variation")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a1, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_a2, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_c1, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_c2, "Timed: ", " in seq() variation")
	Utilities.assert_chain_cleared(self, main_act, "Timed: ", " in seq() variation")
