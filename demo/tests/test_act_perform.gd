extends GutTest


# 1. Are pre perform request and post perform request signals being broadcasted with correct arguments?
# 1. Are perform start and perform end signals being broadcasted with correct arguments?

# 1. Does perform fail when act disabled?
# 1. Does perform fail when theater disabled?
# 1. Does perform fail when act blocked?
# 1. Does perform fail when already ongoing and cannot reperform?
# 1. Does perform fail when external condition is false?
# 1. Does perform fail when overriden _can_perform() is false?
# 1. Does perform fail when called while exiting?

# 1. Does perform succeed when act enabled?
# 1. Does perform succeed when theater enabled?
# 1. Does perform succeed when already ongoing and can reperform?
# 1. Does perform succeed when external condition is true?
# 1. Does perform succeed when overriden _can_perform() is true?

# 1. Does _can_reperform work correctly?

# 1. Does perform fail from on_pre_setup?
# 1. Does perform succeed from on_post_setup?
# 1. Does reperform succeed from on_perform_start?
# 1. Does reperform succeed from on_pre_prologue?
# 1. Does reperform succeed from on_prologue_complete?
# 1. Does reperform succeed from on_post_prologue?
# 1. Does reperform succeed from on_pre_enter?
# 1. Does reperform succeed from on_post_enter?
# 1. Does reperform succeed from on_pre_tick?
# 1. Does reperform succeed from on_post_tick?
# 1. Does reperform succeed from on_pre_physics_tick?
# 1. Does reperform succeed from on_post_physics_tick?
# 1. Does reperform fail from on_pre_exit?
# 1. Does reperform fail from on_post_exit?
# 1. Does perform succeed from on_perform_end?
# 1. Does reperform fail from on_pre_cleanup?
# 1. Does reperform succeed from on_post_cleanup?
# 1. Does perform succeed from on_enable_changed?
# 1. Does perform succeed from on_block_changed?


func test_on_perform_pre_and_post_req():

	# Prerequisites
	var pre_req_tag := "PreReq"
	var post_req_tag := "PostReq"
	var start_tag := "Start"
	var event_order := []


	# Successful perform
	var was_pre_req_invoked := [false]
	var pre_req_arg_1 := [null]
	var was_post_req_invoked := [false]
	var post_req_arg_1 := [null]
	var post_req_arg_2 := [false]

	var act: Act = autofree(Act.new())
	act.on_pre_perform_req.connect(func(a): was_pre_req_invoked[0] = true; pre_req_arg_1[0] = a; event_order.append(pre_req_tag))
	act.on_post_perform_req.connect(func(a, will_perform): was_post_req_invoked[0] = true; post_req_arg_1[0] = a; post_req_arg_2[0] = will_perform; event_order.append(post_req_tag))
	act.on_perform_start.connect(func(a): event_order.append(start_tag))
	act.init("Test Act")
	act.perform()


	# Assertions for successful perform
	assert_true(was_pre_req_invoked[0], "on_pre_perform_req not invoked!")
	assert_true(pre_req_arg_1[0] == act, "on_pre_perform_req first argument is invalid! Arg1='%s'" % [pre_req_arg_1[0]])
	assert_true(was_post_req_invoked[0], "on_post_perform_req not invoked!")
	assert_true(post_req_arg_1[0] == act, "on_post_perform_req first argument is invalid! Arg1='%s'" % [post_req_arg_1[0]])
	assert_true(post_req_arg_2[0] == true, "on_post_perform_req second argument is not true despite act performing! Arg2='%s'" % [post_req_arg_2[0]])
	assert_true(event_order.size() == 3 && event_order[0] == pre_req_tag && event_order[1] == post_req_tag && event_order[2] == start_tag, "Perform request events invalid order! Order='%s'" % [",".join(event_order)])


	# Failed perform
	was_pre_req_invoked[0] = false
	was_post_req_invoked[0] = false
	post_req_arg_2[0] = true

	var fail_act: Utilities.FalseCanPerformAct = autofree(Utilities.FalseCanPerformAct.new())
	fail_act.on_pre_perform_req.connect(func(a): was_pre_req_invoked[0] = true)
	fail_act.on_post_perform_req.connect(func(a, will_perform): was_post_req_invoked[0] = true; post_req_arg_2[0] = will_perform)
	fail_act.init("Fail Act")
	fail_act.perform()


	# Assertions for failed perform
	assert_true(was_pre_req_invoked[0], "on_pre_perform_req not invoked despite perform failing!")
	assert_true(was_post_req_invoked[0], "on_post_perform_req not invoked despite perform failing!")
	assert_true(post_req_arg_2[0] == false, "on_post_perform_req second argument is not false despite perform failing! Arg2='%s'" % [post_req_arg_2[0]])
	assert_true(fail_act.get_perform_count() == 0, "Act performed despite _can_perform() being false! Perform Count=%d" % [fail_act.get_perform_count()])


	await wait_process_frames(1)
