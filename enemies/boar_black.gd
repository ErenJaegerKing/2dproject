extends Enemy

enum State {
	IDLE,
	WALK,
	RUN,
	HURT,
	DYING,
}

const KNOCKBACK_AMOUNT := 512.0

var pending_damage: Damage
# 转身
var isRunBack := false

@onready var wall_checker: RayCast2D = $Graphics/WallChecker
@onready var player_checker: RayCast2D = $Graphics/PlayerChecker
@onready var floor_checker: RayCast2D = $Graphics/FloorChecker
@onready var calm_down_timer: Timer = $CalmDownTimer

# 节点分组为enemies
# func _ready() -> void:
#	add_to_group("enemies")

func can_see_player() -> bool:
	if not player_checker.is_colliding():
		return false
	return player_checker.get_collider() is Player

# 每一帧的逻辑
func tick_physics(state: State,delta:float) -> void:
	match state:
		State.IDLE,State.HURT,State.DYING:
			move(0.0,delta)
		State.WALK:
			move(max_speed / 3, delta)
		State.RUN:
			if wall_checker.is_colliding() or not floor_checker.is_colliding():
				direction *= -1
			move(max_speed,delta)
			
			# 转身
			if not can_see_player() and calm_down_timer.time_left < 1.0 and not isRunBack:
				direction *= -1
				isRunBack = true
				move(max_speed,delta)
			
			if can_see_player():
				calm_down_timer.start()
				isRunBack = false


# 获取下一个状态
func get_next_state(state:State) -> int:
	if status.health == 0:
		return StateMachine.KEEP_CURRENT if state == State.DYING else State.DYING
	
	if pending_damage:
		return State.HURT
	
	match state:
		State.IDLE:
			# 野猪碰见玩家则立即冲向玩家
			if can_see_player():
				return State.RUN
			# 野猪空闲超过2秒则进入走动状态
			if state_machine.state_time > 2:
				return State.WALK
		
		State.WALK:
			# 野猪碰到墙壁或者前面没路的时候进入空闲状态
			if can_see_player():
				return State.RUN
			if wall_checker.is_colliding() or not floor_checker.is_colliding():
				return State.IDLE
		
		State.RUN:
			# 野猪的冷静计时器到点后，进入走动状态
			if not can_see_player() and calm_down_timer.is_stopped():
				return State.WALK
		
		State.HURT:
			if not animation_player.is_playing():
				return State.RUN
	# 保持当前状态不变
	return StateMachine.KEEP_CURRENT


# 状态转换
func transition_state(from: State, to: State) -> void:
	#print("[%s] %s => %s" %[
		#Engine.get_physics_frames(),
		#State.keys()[from] if from != -1 else "<START>",
		#State.keys()[to],
	#])
	
	match to:
		State.IDLE:
			animation_player.play("idle")
			# 如果前方是墙，则野猪转身
			if wall_checker.is_colliding():
				direction *= -1
		State.WALK:
			animation_player.play("walk")
			# 如果前方是悬崖，则野猪转身
			if not floor_checker.is_colliding():
				direction *= -1
				# 转身后强制更新射线的缓存
				floor_checker.force_raycast_update()
		State.RUN:
			animation_player.play("run")
		
		State.HURT:
			animation_player.play("hit")
			
			# 受伤后扣血并被击退
			status.health -= pending_damage.amount
			var dir := pending_damage.source.global_position.direction_to(global_position)
			velocity = dir * KNOCKBACK_AMOUNT
			
			# 获得受击伤害方向
			if dir.x > 0:
				direction = Direction.LEFT
			else:
				direction = Direction.RIGHT
			
			pending_damage = null
			
			
		State.DYING:
			animation_player.play("die")
	


func _on_hurt_box_hurt(hitbox: HitBox) -> void:
	pending_damage = Damage.new()
	pending_damage.amount = 1
	pending_damage.source = hitbox.owner
	
