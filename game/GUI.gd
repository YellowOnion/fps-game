extends CanvasLayer

var coff_kmph = 3600/1000 


func update_speed(speed):
    $HBoxContainer/Speed.text = "%04.1f" % (to_kmph(speed))
    
func to_kmph(speed):
    var s = Vector2(speed.x, speed.z).length()
    return coff_kmph * s


