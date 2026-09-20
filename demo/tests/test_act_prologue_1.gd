extends GutTest


# 1. Does prologue chain {{act_a}} work?
# 1. Does prologue chain {{act_a}, {act_b}} work?
# 1. Does prologue chain {{act_a}, {act_b}, {act_c}} work?


func test_prologue_instant_1():

	var execution_order := []
	var act_a: Act = autofree(Act.new())
	act_a.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a.init("ActA")

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a) -> Array[Act]: return [act_a]
	main_act.init("MainAct")

	main_act.perform()

	assert_true(act_a.get_perform_count() == 1, "ActA did not perform, Perform Count=%d" % [act_a.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "MainAct did not perform, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.size() == 2 && execution_order[0] == "ActA" && execution_order[1] == "MainAct", "Execution order invalid")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a)
	Utilities.assert_chain_cleared(self, main_act)


	await wait_process_frames(1)
func test_prologue_seq_instant_1():

	var execution_order := []
	var act_a: Act = autofree(Act.new())
	act_a.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a.init("ActA")

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a): return Act.seq([[act_a]])
	main_act.init("MainAct")

	main_act.perform()

	assert_true(act_a.get_perform_count() == 1, "ActA did not perform in seq() variation, Perform Count=%d" % [act_a.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "MainAct did not perform in seq() variation, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.size() == 2 && execution_order[0] == "ActA" && execution_order[1] == "MainAct", "Execution order invalid in seq() variation")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a, "", " in seq() variation")
	Utilities.assert_chain_cleared(self, main_act, "", " in seq() variation")


	await wait_process_frames(1)
func test_prologue_instant_1x1():

	var execution_order := []
	var act_a: Act = autofree(Act.new())
	act_a.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a.init("ActA")

	var act_b: Act = autofree(Act.new())
	act_b.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b.prologue = func(a) -> Array[Act]: return [act_a]
	act_b.init("ActB")

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a) -> Array[Act]: return [act_b]
	main_act.init("MainAct")

	main_act.perform()

	assert_true(act_a.get_perform_count() == 1, "ActA did not perform, Perform Count=%d" % [act_a.get_perform_count()])
	assert_true(act_b.get_perform_count() == 1, "ActB did not perform, Perform Count=%d" % [act_b.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "MainAct did not perform, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.size() == 3 && execution_order[0] == "ActA" && execution_order[1] == "ActB" && execution_order[2] == "MainAct", "Execution order invalid")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a)
	Utilities.assert_chain_cleared(self, act_b)
	Utilities.assert_chain_cleared(self, main_act)


	await wait_process_frames(1)
func test_prologue_seq_instant_1x1():

	var execution_order := []
	var act_a: Act = autofree(Act.new())
	act_a.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a.init("ActA")

	var act_b: Act = autofree(Act.new())
	act_b.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b.init("ActB")

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a): return Act.seq([[act_a], [act_b]])
	main_act.init("MainAct")

	main_act.perform()

	assert_true(act_a.get_perform_count() == 1, "ActA did not perform in seq() variation, Perform Count=%d" % [act_a.get_perform_count()])
	assert_true(act_b.get_perform_count() == 1, "ActB did not perform in seq() variation, Perform Count=%d" % [act_b.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "MainAct did not perform in seq() variation, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.size() == 3 && execution_order[0] == "ActA" && execution_order[1] == "ActB" && execution_order[2] == "MainAct", "Execution order invalid in seq() variation")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a, "", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b, "", " in seq() variation")
	Utilities.assert_chain_cleared(self, main_act, "", " in seq() variation")


	await wait_process_frames(1)
func test_prologue_instant_1x1x1():

	var execution_order := []
	var act_a: Act = autofree(Act.new())
	act_a.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a.init("ActA")

	var act_b: Act = autofree(Act.new())
	act_b.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b.prologue = func(a) -> Array[Act]: return [act_a]
	act_b.init("ActB")

	var act_c: Act = autofree(Act.new())
	act_c.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c.prologue = func(a) -> Array[Act]: return [act_b]
	act_c.init("ActC")

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a) -> Array[Act]: return [act_c]
	main_act.init("MainAct")

	main_act.perform()

	assert_true(act_a.get_perform_count() == 1, "ActA did not perform exactly once, Perform Count=%d" % [act_a.get_perform_count()])
	assert_true(act_b.get_perform_count() == 1, "ActB did not perform exactly once, Perform Count=%d" % [act_b.get_perform_count()])
	assert_true(act_c.get_perform_count() == 1, "ActC did not perform exactly once, Perform Count=%d" % [act_c.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "MainAct did not perform exactly once, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.size() == 4 && execution_order[0] == "ActA" && execution_order[1] == "ActB" && execution_order[2] == "ActC" && execution_order[3] == "MainAct", "Execution order invalid")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a)
	Utilities.assert_chain_cleared(self, act_b)
	Utilities.assert_chain_cleared(self, act_c)
	Utilities.assert_chain_cleared(self, main_act)


	await wait_process_frames(1)
func test_prologue_seq_instant_1x1x1():

	var execution_order := []
	var act_a: Act = autofree(Act.new())
	act_a.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_a.init("ActA")

	var act_b: Act = autofree(Act.new())
	act_b.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_b.init("ActB")

	var act_c: Act = autofree(Act.new())
	act_c.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	act_c.init("ActC")

	var main_act: Act = autofree(Act.new())
	main_act.on_pre_enter.connect(func(a): execution_order.append(a.get_name()))
	main_act.prologue = func(a): return Act.seq([[act_a], [act_b], [act_c]])
	main_act.init("MainAct")

	main_act.perform()

	assert_true(act_a.get_perform_count() == 1, "ActA did not perform exactly once in seq() variation, Perform Count=%d" % [act_a.get_perform_count()])
	assert_true(act_b.get_perform_count() == 1, "ActB did not perform exactly once in seq() variation, Perform Count=%d" % [act_b.get_perform_count()])
	assert_true(act_c.get_perform_count() == 1, "ActC did not perform exactly once in seq() variation, Perform Count=%d" % [act_c.get_perform_count()])
	assert_true(main_act.get_perform_count() == 1, "MainAct did not perform exactly once in seq() variation, Perform Count=%d" % [main_act.get_perform_count()])
	assert_true(execution_order.size() == 4 && execution_order[0] == "ActA" && execution_order[1] == "ActB" && execution_order[2] == "ActC" && execution_order[3] == "MainAct", "Execution order invalid in seq() variation")

	# Check chain sets cleared after perform
	Utilities.assert_chain_cleared(self, act_a, "", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_b, "", " in seq() variation")
	Utilities.assert_chain_cleared(self, act_c, "", " in seq() variation")
	Utilities.assert_chain_cleared(self, main_act, "", " in seq() variation")


	await wait_process_frames(1)
