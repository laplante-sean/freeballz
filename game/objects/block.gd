extends CharacterBody2D
class_name Block

signal hit_game_floor()

const BlockBreakParticlesComponentScene = preload("res://game/components/block_break_particles_component.tscn")

var max_health: int = 1
var health: int = 1 : set = set_health
var width: int = 50
var collision_shape : RectangleShape2D = null
var current_color: Color = Color.WHITE
var starting_color: Color = Color.WHITE
var top_left: Vector2 = Vector2.ZERO
var top_right: Vector2 = Vector2.ZERO
var bottom_right: Vector2 = Vector2.ZERO
var bottom_left: Vector2 = Vector2.ZERO
var floor_pos: float = 0.0

@onready var game_stats = Utils.get_game_stats()
@onready var collider = $Collider
@onready var label = $Label
@onready var light_occluder_2d = $LightOccluder2D


func setup(b_width: int, b_health: int):
    width = b_width
    health = b_health
    max_health = b_health
    top_left = Vector2(-width / 2.0, -width / 2.0)
    top_right = Vector2(width / 2.0, -width / 2.0)
    bottom_right = Vector2(width / 2.0, width / 2.0)
    bottom_left = Vector2(-width / 2.0, width / 2.0)


func _ready():
    # NOTE: The collider, and the BottomDetector/Collider share the same collision shape
    # so we only need to set the extents of one.
    collider.shape.extents = Vector2(width / 2.0, width / 2.0)
    label.text = str(health)
    starting_color = get_block_color()
    floor_pos = Utils.get_game_floor_y_pos()

    setup_occluder()


func setup_occluder():
    # The polygon is a shared resource b/w all blocks, so we only have to do this once
    var occluder: OccluderPolygon2D = light_occluder_2d.occluder as OccluderPolygon2D
    if occluder.polygon[1] != Vector2.ZERO:
        return

    # Setup the corners of the polygon
    occluder.polygon[0] = top_left
    occluder.polygon[1] = top_right
    occluder.polygon[2] = bottom_right
    occluder.polygon[3] = bottom_left


func get_block_color() -> Color:
    var hue_angle = game_stats.block_hue_start
    hue_angle = ((hue_angle + (health * 15)) + health)
    var hue = hue_angle / 360
    hue -= int(hue)
    current_color = Color.from_hsv(hue, game_stats.block_saturation / 100.0, game_stats.block_brightness / 100.0)
    return current_color


func _draw():
    var points : PackedVector2Array = PackedVector2Array([
        top_left, top_right, bottom_right, bottom_left])
    draw_colored_polygon(points, get_block_color())


func _process(_delta):
    if (global_position.y + width / 2.0) >= floor_pos:
        hit_game_floor.emit()

    queue_redraw()


func set_health(value):
    health = max(value, 0)
    if label != null:
        label.text = str(health)
    if health == 0:
        explode()
        queue_free()


func explode():
    var effect: BlockBreakParticlesComponent = BlockBreakParticlesComponentScene.instantiate()
    effect.block_color = current_color
    effect.block_width = width
    get_tree().current_scene.add_child(effect)
    effect.global_position = global_position


func hit():
    var hit_tween = get_tree().create_tween()
    hit_tween.tween_property(self, "scale", Vector2(1.075, 1.075), 0.10)
    hit_tween.chain().tween_property(self, "scale", Vector2(1, 1), 0.15)
    health -= 1


func destroy():
    health = 0
