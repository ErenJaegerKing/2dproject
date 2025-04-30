extends HBoxContainer

@export var status: Status

@onready var health_bar: TextureProgressBar = $V/HealthBar
@onready var eased_health_bar: TextureProgressBar = $V/HealthBar/EasedHealthBar
@onready var energy_bar: TextureProgressBar = $V/EnergyBar



func _ready() -> void:
	status.health_changed.connect(update_health)
	update_health()
	
	status.energy_changed.connect(update_energy)
	update_energy()

func update_health() -> void:
	var percentage := status.health / float(status.max_health)
	health_bar.value = percentage
	
	create_tween().tween_property(eased_health_bar,"value",percentage,0.8)

func update_energy() -> void:
	var percentage := status.energy / status.max_energy
	energy_bar.value = percentage
	
