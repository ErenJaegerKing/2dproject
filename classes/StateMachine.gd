extends Node
## 角色状态机
class_name StateMachine

# 状态变量与setter
var current_state: int = -1:
	set(v):
		owner.transition_state(current_state,v)
		current_state = v
		state_time = 0

var state_time: float

func _ready() -> void:
	# 等待父节点(owner)完成初始化
	await owner.ready
	current_state = 0

# 状态更新循环 (_process)
func _physics_process(delta: float) -> void:
	while true:
		var next := owner.get_next_state(current_state) as int
		if current_state == next:
			break
		current_state = next
		
	owner.tick_physics(current_state, delta)
	state_time += delta
