extends KinematicBody

onready var cam  = $CamBase
#onready var anim = $Graphics

var velocity = Vector3()
signal velocity(v)
var jump_cooldown = 0
var air_time = 0
var snap_vector = Vector3(0,0,0)

var time_on_wall = 1

var m_yaw = 0.022
var sens = 0.8

var captured = false

var tick = 0

onready var gravity_vector : Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
onready var gravity_magnitude : float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
 
func _input(event):
    if event is InputEventMouseMotion and captured:
        cam.rotation_degrees.x -= event.relative.y * m_yaw * sens
        cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
        rotation_degrees.y -= event.relative.x * m_yaw * sens
    
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT and event.pressed:
            if not captured:
                Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
                captured = true
            else:
                Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
                captured = false
            
                
 

func _physics_process(delta):
    var vec = Vector3()
    
    var normed = velocity
    var l = normed.length()
    normed.normalized()
    var m
    if is_actually_on_wall():
        m = min(time_on_wall * 100, 30)
    else:
        m = 0
    normed *= max(m, 8 * pow(l,0.2))
    var friction = Vector3(0.2, 0.2, 0.2)

    if is_actually_on_wall():
        #if air_time > 0:
        #   print("air time: ", air_time)
        air_time = 0
    else:
        air_time += delta
        friction.z = 0.0
    
    normed = normed.rotated(Vector3(0,1,0), -rotation.y)
    normed *= friction
    normed = normed.rotated(Vector3(0,1,0), rotation.y)
    velocity -= normed * delta
    
    var accel
    if is_actually_on_wall():
        time_on_wall += delta
        accel = 60
        if Input.is_action_pressed("move_forward"):
            vec.z = -1.0
        if Input.is_action_pressed("move_backward"):
            vec.z = 1.0
        if Input.is_action_pressed("move_left"):
            vec.x = -1.0
        if Input.is_action_pressed("move_right"):
            vec.x = 1.0
    else:
        time_on_wall = 0
        accel = 20
        if Input.is_action_pressed("move_left"):
            vec.x = -1.0
        if Input.is_action_pressed("move_right"):
            vec.x = 1.0
                
    vec = vec.normalized()
    
    if tick % 30 == 0:
        print(vec)
    
    vec = vec.rotated(Vector3.UP, rotation.y)
    vec *= accel
    velocity = vec * delta + velocity
    
    if not is_actually_on_wall():
        velocity += delta*gravity_magnitude*gravity_vector
    else:
        velocity.y = 0
    
    jump_cooldown += delta
    
    velocity += delta * accel * snap_vector
    
    var collision
    if is_on_wall():
        for i in get_slide_count():
            collision = get_slide_collision(i)
        snap_vector = -collision.normal
        #print(collision.collider.name)
        #print(collision.normal)
    else:
        $RayCast.cast_to = snap_vector
        if not $RayCast.is_colliding():
            snap_vector = Vector3(0,0,0)
    
    
    if Input.is_action_just_pressed("move_jump") and jump_cooldown > 0.04:
        print(normed)
        if is_actually_on_wall():
            print("on floor")
            velocity += delta * -snap_vector * 450
        else:
            print("in air")
            pass
           #velocity += delta * Vector3.UP * 360
        jump_cooldown = 0
        #velocity.y = 6.0
        snap_vector = Vector3(0,0,0)
        
    if is_actually_on_wall():
        velocity = move_and_slide_with_snap(velocity, 2*snap_vector, Vector3(0,0,0))
    else:
        velocity = move_and_slide(velocity, Vector3(0,0,0))
    
    emit_signal("velocity", velocity)
    
    if is_actually_on_wall() and vec.normalized().dot(snap_vector) < -0.1:
        snap_vector = Vector3(0,0,0)
        
    if tick % 60 == 0:
        print("angle: ", (vec.normalized()).dot(snap_vector))
        #print(Vector2(velocity.x, velocity.z).length()," ", normed.length())
    tick+=1


func is_actually_on_wall():
    return snap_vector != Vector3(0,0,0)
