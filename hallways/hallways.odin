package main

import rl "vendor:raylib"

GRID_SIZE :: 32
VELOCITY :: GRID_SIZE * 5

Environment :: enum {
	WALL,
	FLOOR,
}

Player :: struct {
	position: rl.Vector2,
	velocity: rl.Vector2,
}

level_map := [8][8]Environment {
	{.WALL, .WALL, .WALL, .WALL, .WALL, .WALL, .WALL, .WALL},
	{.WALL, .FLOOR, .FLOOR, .WALL, .FLOOR, .FLOOR, .FLOOR, .WALL},
	{.WALL, .FLOOR, .WALL, .WALL, .FLOOR, .FLOOR, .FLOOR, .WALL},
	{.WALL, .FLOOR, .WALL, .WALL, .WALL, .FLOOR, .WALL, .WALL},
	{.WALL, .FLOOR, .WALL, .WALL, .WALL, .FLOOR, .FLOOR, .WALL},
	{.WALL, .FLOOR, .FLOOR, .WALL, .WALL, .WALL, .FLOOR, .WALL},
	{.WALL, .WALL, .FLOOR, .FLOOR, .FLOOR, .FLOOR, .FLOOR, .WALL},
	{.WALL, .WALL, .WALL, .WALL, .WALL, .WALL, .WALL, .WALL},
}


player := Player {
	position = {GRID_SIZE * 2, GRID_SIZE * 1},
	velocity = {0, 0},
}

main :: proc() {
	rl.InitWindow(1280, 720, "Grid Movement Test")
	defer rl.CloseWindow()

	// rl.SetTargetFPS(60)
	for !rl.WindowShouldClose() {
		update()
		draw()
	}
}

can_move :: proc(x: int, y: int) -> bool {
	if y < 0 || y > len(level_map) {
		return false
	}
	if x < 0 || x > len(level_map[0]) {
		return false
	}
	return level_map[y][x] == .FLOOR
}

update :: proc() {
	grid_current := [2]int {
		int(player.position.x / GRID_SIZE),
		int(player.position.y / GRID_SIZE),
	}

	can := rl.GetColor(0x9ece6a77)
	cant := rl.GetColor(0xf7768e77)

	if rl.IsKeyDown(.D) {
		x := grid_current.x + 1
		rl.DrawRectangleV(
			{f32(x * GRID_SIZE), f32(grid_current.y * GRID_SIZE)},
			{GRID_SIZE, GRID_SIZE},
			can_move(x, grid_current.y) ? can : cant,
		)
	} else if rl.IsKeyDown(.A) {
		x := grid_current.x - 1
		rl.DrawRectangleV(
			{f32(x * GRID_SIZE), f32(grid_current.y * GRID_SIZE)},
			{GRID_SIZE, GRID_SIZE},
			can_move(x, grid_current.y) ? can : cant,
		)
	}
}

update_old :: proc() {
	frame_time := rl.GetFrameTime()

	// Current X/Y pos in the level_map
	level_x := int(player.position.x / GRID_SIZE)
	level_y := int(player.position.y / GRID_SIZE)

	// NOTE: deltas here are signed!
	delta_x := player.velocity.x * frame_time
	delta_y := player.velocity.y * frame_time

	// Possibly the next X or Y position if the player keeps going
	next_x := int((player.position.x + delta_x) / GRID_SIZE)
	next_y := int((player.position.y + delta_y) / GRID_SIZE)

	rl.DrawRectangleV(
		{f32(GRID_SIZE * next_x), f32(GRID_SIZE * next_y)},
		{GRID_SIZE, GRID_SIZE},
		rl.GetColor(0x565f8977),
	)

	// Horizontal positioning
	if rl.IsKeyDown(.D) {
		player.velocity.x = VELOCITY
	} else if player.velocity.x > 0 {
		if next_x > level_x {
			player.position.x = f32(next_x * GRID_SIZE)
			player.velocity.x = 0
		}
	} else if rl.IsKeyDown(.A) {
		player.velocity.x = -VELOCITY
	} else if player.velocity.x < 0 {
		if next_x < level_x {
			player.position.x = f32(level_x * GRID_SIZE)
			player.velocity.x = 0
		}
	}

	// Vertical positioning
	if rl.IsKeyDown(.S) {
		player.velocity.y = VELOCITY
	} else if player.velocity.y > 0 {
		if next_y > level_y {
			player.position.y = f32(next_y * GRID_SIZE)
			player.velocity.y = 0
		}
	} else if rl.IsKeyDown(.W) {
		player.velocity.y = -VELOCITY
	} else if player.velocity.y < 0 {
		if next_y < level_y {
			player.position.y = f32(level_y * GRID_SIZE)
			player.velocity.y = 0
		}
	}

	// if player.velocity.x != 0 && !can_move(next_x, level_y) {
	// 	player.velocity.x = 0
	// }
	//
	// if player.velocity.y != 0 && !can_move(level_x, next_y) {
	// 	player.velocity.y = 0
	// }

	player.position += player.velocity * rl.GetFrameTime()
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

	draw_halls()
	draw_grid()

	// Draw player
	rl.DrawRectangleRounded(
		{player.position.x, player.position.y, GRID_SIZE, GRID_SIZE},
		0.25,
		8,
		rl.GetColor(0x7aa2f7ff),
	)

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
