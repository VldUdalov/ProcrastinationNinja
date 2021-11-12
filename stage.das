require daslib/media

let NUM_STAGES = 5
let periods = [[float[NUM_STAGES] 1.; 0.8; 0.6 ; 0.4; 0.2]]
let deviations = [[float[NUM_STAGES] 100.; 150.; 200. ; 300.; 500.]]
let scales = [[float[NUM_STAGES] 1.; 0.8; 0.5 ; 0.2; 0.1]]

let hits_in_stage = 20 
var hit_cnt = 0
var cur_stage_index = 0
var miss_alpha = -1.
var miss = 0
var countdown = 7.
let textPos = float2(float(get_screen_width())/2. - 70., 20.)
let missPos = float2(float(get_screen_width())/2., float(get_screen_height())/2.)


def register_hit
    hit_cnt++

def register_miss
    if hit_cnt > 0
        miss_alpha = 1.
        miss = hit_cnt >= 5 ? 5: hit_cnt
    hit_cnt = max(hit_cnt - 5, 0)
    

def update_stage(dt:float)
    if hit_cnt == hits_in_stage //* stages[cur_stage]
        cur_stage_index = (cur_stage_index +1) % NUM_STAGES
        hit_cnt = 0
    update_miss(dt)


def get_period():float
    return periods[cur_stage_index]

def get_scale():float
    return scales[cur_stage_index]

def get_y_deviation(): float
    return deviations[cur_stage_index]

def draw_stage
    let out = "hits: {hit_cnt} stage: {cur_stage_index +1}"
    text_out(textPos.x,textPos.y, out, 0xFFF51111)

def update_countdown(dt:float)
    if countdown > 0.
        countdown -=dt

def is_countdown()
    return countdown >= 0.

def draw_countdown
    if countdown > 0.
        let out = "{int(countdown)+1}"
        text_out(missPos.x,missPos.y, out, 0xFFFFFFFF)    

def update_miss(dt:float)
    if miss_alpha>=0.
        miss_alpha-= dt

def draw_miss
    if miss_alpha>=0.
        let out = "-{miss}"
        let color = make_color(0.7,0., 0., miss_alpha)
        text_out(missPos.x,missPos.y, out, color)    