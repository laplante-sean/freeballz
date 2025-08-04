extends GPUParticles2D
class_name CoinSparkleParticlesComponent

@export var color: Color = Color.WHITE


func _ready():
    one_shot = true
    modulate = color
    finished.connect(queue_free)
    set_deferred("emitting", true)
