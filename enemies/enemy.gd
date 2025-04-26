class_name Enemy
extends CharacterBody2D

# 敌人面朝的方向
enum Diection {
	LEFT = -1,
	RIGHT = +1,
}

@export var direction := Diection.LEFT:
	set(v):
		direction = v
		# 等待节点ready
		if not is_node_ready():
			await ready
		graphics.scale.x = -direction

@export var max_speed: float = 180
@export var acceleration: float = 2000

var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float

@onready var graphics: Node2D = $Graphics
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine
@onready var status: Status = $Status


func move(speed: float, delta: float) -> void:
	# 修改速度向量
	velocity.x = move_toward(velocity.x, speed * direction,acceleration  * delta) 
	velocity.y +=  default_gravity * delta
	
	move_and_slide()