func test_on_perform_start_and_end():

	# Prerequisites
	var was_start_invoked := [false]
	var start_arg_1 := [null]
	var was_end_invoked := [false]
	var end_arg_1 := [null]


	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_perform_start.connect(func(a): was_start_invoked[0] = true; start_arg_1[0] = a)
	act.on_perform_end.connect(func(a): was_end_invoked[0] = true; end_arg_1[0] = a)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(was_start_invoked[0], "on_perform_start not invoked!")
	assert_true(start_arg_1[0] == act, "on_perform_start first argument is invalid! Arg1=`%s`" % [start_arg_1[0]])
	assert_true(was_end_invoked[0], "on_perform_end not invoked!")
	assert_true(end_arg_1[0] == act, "on_perform_end first argument is invalid! Arg1=`%s`" % [end_arg_1[0]])


	await wait_process_frames(1)



func test_perform_when_disabled():

	# Perform Act
	var act: Act = autofree(Act.new())
	act.init("Test Act", null)

	var was_enabled := act.is_enabled()
	act.set_enabled(false)
	var was_disabled := !act.is_enabled()
	act.set_enabled(true)
	var was_re_enabled := act.is_enabled()


	# Assertions
	assert_true(was_enabled, "Act not enabled by default!")
	assert_true(was_disabled, "Act disabling failed!")
	assert_true(was_re_enabled, "Act re-enabling after disabling failed!")


	await wait_process_frames(1)
func test_perform_when_theater_disabled():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)
	theater.set_enabled(false)


	# Perform Act
	var act: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act.init("Test Act", theater)
	act.perform()


	# Assertions
	assert_false(act.is_ongoing(), "Act performed despite theater being disabled!")


	theater.queue_free()
	await wait_process_frames(1)
func test_perform_when_blocked():

	# Perform First Block Later
	var act_pfbl: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act_pfbl.init("Test Act")
	act_pfbl.perform()

	var blocking_act_pfbl: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	blocking_act_pfbl.init("Blocking Act")
	blocking_act_pfbl.add_to_block([act_pfbl])
	blocking_act_pfbl.perform()

	var is_ongoing_pfbl := act_pfbl.is_ongoing()
	var is_blocked_pfbl := act_pfbl.is_blocked()


	# Block First Perform Later
	var act_bfpl: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act_bfpl.init("Test Act")

	var blocking_act_bfpl: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	blocking_act_bfpl.init("Blocking Act")
	blocking_act_bfpl.add_to_block([act_bfpl])
	blocking_act_bfpl.perform()

	act_bfpl.perform()


	var is_ongoing_bfpl := act_bfpl.is_ongoing()
	var is_blocked_bfpl := act_bfpl.is_blocked()


	# Assertions
	assert_true(!is_ongoing_pfbl, "Act is ongoing despite being blocked (Perform First Block Later)!")
	assert_true(is_blocked_pfbl, "Act is unblocked despite being blocked (Perform First Block Later)!")
	assert_true(!is_ongoing_bfpl, "Act is ongoing despite being blocked (Block First Perform Later)!")
	assert_true(is_blocked_bfpl, "Act is unblocked despite being blocked (Block First Perform Later)!")

	await wait_process_frames(1)
