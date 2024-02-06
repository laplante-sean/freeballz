extends CharacterBody2D
class_name Block

var health: int = 1 : set = set_health
var width: int = 50
var color: Color = Color.RED
var collision_shape : RectangleShape2D = null

@onready var collider = $Collider
@onready var label = $Label


func setup(w: int, c: Color, h: int):
    width = w
    color = c
    health = h


func _ready():
    collision_shape = RectangleShape2D.new()
    collision_shape.extents = Vector2(width / 2.0, width / 2.0)
    collider.shape = collision_shape
    collider.position.x += width / 2.0
    collider.position.y += width / 2.0
    label.position.x += width / 2.0
    label.position.y += width / 2.0
    label.text = str(health)


func _draw():
    var points : PackedVector2Array = PackedVector2Array([
        Vector2.ZERO,
        Vector2(width, 0),
        Vector2(width, width),
        Vector2(0, width)
    ])

    draw_colored_polygon(points, color)


func _process(_delta):
    queue_redraw()


func set_health(value):
    health = max(value, 0)
    if label != null:
        label.text = str(health)
    if health == 0:
        queue_free()


func hit():
    health -= 1
