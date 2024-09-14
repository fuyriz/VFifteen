module main

import gg
import gx
import rand
import strconv
import utils

struct App {
mut:
	gg          	&gg.Context = unsafe { nil }
	field			[4][4]u64
	frame_counter	u64
	txtcfg			gx.TextCfg
}

const window_title = 'PyatnVVki'
const default_window_width = 900
const default_window_height = 1200

const padding = 10

fn (app &App) draw() {
	app.gg.draw_rounded_rect_filled(50, 200, 800, 800, 5, gx.gray)
	mut xc, mut yc := 50 + padding / 2, 200 + padding / 2
	tsize := 200 - padding
	for i in 0 .. 4 {
		for j in 0 .. 4 {
			if app.field[i][j] == 0 {xc += tsize + padding; continue}
			app.gg.draw_rounded_rect_filled(xc, yc, tsize, tsize, 10, gx.rgb(4, 79, 53))
			app.gg.draw_text(xc + tsize / 2, yc + tsize / 2, "${app.field[i][j]}", app.txtcfg)
			xc += tsize + padding
		}
		xc = 50 + padding / 2; yc += tsize + padding
	}
}

fn frame(mut app App) {
	app.gg.begin()
	app.draw()
	app.frame_counter++
	if app.frame_counter % 60 == 0 {
		app.print_field()
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

fn init(mut app App) {
	app.resize()
	app.scramble()
}

fn on_event(e &gg.Event, mut app App) {
}

fn (mut app App) resize() {

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