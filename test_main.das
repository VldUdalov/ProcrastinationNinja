require daslib/media
options debugger
require daslib/debug
require utils
require figures
require mouse

let scrHeight = float(get_screen_height())
let scrWidth = float(get_screen_width())

[export]
def initialize
    set_window_title("test")

[export]
def act(dt: float)
    generate_figures(dt)
    update_mouse_trace()
    let canCut = can_cut()    

    var i = 0
    while i < length(figures)
        var f:Figure& = figures[i]
        move_figure(f, dt)

        if f.z >=  50. || f.pos.x > scrWidth || f.pos.x < 0.
            erase(figures, i)
            i--
        if canCut && f.canCut && f.z>killZone[0] && f.z <killZone[1]
            if test_line_figure_intersection(posHistory[0], posHistory[mouse_pos_history_len - 1], f)
                erase(figures, i)
                i--
        i++    

    if get_key(VK_ESCAPE)
        schedule_quit_game()
    return

[export]
def draw
    enable_alpha_blend()
    draw_figures()
    draw_mouse_trace()
    disable_alpha_blend()
    return
