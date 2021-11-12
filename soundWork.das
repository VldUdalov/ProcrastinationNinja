require daslib/media
require utils
require fio

var
    musicLoop: PcmSound
    handle: PlayingSoundHandle

var start_delay = 0.
var vol = 0.3
var curVol = 0.
let playing_time_max = 1.1
var playing_time = -1.
var penalty = 0.1

def init_sound
    let f=fopen("lowing.mp3", "r")
    if f!=null
        fclose(f)
        musicLoop <- create_sound("lowing.mp3")

def update_sound_delay 
    playing_time = playing_time_max

def update_playing_time(dt:float)
    if playing_time > 0.
        playing_time -=dt

def update_sound(dt:float)
    if !is_playing(handle)
        start_delay -=dt
        if start_delay < 0.
            handle = musicLoop |> play_sound_loop(vol,1.)
    else
        update_playing_time(dt)
        let newVol = playing_time < 0. ? vol * penalty: vol;
        if !is_equal_float(curVol, newVol)
            set_sound_volume(handle, newVol)
            curVol = newVol