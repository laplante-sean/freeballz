extends Block
class_name BombBlock

@onready var h_collision_shape_2d = $VerticleBombArea/CollisionShape2D
@onready var v_collision_shape_2d = $HorizontalBombArea/CollisionShape2D
@onready var horizontal_bomb_area = $HorizontalBombArea
@onready var verticle_bomb_area = $VerticleBombArea
@onready var explode_area_collision_shape_2d = $ExplodeArea/CollisionShape2D
@onready var explode_area = $ExplodeArea

var laser_width: float = 0.0
var laser_tween: Tween = null
var h_laser_left: Vector2
var h_laser_right: Vector2
var v_laser_top: Vector2
var v_laser_bottom: Vector2
var pending_cleanup: bool = false
var exploding: bool = false


func _ready():
    super._ready()  # Call parent
    v_collision_shape_2d.shape.size.x = width / 2.0
    v_collision_shape_2d.shape.size.y = width * 6.5
    h_collision_shape_2d.shape.size.x = width * 6.5
    h_collision_shape_2d.shape.size.y = width / 2.0

    h_laser_left = Vector2(position.x - ((width * 6.5) / 2.0), 0)
    h_laser_right = Vector2(position.x + ((width * 6.5) / 2.0), 0)

    v_laser_top = Vector2(0, position.y - ((width * 6.5) / 2.0))
    v_laser_bottom = Vector2(0, position.y + ((width * 6.5) / 2.0))

    explode_area_collision_shape_2d.shape.radius = width * 1.5


func get_block_color():
    # Don't call parent method, we're overriding this
    return game_stats.bomb_block_color


func hit():
    if laser_tween == null:
        laser_tween = get_tree().create_tween()
        laser_tween.tween_property(self, "laser_width", game_stats.bomb_block_laser_max_width, 0.25)
        laser_tween.chain().tween_property(self, "laser_width", 0, 0.15)
        laser_tween.finished.connect(_on_laser_tween_finished)
    
    for block in horizontal_bomb_area.get_overlapping_bodies():
        if block == self:
            continue
        if block is BombBlock:
            block.health -= 1  # Don't call hit() b/c recursion
        else:
            block.hit()
    for block in verticle_bomb_area.get_overlapping_bodies():
        if block == self:
            continue
        if block is BombBlock:
            block.health -= 1  # Don't call hit() b/c recursion
        else:
            block.hit()
    super.hit()


func _cleanup():
    if laser_tween != null:
        pending_cleanup = true
        collider.disabled = true
        label.visible = false
    else:
        super._cleanup()


func explode():
    exploding = true
    var effect: BlockBreakParticlesComponent = BlockBreakParticlesComponentScene.instantiate()
    effect.block_color = game_stats.bomb_block_color
    effect.block_width = width
    get_tree().current_scene.add_child(effect)
    effect.global_position = global_position

    # Additions for bomb
    effect.amount *= 2
    var particles = effect.process_material as ParticleProcessMaterial
    particles.direction = Vector3(0, 0, 0)
    particles.spread = 180
    particles.initial_velocity_max = 2000
    particles.initial_velocity_min = 1900

    for block in explode_area.get_overlapping_bodies():
        if block is BombBlock:
            if not block.exploding:
                block.destroy()
        else:
            block.destroy()


func _draw():
    super._draw()
    if laser_width == 0:
        return

    draw_line(h_laser_left, h_laser_right, game_stats.bomb_block_laser_color, laser_width, true)
    draw_line(v_laser_top, v_laser_bottom, game_stats.bomb_block_laser_color, laser_width, true)


func _on_laser_tween_finished():
    laser_tween = null
    if pending_cleanup:
        super._cleanup()
