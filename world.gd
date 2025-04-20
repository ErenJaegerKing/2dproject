extends Node2D

@onready var trunk: TileMapLayer = $TileMap/Trunk
@onready var camera_2d: Camera2D = $Player/Camera2D


func _ready() -> void:
	var used := trunk.get_used_rect()
	var tile_size := trunk.tile_set.tile_size
	
	camera_2d.limit_top = used.position.y * tile_size.y
	camera_2d.limit_right = used.end.x * tile_size.x
	camera_2d.limit_bottom = used.end.y * tile_size.y
	camera_2d.limit_left = used.position.x * tile_size.x
	camera_2d.reset_smoothing()
