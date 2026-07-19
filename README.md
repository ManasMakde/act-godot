# 🎭 act-godot
This is the godot implementation of the **Act Pattern**  
For a complete explaination & implementation in other game engines visit the [main repository](https://github.com/ManasMakde/act)

> ℹ️ **Note**:  
> If you want to use the Act Pattern in your project just copy paste these files:  
> 1. [`act.gd`](demo/act_pattern/act.gd)  
> 1. [`theater.gd`](demo/act_pattern/theater.gd)  
>
> _Also feel free to leave a ⭐ if you use them in your project!_  



## ⚙️ Act Class

| Enums    | Constants |
|---------|----------|
| [TickFlags](#tickflags) | `NONE`, `TICK`, `PHYSICS_TICK` |
| [Status](#status) | `NONE`, `PROLOGUING`, `ENTERING`, `TICKING`, `EXITING` |
| [Outcome](#outcome) | `INTERRUPTED`, `FAILURE`, `PENDING`, `SUCCESS`, `RETRY` |
| [BlockType](#blocktype) | `ONESHOT`, `PERSISTENT` |


| Signature    | Signals |
|--------------|-------|
| \(act: Act\) | [on_perform_start](#on_perform_start) |
| \(act: Act\) | [on_perform_end](#on_perform_end) |
| \(act: Act\) | [on_pre_setup](#on_pre_setup) |
| \(act: Act\) | [on_post_setup](#on_post_setup) |
| \(act: Act\) | [on_pre_prologue](#on_pre_prologue) |
| \(act: Act\) | [on_post_prologue](#on_post_prologue) |
| \(act: Act\) | [on_pre_enter](#on_pre_enter) |
| \(act: Act\) | [on_post_enter](#on_post_enter) |
| \(act: Act\) | [on_pre_tick](#on_pre_tick) |
| \(act: Act\) | [on_post_tick](#on_post_tick) |
| \(act: Act\) | [on_pre_physics_tick](#on_pre_physics_tick) |
| \(act: Act\) | [on_post_physics_tick](#on_post_physics_tick) |
| \(act: Act\) | [on_pre_exit](#on_pre_exit) |
| \(act: Act\) | [on_post_exit](#on_post_exit) |
| \(act: Act\) | [on_pre_cleanup](#on_pre_cleanup) |
| \(act: Act\) | [on_post_cleanup](#on_post_cleanup) |
| \(act: Act,<br> new_is_enabled: bool\) | [on_enable_changed](#on_enable_changed) |
| \(act: Act,<br> blocking_act: Act,<br> [block_type](#blocktype): BlockType,<br>did_block: bool\) | [on_block_changed](#on_block_changed) |


| Access | Type | Properties |
|--------|------|--------------|
| public | Callable | [prologue](#prologue) |
| public | Array[Callable] | [perform_conditions](#perform_conditions) |
| public | bool | [is_verbose](#is_verbose) |
| protected | bool | [_can_reperform](#_can_reperform) |
| protected | [TickFlags](#tickflags) | [_tick_flags](#_tick_flags) |


| Access | Type | Methods |
|--------|------|--------------|
| public | void | [init](#init)(theater: Theater, name := "", initially_enabled := true) |
| public | void | [deinit](#deinit)() |
| public | void | [perform](#perform)() |
| public | void | [perform_deferred](#perform_deferred)(tick_flag := [TickFlags](#tickflags)) |
| public | void | [retry](#retry)() |
| public | void | [abort](#abort)() |
| public | void | [add_to_block](#add_to_block)(acts: Array[Act], block_type := [BlockType](#blocktype)) |
| public | void | [remove_from_block](#remove_from_block)(acts: Array[Act]) |
| public | void | [set_enabled](#set_enabled)(new_enabled: bool) |
| public | bool | [did_perform](#did_perform)(tick_flag := [TickFlags](#tickflags)) |
| public | bool | [did_perform_ever](#did_perform_ever)() |
| public | bool | [is_ongoing](#is_ongoing)() |
| public | bool | [is_enabled](#is_enabled)() |
| public | bool | [is_blocked](#is_blocked)() |
| public | bool | [can_tick](#can_tick)(type: [TickFlags](#tickflags)) |
| public | [Outcome](#outcome) | [get_outcome](#get_outcome)() |
| public | Theater | [get_theater](#get_theater)() |
| public | Node | [get_owner](#get_owner)() |
| public | float | [get_delta](#get_delta)() |
| public | float | [get_physics_delta](#get_physics_delta)() |
| public | String | [get_name](#get_name)() |
| static | Array | [seq](#seq)(p_arrays: Array[Array]) |
| protected | void | [_setup](#_setup)() <abbr title="">Virtual</abbr> |
| protected | bool | [_can_perform](#_can_perform)() <abbr title="">Virtual</abbr> |
| protected | [Outcome](#outcome) | [_enter](#_enter)() <abbr title="">Virtual</abbr> |
| protected | [Outcome](#outcome) | [_tick](#_tick)() <abbr title="">Virtual</abbr> |
| protected | [Outcome](#outcome) | [_physics_tick](#_physics_tick)() <abbr title="">Virtual</abbr> |
| protected | void | [_exit](#_exit)() <abbr title="">Virtual</abbr> |
| protected | void | [_cleanup](#_cleanup)() <abbr title="">Virtual</abbr> |
| protected | void | [_finish](#_finish)(new_outcome := [Outcome](#outcome)) |
| protected | void | [_block_self](#_block_self)(by_act: Act, block_type: [BlockType](#blocktype)) <abbr title="">Virtual</abbr> |
| protected | void | [_unblock_self](#_unblock_self)(by_act: Act) <abbr title="">Virtual</abbr> |
| protected | void | [_block_others](#_block_others)() <abbr title="">Virtual</abbr> |
| protected | void | [_unblock_others](#_unblock_others)() <abbr title="">Virtual</abbr> |


<br/>


## ⚙️ Theater Class

| Signature    | Signals |
|--------------|-------|
| \(theater: Theater, new_is_enabled: bool\) | [on_enable_changed](#on_enable_changed_theater) |
| \(theater: Theater, act: Act\) | [on_perform_start](#on_perform_start) |
| \(theater: Theater, act: Act\) | [on_perform_end](#on_perform_end) |
| \(theater: Theater\) | [on_all_perform_end](#on_all_perform_end) |


| Access | Type | Methods |
|--------|------|--------------|
| public | bool | [is_enabled](#is_enabled_theater)() |
| public | void | [set_enabled](#set_enabled_theater)(new_enabled: bool) |
| public | void | [abort_all](#abort_all)() |
| public | bool | [are_any_ongoing](#are_any_ongoing)() |
| public | Dictionary[Act, bool] | [get_all_acts](#get_all_acts)() |


<br/>


## 📖 Act Descriptions

### <a id="tickflags"></a> enum TickFlags
- `NONE`: Indicates no ticking should occur.
- `TICK`: Indicates [`Node._process()`][Godot-Process] should be invoked for the act.
- `PHYSICS_TICK`: Indicates [`Node._physics_process()`][Godot-PhysicsProcess] should be invoked for the act.


---


### <a id="status"></a> enum Status
- `NONE`: Indicates the act is not ongoing.  
- `PROLOGUING`: Indicates the act is waiting on pending prologues to complete.
- `ENTERING`: Indicates the act is carrying out it's core behaviour.  
- `TICKING`: Indicates the act is ticking within any or all of it's [_tick](#_tick)() or [_physics_tick](#_physics_tick)() methods.
- `EXITING`: Indicates the act perform has ended and is now finalizing.  


---


### <a id="outcome"></a> enum Outcome
- `INTERRUPTED`: Indicates the act was interrupted externally while performing.  
- `FAILURE`: Indicates the act failed to complete it's core behaviour.  
- `PENDING`: Indicates the act is still pending for it's core behaviour to complete which might also indicate ticking if [_tick_flags](#_tick_flags) is assigned.  
- `SUCCESS`: Indicates the act successfully completed it's core behaviour.  
- `RETRY`:  Indicates the act is retrying it's core behaviour.  


---


### <a id="blocktype"></a> enum BlockType
- `ONESHOT`: Merely interrupts the act (if ongoing) when the blocker act starts performing.
- `PERSISTENT`: Keeps the act blocked for the entire duration of the blocker act performing.  


---


### <a id="on_perform_start"></a> signal on_perform_start(act: Act)
Emitted just before the start of the perform lifecycle.


---


### <a id="on_perform_end"></a> signal on_perform_end(act: Act)
Emitted just after the end of the perform lifecycle.


---


### <a id="on_pre_setup"></a> signal on_pre_setup(act: Act)
Emitted just before [_setup](#_setup)() method is called.


---


### <a id="on_post_setup"></a> signal on_post_setup(act: Act)
Emitted just after [_setup](#_setup)() method has been called.


---


### <a id="on_pre_prologue"></a> signal on_pre_prologue(act: Act)
Emitted just before prologue acts start performing.  
Will not be emitted if act has no prologues.


---


### <a id="on_post_prologue"></a> signal on_post_prologue(act: Act)
Emitted just after all prologue acts have performed.  
Will not be emitted if act has no prologues or If any of the prologues failed.


---


### <a id="on_pre_enter"></a> signal on_pre_enter(act: Act)
Emitted just before [_enter](#_enter)() method is called.


---


### <a id="on_post_enter"></a> signal on_post_enter(act: Act)
Emitted just after [_enter](#_enter)() method has been called.


---


### <a id="on_pre_tick"></a> signal on_pre_tick(act: Act)
Emitted just before [_tick](#_tick)() method is called.


---


### <a id="on_post_tick"></a> signal on_post_tick(act: Act)
Emitted just after [_tick](#_tick)() method has been called.


---


### <a id="on_pre_physics_tick"></a> signal on_pre_physics_tick(act: Act)
Emitted just before [_physics_tick](#_physics_tick)() method is called.


---


### <a id="on_post_physics_tick"></a> signal on_post_physics_tick(act: Act)
Emitted just after [_physics_tick](#_physics_tick)() method has been called.


---


### <a id="on_pre_exit"></a> signal on_pre_exit(act: Act)
Emitted just before [_exit](#_exit)() method is called.


---


### <a id="on_post_exit"></a> signal on_post_exit(act: Act)
Emitted just after [_exit](#_exit)() method has been called.


---


### <a id="on_pre_cleanup"></a> signal on_pre_cleanup(act: Act)
Emitted just before [_cleanup](#_cleanup)() method is called.


---


### <a id="on_post_cleanup"></a> signal on_post_cleanup(act: Act)
Emitted just after [_cleanup](#_cleanup)() method has been called.


---


### <a id="on_enable_changed"></a> signal on_enable_changed(act: Act, new_is_enabled: bool)
Emitted whenever the act has been enabled/disabled.


---


### <a id="on_block_changed"></a> signal on_block_changed(act: Act, blocking_act: Act, block_type: BlockType, did_block: bool)
Emitted whenever the act has been blocked/unblocked.


---


### <a id="init"></a> func init(theater: Theater, name := "", initially_enabled := true)
This method is used to initialize the act & it must be called once before you can call [`perform()`](#perform).  
Generally this will be called in [`Node._ready()`][Godot-Ready] though it can be used elsewhere if required.  
```gdscript
func _ready():
	theater = get_node("Theater")
	my_act.on_post_enter.connect(func(act: Act):
		print("Before Entering")
	)
	my_act.prologue = func(act: Act) -> Array[Act]:
		return [some_act]
	my_act.my_var = 10
	my_act.init(theater, "My Act")
```
i.e. You should ideally set all Signals, Prologue, Onetime Properties, etc before you call `init()`.  
Calling `init()` will internally call your overridden `_setup()` method.


---


### <a id="deinit"></a> func deinit()
This method is used to deinitialize the act & it must be called before the act is destroyed.  
After calling this method [`perform()`](#perform) cannot be called unless you intialize again.  
Generally this will be called in [`Node._exit_tree()`][Godot-ExitTree].  
```gdscript
func _exit_tree():
	my_act.deinit()
```
Calling `deinit()` will internally call your overridden `_cleanup()` method.


---


### <a id="perform"></a> func perform()
Call this method when you want your defined act behaviour to run. This will start the perform lifecycle of the act.  
```gdscript
func _physics_process(_delta):
	move_act.direction = get_direction()
	move_act.perform()
```


---


### <a id="perform_deferred"></a> func perform_deferred(tick_flag := TickFlags.PHYSICS_TICK)
This will delay off the [`perform()`](#perform) until the next tick. Useful to avoid infinite recursion when trying to reperform an act.


---


### <a id="retry"></a> func retry()
If the act is performing then this function will finish the act with [Outcome.RETRY](#outcome) which will cause the act to reperform.   
If the act is not performing this will simply call [`perform()`](#perform).   


---


### <a id="abort"></a> func abort()
This will finish the act if it's performing with [Outcome.INTERRUPTED](#outcome).  
Won't do anything if the act was not performing.


---


### <a id="add_to_block"></a> func add_to_block(acts: Array[Act], block_type := BlockType.PERSISTENT)
Stores which other acts to block while performing.  
```gdscript
func _ready():
	theater = get_node("Theater")
	damaged_act.add_to_block([walk_act])  # Walking is blocked while player is taking damage
	damaged_act.init(theater, "Damaged Act")
```

Also look into [BlockType](#blocktype).


---


### <a id="remove_from_block"></a> func remove_from_block(acts: Array[Act])
Removes given acts from being blocked.


---


### <a id="set_enabled"></a> func set_enabled(new_enabled: bool)
Disables/Enables the act i.e. If an act is disabled then it can no longer [`perform()`](#perform) and any act that was ongoing will be interrupted.
```gdscript
my_act.set_enabled(false)  # Disable act
my_act.set_enabled(true)  # Enable act
```


---


### <a id="did_perform"></a> func did_perform(tick_flag := TickFlags.PHYSICS_TICK) -> bool
Returns `true` if the act has performed atleast once in the span of the current tick.  
```gdscript
func _physics_process(_delta):
	print(my_act.did_perform(Act.TickFlags.PHYSICS_TICK))  # false
	my_act.perform()
	print(my_act.did_perform(Act.TickFlags.PHYSICS_TICK))  # true
```


---


### <a id="did_perform_ever"></a> func did_perform_ever() -> bool
Returns `true` if the act has performed even once since it was [initialized](#init). Resets after act has been [deinitialized](#deinit).
```gdscript
print(my_act.did_perform_ever())  # false

my_act.init(theater)
print(my_act.did_perform_ever())  # false

my_act.perform()
print(my_act.did_perform_ever())  # true

my_act.deinit()
print(my_act.did_perform_ever())  # false
```


---


### <a id="is_ongoing"></a> func is_ongoing() -> bool
Returns `true` if the act is currently performing.


---


### <a id="is_enabled"></a> func is_enabled() -> bool
Returns `true` if the act is currently enabled.


---


### <a id="is_blocked"></a> func is_blocked() -> bool
Returns `true` if the act is currently blocked by 1 or more other acts.


---


### <a id="can_tick"></a> func can_tick(type: TickFlags) -> bool
Returns `true` if the act can tick on the given flag type(s).


---


### <a id="get_outcome"></a> func get_outcome() -> Outcome
Returns the outcome of [`_enter()`](#_enter) or any of the tick methods.  
However this is only to be used inside the lifecycle methods since [`_exit()`](#_exit) will internally reset the flag.


---


### <a id="get_theater"></a> func get_theater() -> Theater
Returns the `Theater` the act belongs to.


---


### <a id="get_owner"></a> func get_owner() -> Node
Returns the [node][Godot-Node] the `Theater` is a child of, Returns `null` if theater is not assigned.


---


### <a id="get_delta"></a> func get_delta() -> float
Returns the theater's [`get_process_delta_time()`][Godot-ProcessDeltaTime]  
(Kept for consistency sake)


---


### <a id="get_physics_delta"></a> func get_physics_delta() -> float
Returns the theater's [`get_physics_process_delta_time()`][Godot-PhysicsDeltaTime]  
(Kept for consistency sake)


---


### <a id="get_name"></a> func get_name() -> String
Returns the name of the act as passed to [`init()`](#init).  
Mainly useful for debugging purposes.


---


### <a id="seq"></a> static func seq(p_arrays: Array[Array]) -> Array
This method is to be used **only** inside [prologue](#prologue), It allows you to call prologue acts in sequence.  
```gdscript
my_act.prologue = func(act: Act) -> Array[Act]:
	return Act.seq([
		[my_act_a1],
		[my_act_b1, my_act_b2],
		[my_act_c1],
	])
```
In the above example `my_act_a1` will perform first,  
then `my_act_b1` & `my_act_b2` will perform in parallel,  
then `my_act_c1` will perform last.  
And then after all prologue acts are complete would `my_act` be performed.  

This is how to do it without using `seq()`:
```gdscript
my_act.prologue = func(act: Act) -> Array[Act]:
	return [my_act_c1]

my_act_c1.prologue = func(act: Act) -> Array[Act]:
	return [my_act_b1, my_act_b2]

my_act_b1.prologue = func(act: Act) -> Array[Act]:
	return [my_act_a1]

my_act_b2.prologue = func(act: Act) -> Array[Act]:
	return [my_act_a1]
```


---


### <a id="_setup"></a> func _setup()
> **Note:** This method is only meant to be overridden never invoked, Except when using `super._setup()`.

This method is meant to be overridden and should contain your initialization logic inside it.
```gdscript
class_name MyAct extends Act

var rigid_body: RigidBody2D

func _setup():
	_can_reperform = true
	_tick_flags = TickFlags.TICK
	rigid_body = get_owner().get_node("RigidBody2D")
	# etc etc
```


---


### <a id="_can_perform"></a> func _can_perform() -> bool
> **Note:** This method is only meant to be overridden never invoked, Except when using `super._can_perform()`.

This method is meant to be overridden and should contain conditions on whether or not `perform()` can be called.
```gdscript
class_name RunAct extends Act

func _can_perform() -> bool:
	return is_on_ground()  # Cannot run if not on ground
```


---


### <a id="_enter"></a> func _enter() -> Outcome

> **Note:** This method is only meant to be overridden never invoked, Except when using `super._enter()`.

This method is meant to be overridden and should contain the core behaviour of the act.  
The return value dictates the outcome of the act. Possible return values are:  
- `Outcome.FAILURE`  
- `Outcome.PENDING`  
- `Outcome.SUCCESS`  
- `Outcome.RETRY`   
Do not return `Outcome.INTERRUPTED` that is reserved for external cancellation.

```gdscript
class_name RunAct extends Act

func _enter() -> Outcome:
	var did_move: bool

	# run logic here

	return Outcome.SUCCESS if did_move else Outcome.FAILURE
```

If you want to use any of the tick methods [`_tick()`](#_tick), [`_physics_tick()`](#_physics_tick) you must:
1. Assign [`_tick_flags`](#_tick_flags) with something other than [`TickFlags.NONE`](#tickflags).
1. Return [`Outcome.PENDING`](#outcome) in `_enter()`, returning anything else will lead to [`_exit()`](#_exit).

```gdscript
class_name GotoAct extends Act

func _setup():
	_tick_flags = TickFlags.PHYSICS_TICK

func _enter() -> Outcome:

	if at_destination():  # Return as success if already at destination
		return Outcome.SUCCESS

	return Outcome.PENDING

func _physics_tick() -> Outcome:

	# Move logic here...

	# Returning pending continues ticking, returning anything else makes the act proceeed into _exit()
	return Outcome.SUCCESS if reached_destination() else Outcome.PENDING
```

If `Outcome.PENDING` is returned without the intent of ticking, [`_finish()`](#_finish) must be called so the act can proceed to [`_exit()`](#_exit).  
```gdscript
class_name EmoteAct extends Act

func _enter() -> Outcome:

	play_animation()

	on_animation_ended.connect(func(did_play: bool):
		_finish(Outcome.SUCCESS if did_play else Outcome.FAILURE)
	)

	return Outcome.PENDING
```
Return `Outcome.RETRY` if you want the act to perform again without continuing with epilogue acts first.


---


### <a id="_tick"></a> func _tick() -> Outcome
> **Note:** This method is only meant to be overridden never invoked, Except when using `super._tick()`.

This method is meant to be overridden and should contain the visual frame ticking logic of the act.  
Look into [`_enter()`](#_enter) to understand how the return value works.


---


### <a id="_physics_tick"></a> func _physics_tick() -> Outcome
> **Note:** This method is only meant to be overridden never invoked, Except when using `super._physics_tick()`.

This method is meant to be overridden and should contain the physics frame ticking logic of the act.  
Look into [`_enter()`](#_enter) to understand how the return value works.


---


### <a id="_exit"></a> func _exit()
> **Note:** This method is only meant to be overridden never invoked, Except when using `super._exit()`.

This method is meant to be overridden and should contain the finialization logic after [Entering](#_enter).  
```gdscript
class_name MoveAct extends Act

var direction := Vector2.ZERO

func _enter() -> Outcome:
	# ...
	return Outcome.PENDING

func _exit():
	direction = Vector2.ZERO
```


---


### <a id="_cleanup"></a> func _cleanup()
> **Note:** This method is only meant to be overridden never invoked, Except when using `super._cleanup()`.

This method is meant to be overridden and should contain your deinitialization logic inside it.
```gdscript
class_name MyAct extends Act

var rigid_body: RigidBody2D

func _cleanup():
	rigid_body = null
	# etc etc
```


---


### <a id="_finish"></a> func _finish(new_outcome := Outcome.SUCCESS)
This method is only meant to be invoked in [`_enter()`](#_enter) and should not be overridden.  


---


### <a id="_block_self"></a> func _block_self(by_act: Act, block_type: BlockType)
This method is used internally, Only kept incase some special functionality needs to be hooked when act is being blocked. 
```gdscript
class_name MyAct extends Act

func _block_self(by_act: Act, block_type: BlockType):

	super._block_self(by_act, block_type)

	# custom functionality
```

---


### <a id="_unblock_self"></a> func _unblock_self(by_act: Act)
This method is used internally, Only kept incase some special functionality needs to be hooked when act is being unblocked. 
```gdscript
class_name MyAct extends Act

func _unblock_self(by_act: Act):

	super._unblock_self(by_act)

	# custom functionality
```


---


### <a id="_block_others"></a> func _block_others()
This method is used internally, Only kept incase some special functionality needs to be hooked when act is blocking others. 
```gdscript
class_name MyAct extends Act

func _block_others():

	super._block_others()

	# custom functionality
```


---


### <a id="_unblock_others"></a> func _unblock_others()
This method is used internally, Only kept incase some special functionality needs to be hooked when act is unblocking others. 
```gdscript
class_name MyAct extends Act

func _unblock_others():

	super._unblock_others()

	# custom functionality
```


---


### <a id="prologue"></a> var prologue: Callable
`Default: func(act: Act) -> Array[Act]: return []`  

Assign this with a function which returns a list of acts, All acts in that list will be performed in parallel before the main act is performed.  
If the list contains `null` or if any act failed to perform it will be treated as act failed.  
```gdscript
my_act.prologue = func(act: Act) -> Array[Act]:

	if to_fail:
		return [null]  # This will intentionally fail the act

	return [my_act_1, my_act_2]  # my_act_1 & my_act_2 will be performed in parallel
```


---


### <a id="perform_conditions"></a> var perform_conditions: Array[Callable]
`Default: []`  

Used when overriding [`_can_perform()`](#_can_perform) isn't sufficient and additional external conditions are required. Signature is `func(act: Act) -> bool`.
```gdscript
func _physics_process(_delta):
	jump_act.perform()

func _ready():
	jump_act.perform_conditions.append(func(_act: Act) -> bool:
		return Input.is_action_just_pressed("jump")  # Only jump when jump input is pressed
	)
	jump_act.init(theater, "Jump Act")
```


---


### <a id="is_verbose"></a> var is_verbose: bool
`Default: true`  

Controls whether or not to print warnings. Set to `false` to silence them.


---


### <a id="_can_reperform"></a> var _can_reperform: bool
> **Note:** Should only be assigned inside the [`_setup()`](#_setup) method.  

`Default: false` 

If `true` then calling `perform()` while act is already performing will finish interruptively current perform and then reperform.  
If `false` then current ongoing perform must be completed before calling `perform()` again.


---


### <a id="_tick_flags"></a> var _tick_flags: TickFlags
> **Note:** Should only be assigned inside the [`_setup()`](#_setup) method.  

`Default: TickFlags.NONE`  

Determines which tick methods are to be called. Look into [`_enter()`](#_enter) & [`TickFlags`](#tickflags) to learn more.


<br/>


## 📖 Theater Descriptions

### <a id="on_enable_changed_theater"></a> signal on_enable_changed(theater: Theater, new_is_enabled: bool)
Emitted whenever theater has been enabled/disabled.


---


### <a id="on_perform_start"></a> signal on_perform_start(theater: Theater, act: Act)
Emitted whenever any of acts assigned to the theater has started to performed.


---


### <a id="on_perform_end"></a> signal on_perform_end(theater: Theater, act: Act)
Emitted whenever any of acts assigned to the theater has completed performing.


---


### <a id="on_all_perform_end"></a> signal on_all_perform_end(theater: Theater)
Emitted whenever all of the acts assigned to the theater have completed performing and none are ongoing anymore.  
Useful for idle checking, etc.


---


### <a id="is_enabled_theater"></a> func is_enabled() -> bool
Returns `true` if theater is currently enabled.

---


### <a id="set_enabled_theater"></a> func set_enabled(new_enabled: bool)
Disables/Enables theater i.e. If a theater is disabled then all acts assigned to it can no longer [`perform()`](#perform) and any act that was ongoing will be interrupted.
```gdscript
theater.set_enabled(false)  # Disable theater
theater.set_enabled(true)  # Enable theater
```


---


### <a id="abort_all"></a> func abort_all()
Calls [`abort()`](#abort) on all currently ongoing acts.


---


### <a id="are_any_ongoing"></a> func are_any_ongoing() -> bool
Returns `true` if any act is currently performing.


---


### <a id="get_all_acts"></a> func get_all_acts() -> Dictionary[Act, bool]
Returns a dictionary (treat as a HashSet) of all the acts assigned to the theater.


<br>


## 🤝 Contribution
You can contribute in the following ways:
1. Report bugs or suggest features by opening a [new issue](https://github.com/ManasMakde/act-godot/issues/new).
2. Write test cases.
3. Sponsor this project.



## ❤️ Sponsor
If this project has been useful for you consider [supporting][Sponsor] its development.  
Any support motivates to keep the project well maintained, documented & growing.



## 🔑 License
MIT © [Manas Ravindra Makde](https://manasmakde.github.io/)



[Sponsor]: https://github.com/sponsors/ManasMakde
[Act-Lifecycle]: https://github.com/ManasMakde/act/blob/main/images/act-lifecycle.png
[Godot-Ready]: https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-private-method-ready
[Godot-Process]: https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-private-method-process
[Godot-PhysicsProcess]: https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-private-method-physics-process
[Godot-Node]: https://docs.godotengine.org/en/stable/classes/class_node.html
[Godot-ProcessDeltaTime]: https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-get-process-delta-time
[Godot-PhysicsDeltaTime]: https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-get-physics-process-delta-time
[Godot-ExitTree]: http://docs.godotengine.org/en/stable/classes/class_node.html#class-node-private-method-exit-tree
