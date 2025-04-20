extends CharacterBody2D

# 状态集
enum State {
	IDLE,
	RUNNING,
	JUMP,
	FALL,
	LANDING,
	WALL_SLIDING,
}

const GROUND_STATUS := [State.IDLE,State.RUNNING,State.LANDING]
const RUN_SPEED := 160.0
const FLOOR_ACCELERATION := RUN_SPEED / 0.2
const AIR_ACCELERATION := RUN_SPEED / 0.02
const JUMP_VELOCITY := -400.0

var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float
var is_first_tick := false

@onready var graphics: Node2D = $Graphics
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_request_timer: Timer = $JumpRequestTimer
@onready var hand_checker: RayCast2D = $Graphics/HandChecker
@onready var foot_checker: RayCast2D = $Graphics/FootChecker


# 预输入 （缓冲跳跃）
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start()
	# 可变高度跳跃	
	if event.is_action_released("jump"):
		jump_request_timer.stop()
		if velocity.y < JUMP_VELOCITY / 2:
			velocity.y = JUMP_VELOCITY / 2
	

# 动作
func tick_physics(state: State,delta: float) -> void:
	match state:
		State.IDLE:
			move(default_gravity,delta)
		State.RUNNING:
			move(default_gravity,delta)
		State.JUMP:
			move(0.0 if is_first_tick else default_gravity, delta)
		State.FALL:
			move(default_gravity,delta)
		State.LANDING:
			stand(delta)
		State.WALL_SLIDING:
			move(default_gravity / 3, delta)
			graphics.scale.x = get_wall_normal().x
	is_first_tick = false

func move(gravity: float, delta: float) -> void:
	var direction := Input.get_axis("move_left","move_right")
	# 走到跑-均匀加速 
	var acceleration := FLOOR_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.x = move_toward(velocity.x, direction * RUN_SPEED,acceleration  * delta) 
	velocity.y += gravity * delta
	
	# 角色反转
	if not is_zero_approx(direction):
		graphics.scale.x = -1 if direction < 0 else +1
	
	move_and_slide()

func stand(delta: float) -> void:
	var acceleration := FLOOR_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.x = move_toward(velocity.x, 0.0,acceleration  * delta) 
	velocity.y += default_gravity * delta
	move_and_slide()

# 事件
func get_next_state(state: State) -> State:
	# 郊狼时间
	var can_jump := is_on_floor() or coyote_timer.time_left > 0
	# 预输入
	var should_jump := can_jump and jump_request_timer.time_left > 0
	if should_jump:
		return State.JUMP

	# 获得水平输入方向
	var direction := Input.get_axis("move_left","move_right")
	# 判断角色是否静止
	var is_still := is_zero_approx(direction) and is_zero_approx(velocity.x)
	
	# 根据当前状态决定下一个状态
	match state:
		State.IDLE:
			if not is_on_floor():
				return State.FALL
			if not is_still:
				return State.RUNNING
		State.RUNNING:
			if not is_on_floor():
				return State.FALL
			if is_still:
				return State.IDLE
		State.JUMP:
			if velocity.y >= 0:
				return State.FALL
		State.FALL:
			if is_on_floor():
				return State.LANDING if is_still else State.RUNNING
			if is_on_wall() and hand_checker.is_colliding() and foot_checker.is_colliding():
				return State.WALL_SLIDING
		State.LANDING:
			if not is_still:
				return State.RUNNING
			if not animation_player.is_playing():
				return State.IDLE
		State.WALL_SLIDING:
			if is_on_floor():
				return State.IDLE
			if not is_on_wall():
				return State.FALL
	return state

# 转换
func transition_state(from: State,to: State) -> void:
	if from not in GROUND_STATUS and to in GROUND_STATUS:
		coyote_timer.stop()
	
	match to:
		State.IDLE:
			animation_player.play("idle")
		State.RUNNING:
			animation_player.play("running")
		State.JUMP:
			animation_player.play("jump")
			velocity.y = JUMP_VELOCITY
			coyote_timer.stop()
			jump_request_timer.stop()
		State.FALL:
			animation_player.play("fall")
			if from in GROUND_STATUS:
				coyote_timer.start()
		State.LANDING:
			animation_player.play("landing")
		State.WALL_SLIDING:
			animation_player.play("wall_sliding")
	is_first_tick = true
