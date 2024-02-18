extends CharacterBody2D
class_name Ball

const PickupBallSparkleParticlesComponentScene = preload("res://game/components/pickup_ball_sparkle_particles_component.tscn")

enum MovementState {
    MOVING,
    RETURNING
}

@export var is_colletible: bool = false

var direction: Vector2 = Vector2.ZERO
var move_state: MovementState = MovementState.MOVING
var animated_radius = 0
var collectible_tween: Tween
var return_proximity: float = 15.0
var fire_ball: bool = false

@onready var game_stats: GameStats = Utils.get_game_stats()
@onready var player_stats: PlayerStats = Utils.get_player_stats()
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var gpu_particles_2d = $GPUParticles2D


func _ready():
    velocity = Vector2.ZERO
    collision_shape_2d.shape.radius = game_stats.ball_radius
    return_proximity = game_stats.ball_radius

    if is_colletible:
        setup_collectible_ball()


func setup_collectible_ball():
    # Make it collide on the pickup layer
    set_collision_layer_value(4, true)
    collision_shape_2d.shape.radius = game_stats.pickup_ball_collision_radius
    animated_radius = game_stats.pickup_ball_animation_radius_start

    # Create a tween to animate a circle in and out
    collectible_tween = get_tree().create_tween()
    collectible_tween.tween_property(
        self, "animated_radius",
        game_stats.pickup_ball_animation_radius_end,
        game_stats.pickup_ball_animation_duration
    )
    collectible_tween.chain().tween_property(
        self, "animated_radius",
        game_stats.pickup_ball_animation_radius_start,
        game_stats.pickup_ball_animation_duration
    )
    collectible_tween.set_loops()  # Loops forever


func fire(dir: Vector2):
    move_state = MovementState.MOVING
    direction = dir
    
    if fire_ball:
        gpu_particles_2d.emitting = true
        gpu_particles_2d.modulate = game_stats.fire_ball_color


func collect():
    is_colletible = false
    collision_shape_2d.shape.radius = game_stats.ball_radius
    set_collision_layer_value(4, false)
    drop()
    player_stats.balls += 1
    
    var inst = PickupBallSparkleParticlesComponentScene.instantiate()
    get_tree().current_scene.add_child(inst)
    inst.global_position = global_position


func drop():
    move_state = MovementState.MOVING
    direction = Vector2.DOWN
    set_collision_mask_value(2, false)


func _physics_process(delta):
    queue_redraw()

    if direction == Vector2.ZERO:
        return

    match move_state:
        MovementState.MOVING:
            move_ball(delta)
        MovementState.RETURNING:
            return_ball(delta)


func return_ball(delta):
    direction = global_position.direction_to(game_stats.launch_point_global_position)
    velocity = direction * game_stats.ball_speed * delta
    position += velocity
    if global_position.distance_to(game_stats.launch_point_global_position) <= return_proximity:
        gpu_particles_2d.reparent(get_tree().current_scene)  # So visually the particles don't just pop out of exisitence
        gpu_particles_2d.emitting = false
        get_tree().create_timer(gpu_particles_2d.lifetime).timeout.connect(gpu_particles_2d.queue_free)
        queue_free()


func move_ball(delta):
    var speed = game_stats.ball_speed
    if fire_ball:
        speed = game_stats.fire_ball_speed

    velocity = direction * speed
    var collision = move_and_collide(velocity * delta) as KinematicCollision2D
    if collision:
        var collider = collision.get_collider()
        if collider is Block and not fire_ball:
            collider.hit()
        if collider is Block and fire_ball:
            collider.destroy()
        if collider.is_in_group("GameFloor"):
            move_state = MovementState.RETURNING
            return
        if collider.has_method("collect"):
            collider.collect()
            return
        if collider is Block and fire_ball:
            var remainder = collision.get_remainder()
            move_and_collide(remainder)
            return  # Don't bounce off blocks in fire_ball mode

        var reflect = collision.get_remainder().bounce(collision.get_normal())
        direction = direction.bounce(collision.get_normal())
        move_and_collide(reflect)


func _draw():
    var color = game_stats.ball_color
    if fire_ball:
        color = game_stats.fire_ball_color
    
    draw_circle(Vector2.ZERO, game_stats.ball_radius, color)
    if is_colletible:
        draw_arc(Vector2.ZERO, animated_radius, 0, deg_to_rad(360), 100, game_stats.ball_color, 3.5, true)
