require daslib/media
options debugger
require daslib/debug
require utils
require figures
require mouse
require fx
require soundWork
require stage

let scrWidth = float(get_screen_width())
var seed:int4

[export]
def initialize
    set_window_title("Procrastination Ninja")
    init_sound()
    randomize_seed(seed)

[export]
def act(dt: float)
    update_sound(dt)
    if is_countdown()
        update_countdown(dt)
        return
    generate_figures(dt, seed)
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
            if test_line_figure_intersection(posHistory[0], posHistory[mouse_pos_history_len - 1], f, seed)
                erase(figures, i)
                update_sound_delay()
                register_hit()
                i--
        if f.canCut && f.z > killZone[1]
            register_miss()
            f.canCut = false
        i++    

    update_stage(dt)
    update_splashes(dt)
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    return

[export]
def draw
    enable_alpha_blend()
    draw_figures()
    draw_mouse_trace()
    draw_miss()
    draw_countdown()
    disable_alpha_blend()
    draw_splashes()
    draw_stage()

    return
