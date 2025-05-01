extends HBoxContainer

@export var status: Status

@onready var health_bar: TextureProgressBar = $V/HealthBar
@onready var eased_health_bar: TextureProgressBar = $V/HealthBar/EasedHealthBar
@onready var energy_bar: TextureProgressBar = $V/EnergyBar



func _ready() -> void:
	if not status:
		status = Game.player_status
	
	status.health_changed.connect(update_health)
	update_health(true)
	
	status.energy_changed.connect(update_energy)
	update_energy()
	# 4.2+
	tree_exited.connect(func ():
		status.health_changed.disconnect(update_health)
		status.energy_changed.disconnect(update_energy)
	)

func update_health(skip_anim := false) -> void:
	var percentage := status.health / float(status.max_health)
	health_bar.value = percentage
	
	if skip_anim:
		eased_health_bar.value = percentage
	else: 
		create_tween().tween_property(eased_health_bar,"value",percentage,0.8)

func update_energy() -> void:
	var percentage := status.energy / status.max_energy
	energy_bar.value = percentage
	
