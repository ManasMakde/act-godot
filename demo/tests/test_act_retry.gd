extends GutTest


# 1. Does retry outcome make the act retry perform?
# 1. Does retry() work externally?
# 1. Does retry cancel prologues?
# 1. Does retry not cancel epilogues?
# 1. Does retry() perform the act even if not ongoing?
# 1. Does failing to retry change the outcome to failure?


func test_retry_outcome():

	# Perform Act
	var act: Utilities.RetryAct = autofree(Utilities.RetryAct.new())
	act.is_verbose = true
	act.retry_limit = 1
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(act.enter_call_count == 2, "_enter() did not run again after internal retry! Call count=%d" % [act.enter_call_count])
	assert_true(act.get_perform_count() == 2, "Act did not perform again after internal retry! Perform Count=%d" % [act.get_perform_count()])
	assert_true(act.get_outcome() == Act.Outcome.SUCCESS, "Act did not end with success after retrying! Outcome=%s" % [Act.Outcome.keys()[act.get_outcome()]])

	await wait_process_frames(1)
func test_retry_external():

	# Perform Act
	var act: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act.init("Test Act")
	act.perform()
	act.retry()


	# Assertions
	assert_true(act.get_perform_count() == 2, "Act did not perform again after calling retry() externally! Perform Count=%d" % [act.get_perform_count()])
	assert_true(act.get_status() == Act.Status.ENTERING, "Act did not re enter after retrying! Status=%s" % [Act.Status.keys()[act.get_status()]])

	await wait_process_frames(1)
func test_retry_cancels_prologues():

	# Perform Act
	var did_prologue := [false]
	var prologue_act: Utilities.ManualFinishAct = autofree(Utilities.ManualFinishAct.new())
	prologue_act.init("Prologue Act")
	var act: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act.prologue = func(a) -> Array[Act]:
		if did_prologue[0]:
			return []
		did_prologue[0] = true
		return [prologue_act]
	act.init("Test Act")
	act.perform()
	act.retry()


	# Assertions
	assert_true(prologue_act.get_perform_count() == 1, "Prologue act did not exactly once! Perform Count=%d" % [prologue_act.get_perform_count()])
	assert_true(prologue_act.get_outcome() == Act.Outcome.INTERRUPTED, "Prologue act was not interrupted after retry! Outcome=%s" % [Act.Outcome.keys()[prologue_act.get_outcome()]])
	assert_false(prologue_act.is_ongoing(), "Prologue act is still ongoing after retry cancelled it!")
	assert_true(act.get_status() == Act.Status.ENTERING, "Act did not skip cancelled prologue and enter! Status=%s" % [Act.Status.keys()[act.get_status()]])

	await wait_process_frames(1)
func test_retry_does_not_cancel_epilogues():

	# Perform Act
	var prologue_act: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	prologue_act.init("Prologue Act")
	var act: Utilities.WaitInfiniAct = autofree(Utilities.WaitInfiniAct.new())
	act.prologue = func(a) -> Array[Act]: return [prologue_act]
	act.init("Test Act")
	act.perform()

	var status_before_retry := act.get_status()
	prologue_act.retry()
	var status_after_retry := act.get_status()


	# Assertions
	assert_true(status_before_retry == Act.Status.PROLOGUING, "Act did not wait on prologue before retry! Status=%s" % [Act.Status.keys()[status_before_retry]])
	assert_true(status_after_retry == Act.Status.PROLOGUING, "Act got cancelled after prologue retried! Status=%s" % [Act.Status.keys()[status_after_retry]])
	assert_true(act.is_ongoing(), "Act stopped being ongoing after prologue retried!")

	await wait_process_frames(1)
func test_retry_performs_when_not_ongoing():

	# Perform Act
	var act: Utilities.EnterAct = autofree(Utilities.EnterAct.new())
	act.init("Test Act")
	act.retry()


	# Assertions
	assert_true(act.get_perform_count() == 1, "Act did not perform after calling retry() while not ongoing! Perform Count=%d" % [act.get_perform_count()])
	assert_true(act.call_count == 1, "_enter() was not invoked after retry() while not ongoing! Call count=%d" % [act.call_count])

	await wait_process_frames(1)
func test_retry_failure_changes_outcome():

	# Perform Act
	var act: Utilities.RetryOnceThenFailAct = autofree(Utilities.RetryOnceThenFailAct.new())
	act.init("Test Act")
	act.perform()


	# Assertions
	assert_true(act.get_outcome() == Act.Outcome.FAILURE, "Outcome did not change to failure after failing to retry! Outcome=%s" % [Act.Outcome.keys()[act.get_outcome()]])
	assert_false(act.is_ongoing(), "Act is still ongoing despite failing to retry!")

	await wait_process_frames(1)
