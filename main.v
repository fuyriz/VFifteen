module main

import time
import gg
import gx
import rand
import strconv
import utils

struct App {
mut:
	gg          	&gg.Context = unsafe { nil }
	field			[4][4]u8
	moves			u32
	frame_counter	u64
	txtcfg			gx.TextCfg
	timer_started   bool
    start_time      u64
    elapsed_time    u64
	is_solved		bool
}

const window_title = 'PyatnaVVki'
const default_window_width = 900
const default_window_height = 1200

const padding = 10

fn (mut app App) draw() {
    app.gg.draw_text(50, 100, "Moves: ${app.moves}", gx.TextCfg{
        size: 60
        color: gx.black
        vertical_align: .middle
    })

    // Отображение времени, если таймер запущен
    if app.timer_started || app.is_solved {
		if !app.is_solved {app.elapsed_time = u64(time.now().unix_time()) - app.start_time}
        app.gg.draw_text(50, 150, "Time: ${app.elapsed_time} seconds", gx.TextCfg{
            size: 60
            color: gx.black
            vertical_align: .middle
        })
    }

    app.gg.draw_rounded_rect_filled(50, 200, 800, 800, 5, gx.gray)
    mut xc, mut yc := 50 + padding / 2, 200 + padding / 2
    tsize := 200 - padding
    for i in 0 .. 4 {
        for j in 0 .. 4 {
            if app.field[i][j] == 0 { xc += tsize + padding; continue }
            app.gg.draw_rounded_rect_filled(xc, yc, tsize, tsize, 10, gx.rgb(4, 79, 53))
            app.gg.draw_text(xc + tsize / 2, yc + tsize / 2, "${app.field[i][j]}", app.txtcfg)
            xc += tsize + padding
        }
        xc = 50 + padding / 2
        yc += tsize + padding
    }
}

fn frame(mut app App) {
    app.gg.begin()
    app.draw()
    app.frame_counter++
    if app.frame_counter % 180 == 0 {
        //app.print_field()
		//println(app.is_solved())
    }
    app.gg.end()
}

fn (app &App) print_field() {
	for i in 0 .. 4 {
		for j in 0 .. 4 {
			unsafe{strconv.v_printf('%2d ', app.field[i][j])}
		}
		println("")
	}
	println("============")
}

fn (mut app App) scramble() {
	mut unused := []u8{len: 16}
	for i in 0..16 {unused[i] = u8(i)}
	for i in 0 .. 4 {
		for j in 0 .. 4 {
			mut idx := rand.u32_in_range(0, u32(unused.len)) or {panic("Error: 1")}
			app.field[i][j] = unused[idx]
			unused = utils.delete(mut unused, idx)
		}
	}
}

fn (mut app App) new_game() {
    app.scramble()
	for !utils.is_solvable(app.field) || app.is_solved(){
		app.scramble()
	}
    app.moves = 0
	app.timer_started = false
	app.is_solved = false
	app.elapsed_time = 0
}

fn (app &App) is_solved() bool {
	mut expected := u8(1)
	for i in 0 .. 15 {
		if app.field[i / 4][i % 4] != expected {return false}
		expected++
	}
	return true
}


fn init(mut app App) {
	app.resize()
	app.new_game()
}

fn (mut app App) handle_tap(x i32, y i32) {
    if x < 50 || x > 850 { return }
    if y < 200 || y > 1000 { return }
    ny, nx := (x - 50) / 200, (y - 200) / 200
    if app.field[nx][ny] != 0 {
        if nx != 0 && app.field[nx-1][ny] == 0 { app.field[nx][ny], app.field[nx-1][ny] = app.field[nx-1][ny], app.field[nx][ny]; app.moves++; }
        if ny != 0 && app.field[nx][ny-1] == 0 { app.field[nx][ny], app.field[nx][ny-1] = app.field[nx][ny-1], app.field[nx][ny]; app.moves++; }
        if nx != 3 && app.field[nx+1][ny] == 0 { app.field[nx][ny], app.field[nx+1][ny] = app.field[nx+1][ny], app.field[nx][ny]; app.moves++; }
        if ny != 3 && app.field[nx][ny+1] == 0 { app.field[nx][ny], app.field[nx][ny+1] = app.field[nx][ny+1], app.field[nx][ny]; app.moves++; }
        //timer
        if !app.timer_started {
            app.timer_started = true
            app.start_time = u64(time.now().unix_time())
        }
		app.is_solved = app.is_solved()
    }
}

fn on_event(e &gg.Event, mut app App) {
	match e.typ {
		.mouse_up {
			app.handle_tap(i32(e.mouse_x), i32(e.mouse_y))
		}
		.key_down {
			app.on_key_down(e.key_code)
		}
		else {}
	}
}

fn (mut app App) resize() {

}

fn (mut app App) on_key_down(key gg.KeyCode) {
	// these keys are independent from the game state:
	match key {
		.escape { app.gg.quit() }
		.n, .r { app.new_game() }
		else{}
	}
}

fn main() {
	mut app := &App{}
	app.txtcfg = gx.TextCfg {
		color: gx.white
		size: 69
		align: .center
		vertical_align: .middle
	}
	app.gg = gg.new_context(
		bg_color: gx.white
		width: default_window_width
		height: default_window_height
		window_title: window_title
		frame_fn: frame
		init_fn: init
		event_fn: on_event
		user_data: app
	)
	app.gg.run()
}