func test_perform_when_cannot_reperform():

	# Perform Act
	var act: Utilities.NonReperformableInfiAct = autofree(Utilities.NonReperformableInfiAct.new())
	var enter_count := [0]
	act.on_pre_enter.connect(func(a):
		enter_count[0] += 1
	)
	act.init("Test Act")
	act.perform()
	act.perform()


	# Assertions
	assert_true(enter_count[0] == 1, "Act reperformed despite _can_reperform being false!")


	await wait_process_frames(1)
func test_perform_when_external_condition_false():

	# Perform Act
	var act: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act.perform_conditions.append(func(a): return false)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(!act.is_ongoing(), "Act performed despite external condition being false!")


	await wait_process_frames(1)
func test_perform_when_can_perform_false():

	# Perform Act
	var act: Utilities.FalseCanPerformAct = autofree(Utilities.FalseCanPerformAct.new())
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(!act.is_ongoing(), "Act performed despite _can_perform() being false!")


	await wait_process_frames(1)



func test_perform_when_enabled():

	# Perform Act
	var act: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act.init("Test Act")
	act.set_enabled(true)
	act.perform()


	# Assertions
	assert_true(act.is_ongoing(), "Act did not perform despite being enabled!")


	await wait_process_frames(1)
func test_perform_when_theater_enabled():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Perform Act
	var act: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act.init("Test Act", theater)
	theater.set_enabled(true)
	act.perform()


	# Assertions
	assert_true(act.is_ongoing(), "Act did not perform despite theater being enabled!")


	theater.queue_free()
	await wait_process_frames(1)
func test_perform_when_can_reperform():

	# Perform Act
	var act: Utilities.ReperformableInfiAct = autofree(Utilities.ReperformableInfiAct.new())
	var enter_count := [0]
	act.on_pre_enter.connect(func(a):
		enter_count[0] += 1
	)
	act.init("Test Act")
	act.perform()
	act.perform()


	# Assertions
	assert_true(enter_count[0] == 2, "Act did not reperform despite _can_reperform being true!")


	await wait_process_frames(1)
func test_perform_when_external_condition_true():

	# Perform Act
	var act: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act.perform_conditions.append(func(a): return true)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(act.is_ongoing(), "Act did not perform despite external condition being true!")


	await wait_process_frames(1)
func test_perform_when_can_perform_true():

	# Perform Act
	var act: Utilities.CanPerformAct = autofree(Utilities.CanPerformAct.new())
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(act.call_count == 1, "_can_perform() not invoked despite performing!")
	assert_true(act.get_perform_count() == 1, "Act did not perform despite _can_perform() being true!")


	await wait_process_frames(1)



func test_can_reperform_works_correctly():

	# Perform Act
	var cannot_reperform_act: Utilities.NonReperformableInfiAct = autofree(Utilities.NonReperformableInfiAct.new())
	cannot_reperform_act.init("Cannot Reperform Act")
	cannot_reperform_act.perform()
	cannot_reperform_act.perform()

	var can_reperform_act: Utilities.ReperformableInfiAct = autofree(Utilities.ReperformableInfiAct.new())
	can_reperform_act.init("Can Reperform Act")
	can_reperform_act.perform()
	can_reperform_act.perform()


	# Assertions
	assert_true(cannot_reperform_act.get_perform_count() == 1, "Act reperformed despite _can_reperform being false! Count=%d" % [cannot_reperform_act.get_perform_count()])
	assert_true(can_reperform_act.get_perform_count() == 2, "Act did not reperform despite _can_reperform being true! Count=%d" % [can_reperform_act.get_perform_count()])


	await wait_process_frames(1)



func test_perform_from_on_pre_setup():

	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_pre_setup.connect(func(a):
		a.perform()
	)
	act.init("Test Act")


	# Assertions
	assert_true(act.get_perform_count() == 0, "Act performed from on_pre_setup! Perform Count=%d" % [act.get_perform_count()])


	await wait_process_frames(1)
func test_perform_from_on_post_setup():

	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_post_setup.connect(func(a):
		a.perform()
	)
	act.init("Test Act")


	# Assertions
	assert_true(act.get_perform_count() == 1, "Act performed from on_post_setup! Perform Count=%d" % [act.get_perform_count()])


	await wait_process_frames(1)
