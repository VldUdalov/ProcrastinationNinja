require daslib/media

struct Particle
    pos: float2
    vel: float2
    lifetime: float
def Particle(p_:float2; v_: float2; t_:float)
    return <- [[Particle pos = p_, vel = v_, lifetime = t_ ]]

struct Splash
    parts: array<Particle>
    color:uint

var splashes:array<Splash> 
let num_particles = 16

def add_splash(pos: float2; vel: float2; var seed:int4)
    var splash: Splash
    splash.color = 0xFFF51111
    var dir = normalize(vel)



    for i in range(0, num_particles)
        let deviation = 200.
        let w0 = float2(deviation * random_float(seed), deviation *random_float(seed))
        let posLoc  = pos - dir *(300. * random_float(seed))
        let lifetime = 1. + random_float(seed)
        splash.parts|> push(Particle(posLoc, vel + w0, lifetime))
    
    splashes|>push_clone(splash)

def update_splashes(dt: float)
    var j = 0
    while j< length(splashes)
        var i =0
        while i < length(splashes[j].parts)
            splashes[j].parts[i].pos += splashes[j].parts[i].vel * dt 
            splashes[j].parts[i].vel.y += 200.8 * dt
            splashes[j].parts[i].lifetime -= dt
            if(splashes[j].parts[i].lifetime < 0.)
                splashes[j].parts |> erase(i)
                i--
            i++
        if(length(splashes[j].parts) == 0)
            splashes |> erase(j)
            j--  
        j++    

def draw_splashes
    for splash in splashes
        for part in splash.parts
            set_pixel(part.pos.x, part.pos.y, splash.color)