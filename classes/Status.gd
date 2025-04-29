## 对象状态存放
class_name Status
extends Node

# 先export初始化，然后再onready初始化
@export var max_health: int = 3

@onready var health: int = max_health:
	set(v):
		v = clampi(v,0,max_health)
		if health == v:
			return
		health = v
