package main

import rl "vendor:raylib"

GRID_SIZE :: 32
VELOCITY :: GRID_SIZE * 5

Player :: struct {
	position: rl.Vector2,
	velocity: rl.Vector2,
}

player := Player {
	position = {GRID_SIZE * 3, GRID_SIZE * 3},
	velocity = {0, 0},
}

main :: proc() {
	rl.InitWindow(1280, 720, "Grid Movement Test")
	defer rl.CloseWindow()

	for !rl.WindowShouldClose() {
		update()
		draw()
	}
}

update :: proc() {
	// Vertical positioning
	if rl.IsKeyDown(.D) {
		player.velocity.x = VELOCITY
	} else if rl.IsKeyDown(.A) {
		player.velocity.x = -VELOCITY
	} else if snap := int(player.position.x); snap % GRID_SIZE == 0 {
		player.velocity.x = 0
		player.position.x = f32(snap)
	}

	// Horizontal positioning
	if rl.IsKeyDown(.S) {
		player.velocity.y = VELOCITY
	} else if rl.IsKeyDown(.W) {
		player.velocity.y = -VELOCITY
	} else if snap := int(player.position.y); snap % GRID_SIZE == 0 {
		player.velocity.y = 0
		player.position.y = f32(snap)
	}

	player.position += player.velocity * rl.GetFrameTime()
}

draw :: proc() {
	rl.BeginDrawing()

	// Clear screen
	rl.ClearBackground(rl.GetColor(0x1a1b26ff))

	// Draw player
	rl.DrawRectangleRounded(
		{player.position.x, player.position.y, GRID_SIZE, GRID_SIZE},
		0.25,
		8,
		rl.GetColor(0x7aa2f7ff),
	)

	// Draw grid
	screen_width := f32(rl.GetScreenWidth())
	screen_height := f32(rl.GetScreenHeight())
	for x := f32(0); x < screen_width; x += GRID_SIZE {
		rl.DrawLineV({x, 0}, {x, screen_height}, rl.GetColor(0xc0caf577))
	}
	for y := f32(0); y < screen_height; y += GRID_SIZE {
		rl.DrawLineV({0, y}, {screen_width, y}, rl.GetColor(0xc0caf577))
	}

	// Draw FPS
	rl.DrawText(rl.TextFormat("FPS: %v", rl.GetFPS()), 8, 8, 10, rl.GetColor(0x9ece6aff))

	rl.EndDrawing()
}
