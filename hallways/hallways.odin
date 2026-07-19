package main

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

GRID_SIZE :: 32
VELOCITY :: 7

Environment :: enum {
	WALL,
	FLOOR,
}

Player :: struct {
	grid_pos:   [2]int,
	start_pos:  rl.Vector2,
	target_pos: rl.Vector2,
	visual_pos: rl.Vector2,
	is_moving:  bool,
	t:          f32,
}

player := Player {
	grid_pos   = {16, 16},
	visual_pos = {16, 16} * GRID_SIZE,
}

camera := rl.Camera2D {
	target   = player.visual_pos + GRID_SIZE / 2,
	offset   = {1280 / 2, 720 / 2},
	rotation = 0,
	zoom     = 1,
}

level_map := [33][33]Environment{}

main :: proc() {
	rl.InitWindow(1280, 720, "Grid Movement Test")
	defer rl.CloseWindow()

	rl.SetTargetFPS(200)

	generate_map()
	for !rl.WindowShouldClose() {
		update()
		draw()
	}
}

can_move :: proc(pos: [2]int) -> bool {
	if pos.y < 0 || pos.y >= len(level_map) {
		return false
	}

	if pos.x < 0 || pos.x >= len(level_map[0]) {
		return false
	}

	return level_map[pos.y][pos.x] == .FLOOR
}

update_camera :: proc() {
	camera.target = player.visual_pos + GRID_SIZE / 2
	camera.offset = {
		f32(rl.GetScreenWidth() / 2),
		f32(rl.GetScreenHeight() / 2),
	}
}

update_player :: proc() {
	if player.is_moving {
		// Progress interpolation over time
		player.t += rl.GetFrameTime() * VELOCITY

		if player.t >= 1 {
			player.visual_pos = player.target_pos
			player.is_moving = false
			player.t = 0
		} else {
			player.visual_pos.x = math.lerp(
				player.start_pos.x,
				player.target_pos.x,
				player.t,
			)
			player.visual_pos.y = math.lerp(
				player.start_pos.y,
				player.target_pos.y,
				player.t,
			)
		}

		return
	}

	// Determine direction from keys pressed
	direction: [2]int
	if rl.IsKeyDown(.W) {
		direction = {0, -1}
	} else if rl.IsKeyDown(.A) {
		direction = {-1, 0}
	} else if rl.IsKeyDown(.S) {
		direction = {0, 1}
	} else if rl.IsKeyDown(.D) {
		direction = {1, 0}
	}

	// If no movement, bail
	if direction == {0, 0} {
		return
	}

	next_grid := player.grid_pos + direction

	// Don't move if it's not in play
	if !can_move(next_grid) {
		return
	}

	player.grid_pos = next_grid
	player.start_pos = player.visual_pos
	player.target_pos = {
		f32(player.grid_pos.x * GRID_SIZE),
		f32(player.grid_pos.y * GRID_SIZE),
	}
	player.is_moving = true
}

update :: proc() {
	update_player()
	update_camera()
}

draw_halls :: proc() {
	wall_color := rl.GetColor(0x41486877)
	for row, y in level_map {
		for tile, x in row {
			switch tile {
			case .WALL:
				rl.DrawRectangleV(
					{f32(GRID_SIZE * x), f32(GRID_SIZE * y)},
					{GRID_SIZE, GRID_SIZE},
					wall_color,
				)
			case .FLOOR:
			// NOOP
			}
		}
	}
}

draw_grid :: proc() {
	screen_width := f32(rl.GetScreenWidth())
	screen_height := f32(rl.GetScreenHeight())
	for x := f32(0); x < screen_width; x += GRID_SIZE {
		rl.DrawLineV({x, 0}, {x, screen_height}, rl.GetColor(0xc0caf577))
	}
	for y := f32(0); y < screen_height; y += GRID_SIZE {
		rl.DrawLineV({0, y}, {screen_width, y}, rl.GetColor(0xc0caf577))
	}
}

draw :: proc() {
	rl.BeginDrawing()

	// Clear screen
	rl.ClearBackground(rl.GetColor(0x1a1b26ff))

	// Set up camera to follow player
	rl.BeginMode2D(camera)

	draw_halls()
	draw_grid()

	// Draw player
	rl.DrawRectangleRounded(
		{player.visual_pos.x, player.visual_pos.y, GRID_SIZE, GRID_SIZE},
		0.25,
		8,
		rl.GetColor(0x7aa2f7ff),
	)

	rl.EndMode2D()

	// Draw FPS
	rl.DrawText(
		rl.TextFormat("FPS: %v", rl.GetFPS()),
		8,
		8,
		10,
		rl.GetColor(0x9ece6aff),
	)

	rl.EndDrawing()
}
