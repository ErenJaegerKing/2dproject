extends Node

@onready var sfx: Node = $SFX
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

func play_sfx(name: String) -> void:
	var player := sfx.get_node(name) as AudioStreamPlayer
	if not player:
		return
	player.play()

func play_bgm(stream: AudioStream) -> void:
	if bgm_player.stream == stream and bgm_player.playing:
		return 
	bgm_player.stream = stream
	bgm_player.play()

func setup_ui_sounds(node: Node) -> void:
	var button := node as Button
	if button:
		button.pressed.connect(play_sfx.bind("UIPress"))
		button.focus_entered.connect(play_sfx.bind("UIFocus"))
	
	# 递归标题场景下节点,找到按钮节点，只要是Button就进行信号连接
	for child in node.get_children():
		setup_ui_sounds(child)
