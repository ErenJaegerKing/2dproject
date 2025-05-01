extends Node

# 场景的名称 => {
#	enemies_alive => [ 敌人的路径 ]
#} 
# 保存场景状态
var world_status := {
	
}

@onready var player_status: Status = $PlayerStatus
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.color.a = 0

func change_scene(path: String,entry_point: String) -> void:
	var tree := get_tree()
	
	tree.paused = true
	
	# 动画转场
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect,"color:a",1,0.2)
	await  tween.finished
	
	# 保持场景状态
	var old_name := tree.current_scene.scene_file_path.get_file().get_basename()
	world_status[old_name] = tree.current_scene.to_dict()
	
	
	tree.change_scene_to_file(path)
	await tree.tree_changed
	
	# 保持场景状态
	var new_name := tree.current_scene.scene_file_path.get_file().get_basename()
	if new_name in world_status:
		tree.current_scene.from_dict(world_status[new_name])
	
	for node in tree.get_nodes_in_group("entry_points"):
		if node.name == entry_point:
			tree.current_scene.update_player(node.global_position, node.direction)
			break
	
	tree.paused = false
	tween = create_tween()
	tween.tween_property(color_rect,"color:a",0,0.2)