func test_perform_from_on_perform_start():

	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.on_perform_start.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform()
	)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform from on_perform_start! Perform Count=%d" % [act.get_perform_count()])

	await wait_process_frames(1)
func test_perform_from_on_pre_prologue():

	# Prologue act so the prologue signal actually fires
	var prologue_act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	prologue_act.init("Prologue Act")


	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.prologue = func(a) -> Array[Act]: return [prologue_act]
	act.on_pre_prologue.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform()
	)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform thrice from on_pre_prologue! Perform Count=%d" % [act.get_perform_count()])


	await wait_process_frames(1)
func test_perform_from_on_prologue_complete():

	# Prerequisites
	var theater := Theater.new()
	add_child(theater)


	# Prologue act
	var prologue_1_act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	prologue_1_act.init("Prologue 1 Act")

	var prologue_2_act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	prologue_2_act.init("Prologue 2 Act")


	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.prologue = func(a) -> Array[Act]: return [prologue_1_act, prologue_2_act]
	act.on_prologue_complete.connect(func(a, p_a, p_o):
		if(p_o != Act.Outcome.SUCCESS):
			return

		if(act.get_perform_count() <= 2):
			act.perform()
	)
	act.init("Test Act", theater)
	act.perform()


	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)

	await wait_physics_frames(1)
	await wait_process_frames(1)


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform thrice from on_prologue_complete! Perform Count=%d" % [act.get_perform_count()])


	theater.queue_free()
func test_perform_from_on_post_prologue():

	# Prologue act so the prologue signal actually fires
	var prologue_act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	prologue_act.init("Prologue Act")


	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.prologue = func(a) -> Array[Act]: return [prologue_act]
	act.on_post_prologue.connect(func(a):
		if(act.get_perform_count() <= 2):
			act.perform()
	)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform thrice from on_post_prologue! Perform Count=%d" % [act.get_perform_count()])


	await wait_process_frames(1)
func test_perform_from_on_pre_enter():

	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.on_pre_enter.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform()
	)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform thrice from on_pre_enter! Perform Count=%d" % [act.get_perform_count()])


	await wait_process_frames(1)
func test_perform_from_on_post_enter():

	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.on_post_enter.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform()
	)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform thrice from on_post_enter! Perform Count=%d" % [act.get_perform_count()])


	await wait_process_frames(1)
func test_perform_from_on_pre_tick():

	# Real theater needed to drive ticks
	var theater := Theater.new()
	theater.name = "TestTheater"
	add_child(theater)


	# Perform Act
	var act: Utilities.ReperformableInfiAct = autofree(Utilities.ReperformableInfiAct.new())
	act.override_tick_flag = Act.TickFlags.TICK
	act.on_pre_tick.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform()
	)
	act.init("Test Act", theater)
	act.perform()


	# Wait for tick cascade
	var frame := 0
	while(act.get_perform_count() < 3 && frame < 10):
		await wait_process_frames(1)
		frame += 1


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform thrice from on_pre_tick! Perform Count=%d" % [act.get_perform_count()])


	# Cleanup
	theater.free()
func test_perform_from_on_post_tick():

	# Real theater needed to drive ticks
	var theater := Theater.new()
	theater.name = "TestTheater"
	add_child(theater)


	# Perform Act
	var act: Utilities.ReperformableInfiAct = autofree(Utilities.ReperformableInfiAct.new())
	act.override_tick_flag = Act.TickFlags.TICK
	act.on_post_tick.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform()
	)
	act.init("Test Act", theater)
	act.perform()


	# Wait for tick cascade
	var frame := 0
	while(act.get_perform_count() < 3 && frame < 10):
		await wait_process_frames(1)
		frame += 1


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform thrice from on_post_tick! Perform Count=%d" % [act.get_perform_count()])


	# Cleanup
	theater.free()
