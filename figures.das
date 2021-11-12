require utils
require fx
require daslib/media
require stage

struct Vertice
    pt:float2
    intersections: float2
    intersected:bool
def Vertice(pt_:float2; inter_: float2; intersect_:bool)
    return <- [[Vertice pt = pt_, intersections = inter_, intersected = intersect_ ]]   

struct Figure
    id :int
    canCut:bool
    pos:float2
    z:float
    vel:float2
    scale:float = 1.
    angle:float
    w:float = 2.
    startPos:int
    color: float4
    vertices: array<Vertice>
    numIntersections:int
    numRed :int

let speedZ = 15.
let sin_aov = sin(PI/3.)
let deltaX = 100.
let numPositions = 7
let startDirAngle = [[float[numPositions] -3.*PI/8.; -PI/4.; -PI/8.; 0.; PI/8.; PI/4.; 3.*PI/8.]] 

let killZone = [[float[2] 10.; 20.]]

var figures: array<Figure>
var id_counter = 0
var gen = 0.7
var cnt = 0

def test_line_figure_intersection(a0: float2; a1: float2; var fig: Figure; seed :int4) :bool
    for i in range (0, length(fig.vertices))
        var j = i==length(fig.vertices) - 1 ? 0 : i+1
        var intersection:float2
        if !fig.vertices[i].intersected && test_lines_intersection (a0, a1, fig.vertices[i].pt, fig.vertices[j].pt, fig.vertices[i].intersections)
            fig.vertices[i].intersected = true
            fig.numIntersections ++


    if fig.numIntersections >1
        add_splash(a1, a1-a0, seed)
        cut_figure(fig)
            
        return true
    return false        


def make_figure(center:float2; z:float;pts:array<float2>; vel_:float2; w:float = 1.; start: int; can_cut:bool = true; num_red = -1): Figure
    var fig: Figure
    fig.id = id_counter++
    fig.pos.y = center.y
    fig.pos.x = center.x 
    fig.z = z
    fig.vel = vel_;
    fig.scale = 1.
    fig.canCut = can_cut
    fig.color = float4(1,1,1,1)
    fig.w = w
    fig.startPos = start
    fig. numRed = num_red
     
    for pt in pts 
        fig.vertices|>push(Vertice(fig.pos + pt, float2(0,0), false)) 
    return <-fig

def rot_vec(v:float2; angle:float):float2
    var rotatedVec:float2
    rotatedVec.x = v.x *cos(angle) - v.y * sin(angle)
    rotatedVec.y = v.y *cos(angle) + v.x * sin(angle)
    return rotatedVec

def generate_figures(dt:float; var seed: int4)
    gen += dt
    if gen < get_period()
        return
    gen = 0.
    
    randomize_seed(seed)
    let flStart = 7. *  random_float(seed)
    let start = int(flStart)
    var scrCenter = float2(float(get_screen_width())/2. , float(get_screen_height())/2. + get_y_deviation() *random_float(seed)) 
    var pts: array<float2>
    let r = 5. * get_scale()
    pts|> push(float2(-r, -r)) 
    pts|> push(float2(r, -r)) 
    pts|> push(float2(r, r)) 
    pts|> push(float2(-r, r))  
    let w0 = random_float(seed)
    scrCenter.x += deltaX * float(start) - float(numPositions)/2.*deltaX
    let startVel = float2(0.,50. - 100. *random_float(seed))
    figures|> push_clone(make_figure(scrCenter,0.,pts,startVel, w0,start))


def update_color(var fig:Figure)
    if fig.z < killZone[0]
        fig.color.w =min(fig.z/killZone[0], 1.)
    elif fig.z >= killZone[0] && fig.z <killZone[1] 
        fig.color.w = 1.
    else     
        fig.color.w =max(1. - (fig.z - killZone[1])/killZone[1], 0.3)


def scale_figure(var fig: Figure;dt: float):float
    fig.z += speedZ *dt
    return sin_aov * speedZ *dt * 7.

def rotate_figure(var fig: Figure;dt: float)    
    fig.angle = fig.w * dt

def shift_figure(var fig: Figure;dt: float)
    var shift:float2
    shift.x = 20.* speedZ *dt * sin(startDirAngle[fig.startPos]) + fig.vel.x * dt 
    shift.y = fig.vel.y * dt
    fig.pos += shift
    for i in range (0, length(fig.vertices))
        fig.vertices[i].pt +=shift  

def validate_figure(var fig: Figure;dt: float)
    let dscale = scale_figure(fig, dt)
    for i in range (0, length(fig.vertices))
        var vec = fig.vertices[i].pt - fig.pos
        let len = length(vec)
        let vecScaled = vec/len * (len + dscale)
        let vecRotated = rot_vec(vecScaled, fig.angle)
        fig.vertices[i].pt = fig.pos + vecRotated


def move_figure(var fig: Figure; dt:float)
    update_color(fig)
    shift_figure(fig, dt)
    rotate_figure(fig, dt)
    validate_figure(fig, dt)

def cut_figure(var fig:Figure)
    var fig1:array<float2>[2]
    var idx:int = 0
    var cutDir:float2
    var reds = [[int[2] -1;-1]]
  
    for vert in fig.vertices
        if vert.intersected
            fig1[idx]|>push(vert.pt- fig.pos)
            var inter = (vert.intersections - fig.pos)
            if idx ==0
                cutDir = vert.intersections
            else
                cutDir -= vert.intersections
            if reds[0] < 0
                reds[0] = length(fig1[0])
            elif reds[1] < 0
                reds[1] = length(fig1[1])   
                        
            fig1[0]|>push(inter)
            fig1[1]|>push(inter)
            idx ^=1;
        else    
            fig1[idx]|>push(vert.pt- fig.pos)
     

    let startSpeed = 100.
    let norm = normalize(rot_vec(cutDir, PI/2.)) * startSpeed
    let wStart = 0.5
    figures|> push_clone(make_figure(fig.pos,fig.z,fig1[0], -norm, fig.w + wStart,fig.startPos, false, reds[0]))
    figures|> push_clone(make_figure(fig.pos,fig.z,fig1[1], norm, fig.w - wStart,fig.startPos, false, reds[1]))


def draw_figures
    if figures|> empty()
        return
    for fig in figures
        for i in range(0, length(fig.vertices))
            var j = i==length(fig.vertices) - 1 ? 0 : i+1
            let color = (i == fig.numRed)? make_color(0.7,0., 0., fig.color.w) :make_color(fig.color.x,fig.color.y, fig.color.z, fig.color.w)
                
            line(fig.vertices[i].pt.x, fig.vertices[i].pt.y,fig.vertices[j].pt.x, fig.vertices[j].pt.y, color)