extends GPUParticles2D
class_name BlockBreakParticlesComponent

@export var block_color: Color = Color.WHITE
@export var block_width: float = 0.0

@onready var game_stats = Utils.get_game_stats()


func _ready():
    one_shot = true
    process_material.emission_box_extents = Vector3(block_width / 2.0, block_width / 2.0, 1)
    modulate = block_color
    finished.connect(queue_free)
    set_deferred("emitting", true)
