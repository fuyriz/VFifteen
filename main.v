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
	ui				UI
	field			[4][4]u8
	moves			u32
	frame_counter	u64
	txtcfg			gx.TextCfg
	timer_started   bool
    start_time      u64
    elapsed_time    u64
	is_solved		bool
}

struct UI {
mut:
	window_width	u16
	window_height	u16
	field_size		u16
	tile_padding	u16
	tile_size		u16
	font_size		u16
	f_x				u16
	f_y				u16
}

const window_title = 'PyatnaVVki'
const default_window_width = 900
const default_window_height = 1200

const padding = 10

fn (mut app App) draw() {
    app.gg.draw_text(app.ui.f_x, app.ui.f_y / 2, "Moves: ${app.moves}", gx.TextCfg{
        size: app.ui.font_size
        color: gx.black
        vertical_align: .middle
    })

    if app.timer_started || app.is_solved {
		if !app.is_solved {app.elapsed_time = u64(time.now().unix_time()) - app.start_time}
        app.gg.draw_text(app.ui.f_x, app.ui.f_y - app.ui.f_y/4, "Time: ${app.elapsed_time/60}:${utils.pad(app.elapsed_time%60, 2)}", gx.TextCfg{
            size: app.ui.font_size
            color: gx.black
            vertical_align: .middle
        })
    }

    app.gg.draw_rounded_rect_filled(app.ui.f_x, app.ui.f_y, app.ui.field_size, app.ui.field_size, 10, gx.gray)
    mut xc, mut yc := app.ui.f_x + app.ui.tile_padding / 2, app.ui.f_y + app.ui.tile_padding / 2
    tsize := app.ui.tile_size
    for i in 0 .. 4 {
        for j in 0 .. 4 {
            if app.field[i][j] == 0 { xc += tsize + app.ui.tile_padding; continue }
            app.gg.draw_rounded_rect_filled(xc, yc, tsize, tsize, 10, gx.rgb(4, 79, 53))
            app.gg.draw_text(xc + tsize / 2, yc + tsize / 2, "${app.field[i][j]}", app.txtcfg)
            xc += tsize + app.ui.tile_padding
        }
        xc = app.ui.f_x + app.ui.tile_padding / 2
        yc += tsize + app.ui.tile_padding
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
		.resized, .restored, .resumed {
			app.resize()
		}
		else {}
	}
}

fn (mut app App) resize() {
	window_size := app.gg.window_size()
	w := u16(window_size.width)
	h := u16(window_size.height)
	m := utils.min(w, h)
	app.ui.window_width  = w
	app.ui.window_height = h
	app.ui.field_size = u16(m - f32(m) * 1 / 9)
	app.ui.f_x = (w - app.ui.field_size) / 2
	app.ui.f_y = (h - app.ui.field_size) / 2
	app.ui.tile_padding = app.ui.field_size / 80
	app.ui.tile_size = app.ui.field_size / 4 - app.ui.tile_padding
	app.ui.font_size = u16(f32((w + h)) * 6.5 / 200)
	//if app.ui.font_size < 61 {app.ui.font_size = 61}
	//println(app.ui.font_size)
	app.txtcfg = gx.TextCfg{
		...app.txtcfg
		size: app.ui.font_size
	}
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