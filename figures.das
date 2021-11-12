require utils
require daslib/media

let MAX_PTS = 5

struct Shape
    points: float2[MAX_PTS]
    pointsCur: float2[MAX_PTS]
    intersected: bool[MAX_PTS]
    intersections: float2[MAX_PTS]
    numPts: int
    numIntersections:int
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
    shape: Shape



let speed = 15.
let speedZ = speed
let sin_aov = sin(PI/3.)
let speedX = speed *10.
let deltaX = 100.
let numPositions = 7
let startDirAngle = [[float[numPositions] -3.*PI/8.; -PI/4.; -PI/8.; 0.; PI/8.; PI/4.; 3.*PI/8.]] 

let killZone = [[float[2] 10.; 17.]]
let period = 1.

var figures: array<Figure>
var id_counter = 0
var gen = period
var cnt = 0

def test_line_figure_intersection(a0: float2; a1: float2; var fig: Figure) :bool
    for i in range (0, fig.shape.numPts)
        var j = i==fig.shape.numPts - 1 ? 0 : i+1
        if !fig.shape.intersected[i] && test_lines_intersection (a0, a1, fig.shape.pointsCur[i], fig.shape.pointsCur[j], fig.shape.intersections[i])
            fig.shape.intersected[i] = true
            fig.shape.numIntersections ++


    if fig.shape.numIntersections >1
        cut_figure(fig)
        return true
    return false        

def make_figure(center:float2; z:float;pts:array<float2>; vel_:float2; w:float = 1.; start: int; can_cut:bool = true): Figure
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
     
    for i in range (0, min(length(pts), MAX_PTS)) 
        fig.shape.points[i] = pts[i] 
        fig.shape.numPts++
    return fig

def rot_vec(v:float2; angle:float):float2
    var rotatedVec:float2
    rotatedVec.x = v.x *cos(angle) - v.y * sin(angle)
    rotatedVec.y = v.y *cos(angle) + v.x * sin(angle)
    return rotatedVec

def generate_figures(dt:float)
    gen += dt
    if gen < period
        return
    gen = 0.

    let start = (cnt++) % 7 
    var scrCenter = float2(get_screen_width()/2, get_screen_height()/2 + 100) 
    var pts: array<float2>
    pts|> push(float2(-5, -4)) 
    pts|> push(float2(3, -5)) 
    pts|> push(float2(4, 3)) 
    pts|> push(float2(-6, 6))  
    scrCenter.x += deltaX * float(start) - float(numPositions)/2.*deltaX
    figures|> push(make_figure(scrCenter,0.,pts,float2(0,0), 0.,start))


def update_color(var fig:Figure)
    if fig.z < killZone[0]
        fig.color.w =min(fig.z/killZone[0], 1.)
    elif fig.z >= killZone[0] && fig.z <killZone[1] 
        fig.color.w = 1.
    else     
        fig.color.w =max(1. - (fig.z - killZone[1])/killZone[1], 0.3)


def scale_figure(var fig: Figure;dt: float)
    fig.z += speedZ *dt
    fig.scale = sin_aov * fig.z

def rotate_figure(var fig: Figure;dt: float)    
    fig.angle += fig.w * dt

def shift_figure(var fig: Figure;dt: float)
    fig.pos.x = fig.pos.x + 20.* speedZ *dt * sin(startDirAngle[fig.startPos])
    fig.pos.x += fig.vel.x * dt 
    fig.pos.y += fig.vel.y * dt 

def validate_figure(var fig: Figure)
    for i in range (0, fig.shape.numPts)
        fig.shape.pointsCur[i] = float2(fig.pos.x, fig.pos.y) + fig.scale * rot_vec(fig.shape.points[i], fig.angle)

def move_figure(var fig: Figure; dt:float)
    scale_figure(fig, dt)
    update_color(fig)
    shift_figure(fig, dt)
    rotate_figure(fig, dt)

def cut_figure(var fig:Figure)
    var fig1:array<float2>[2]
    var idx:int = 0
    var norm:float2

    for i in range (0, fig.shape.numPts)
        if fig.shape.intersected[i]
            fig1[idx]|>push(fig.shape.points[i])
            var inter = (fig.shape.intersections[i] - float2(fig.pos.x,fig.pos.y)) / fig.scale
            inter = rot_vec(inter, - fig.angle)
            if idx ==0
                norm = fig.shape.intersections[i]
            else
                norm -= fig.shape.intersections[i]
            fig1[0]|>push(inter)
            fig1[1]|>push(inter)
            idx ^=1;
        else    
            fig1[idx]|>push(fig.shape.points[i])

    let startSpeed = 100.
    norm = normalize(rot_vec(norm, PI/2.)) * startSpeed
    let wStart = 0.5
    figures|> push(make_figure(fig.pos,fig.z,fig1[0], -norm, fig.w + wStart,fig.startPos, false))
    figures|> push(make_figure(fig.pos,fig.z,fig1[1], norm, fig.w - wStart,fig.startPos, false))


def draw_figures
    if figures|> empty()
        return
    for fig in figures
        validate_figure(fig)
        for i in range(0, fig.shape.numPts)
            var j = i==fig.shape.numPts - 1 ? 0 : i+1
            line(fig.shape.pointsCur[i].x, fig.shape.pointsCur[i].y,fig.shape.pointsCur[j].x, fig.shape.pointsCur[j].y,make_color(fig.color.x,fig.color.y, fig.color.z, fig.color.w))