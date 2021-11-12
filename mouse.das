require daslib/media
require utils

let mouse_pos_history_len = 6
var posHistory: array<float2>


def update_mouse_trace()
    let mousePos = get_mouse_position()
    push(posHistory, mousePos)
    if(length(posHistory) > mouse_pos_history_len)
        erase(posHistory, 0)

def draw_mouse_trace()
    if !can_cut()
        return
    for i in range (1, length(posHistory))
        var coeff = float(i)/float(length(posHistory))
        let color = make_color(1.,1.,1.,coeff)
        line(posHistory[i-1].x,posHistory[i-1].y, posHistory[i].x,posHistory[i].y, color)
   

def can_cut(): bool
    if length(posHistory) == mouse_pos_history_len
        return vec_lengthSq(posHistory[0], posHistory[mouse_pos_history_len-1]) >= sqr(150.)
    else
        return false     