func test_perform_from_on_pre_physics_tick():

	# Real theater needed to drive ticks
	var theater := Theater.new()
	theater.name = "TestTheater"
	add_child(theater)


	# Perform Act
	var act: Utilities.ReperformableInfiAct = autofree(Utilities.ReperformableInfiAct.new())
	act.override_tick_flag = Act.TickFlags.PHYSICS_TICK
	act.on_pre_physics_tick.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform()
	)
	act.init("Test Act", theater)
	act.perform()


	# Wait for physics tick cascade
	var frame := 0
	while(act.get_perform_count() < 3 && frame < 10):
		await wait_physics_frames(1)
		frame += 1


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform thrice from on_pre_physics_tick! Perform Count=%d" % [act.get_perform_count()])


	# Cleanup
	theater.free()
func test_perform_from_on_post_physics_tick():

	# Real theater needed to drive ticks
	var theater := Theater.new()
	theater.name = "TestTheater"
	add_child(theater)


	# Perform Act
	var act: Utilities.ReperformableInfiAct = autofree(Utilities.ReperformableInfiAct.new())
	act.override_tick_flag = Act.TickFlags.PHYSICS_TICK
	act.on_post_physics_tick.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform()
	)
	act.init("Test Act", theater)
	act.perform()


	# Wait for physics tick cascade
	var frame := 0
	while(act.get_perform_count() < 3 && frame < 10):
		await wait_physics_frames(1)
		frame += 1


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform thrice from on_post_physics_tick! Perform Count=%d" % [act.get_perform_count()])


	# Cleanup
	theater.free()
func test_perform_from_on_pre_exit():

	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.on_pre_exit.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform()
	)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(act.get_perform_count() != 3, "Act reperformed from on_pre_exit! Perform Count=%d" % [act.get_perform_count()])


	await wait_process_frames(1)
func test_perform_from_on_post_exit():

	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.on_post_exit.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform()
	)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(act.get_perform_count() != 3, "Act reperformed from on_post_exit! Perform Count=%d" % [act.get_perform_count()])


	await wait_process_frames(1)
func test_perform_from_on_perform_end():

	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.on_perform_end.connect(func(a):
		if(act.get_perform_count() <= 2):
			a.perform()
	)
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform thrice from on_perform_end! Perform Count=%d" % [act.get_perform_count()])


	await wait_process_frames(1)
func test_perform_from_on_pre_cleanup():

	# Perform Act
	var act: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	act.on_pre_cleanup.connect(func(a):
		a.perform()
	)
	act.init("Test Act")
	act.deinit()


	# Assertions
	assert_true(act.get_perform_count() == 0, "Act performed from on_pre_cleanup! Perform Count=%d" % [act.get_perform_count()])


	await wait_process_frames(1)
func test_perform_from_on_post_cleanup():

	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_post_cleanup.connect(func(a):
		a.perform()
	)
	act.init("Test Act")
	act.deinit()


	# Assertions
	assert_true(act.get_perform_count() == 1, "Act performed from on_post_cleanup! Perform Count=%d" % [act.get_perform_count()])


	await wait_process_frames(1)
func test_perform_from_on_enable_changed():

	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_enable_changed.connect(func(a, new_enabled):
		if(act.get_perform_count() <= 2):
			a.perform()
	)
	act.init("Test Act")
	act.set_enabled(false)
	act.set_enabled(true)
	act.set_enabled(false)
	act.set_enabled(true)
	act.set_enabled(false)
	act.set_enabled(true)


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform thrice from on_enable_changed! Perform Count=%d" % [act.get_perform_count()])


	await wait_process_frames(1)
func test_perform_from_on_block_changed():

	# Perform Act
	var act: Act = autofree(Act.new())
	act.on_block_changed.connect(func(a, by_act, block_type, did_block):
		if(act.get_perform_count() <= 2):
			a.perform()
	)
	act.init("Test Act")


	var blocker: Utilities.ReperformableAct = autofree(Utilities.ReperformableAct.new())
	blocker.init("Blocker Act")
	blocker.add_to_block([act])
	blocker.perform()
	blocker.abort()
	blocker.perform()
	blocker.abort()
	blocker.perform()
	blocker.abort()


	# Assertions
	assert_true(act.get_perform_count() == 3, "Act did not reperform thrice from on_block_changed! Perform Count=%d" % [act.get_perform_count()])


	await wait_process_frames(1)
