package level_gen

import rl "vendor:raylib"

COLOR_BG :: rl.Color{0x1a, 0x1b, 0x26, 0xff}
COLOR_FPS :: rl.Color{0x9e, 0xce, 0x6a, 0xff}
COLOR_FLOOR :: rl.Color{0xa9, 0xb1, 0xd6, 0xff}
COLOR_WALL :: rl.Color{0x7a, 0xa2, 0xf7, 0xff}
COLOR_DOOR :: rl.Color{0xe0, 0xaf, 0x68, 0xff}
GRID_SIZE :: 16

Environment :: enum {
	Floor,
	Wall,
	Door,
}

level := [64][64]Environment{}

update :: proc() {
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(COLOR_BG)

	color: rl.Color
	for y in 0 ..< len(level) {
		for x in 0 ..< len(level[0]) {
			switch level[y][x] {
			case .Floor:
				color = COLOR_FLOOR
			case .Wall:
				color = COLOR_WALL
			case .Door:
				color = COLOR_DOOR
			}

			rl.DrawRectangleV(
				{f32(x) * GRID_SIZE, f32(y) * GRID_SIZE},
				{GRID_SIZE, GRID_SIZE},
				color,
			)
		}
	}

	rl.DrawText(rl.TextFormat("FPS: %d", rl.GetFPS()), 10, 10, 10, COLOR_FPS)

	rl.EndDrawing()
}

main :: proc() {
	rl.InitWindow(1280, 720, "Level Generator")
	defer rl.CloseWindow()

	rl.SetTargetFPS(200)

	for !rl.WindowShouldClose() {
		update()
		draw()
	}
}
