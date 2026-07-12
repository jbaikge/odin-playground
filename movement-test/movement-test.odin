package movement_test

import rl "vendor:raylib"

// Pixels per second
MOVE_RATE :: f32(400)

// Colors
// https://wixdaq.github.io/Tokyo-Night-Website/palette.html
COLOR_BG :: rl.Color{26, 27, 38, 255}
COLOR_PLAYER :: rl.Color{255, 158, 100, 255}
COLOR_FPS :: rl.Color{158, 206, 106, 255}

Player :: struct {
	position: rl.Vector2,
	size:     rl.Vector2,
	velocity: rl.Vector2,
}

main :: proc() {
	rl.InitWindow(1280, 720, "Movement Test")
	defer rl.CloseWindow()

	rl.SetWindowPosition(30, 60)

	player := Player {
		position = {640, 320},
		size     = {64, 64},
		velocity = {0, 0},
	}

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(COLOR_BG)

		// Move up/down
		if rl.IsKeyDown(.W) {
			player.velocity.y = -MOVE_RATE
		} else if rl.IsKeyDown(.S) {
			player.velocity.y = MOVE_RATE
		} else {
			player.velocity.y = 0
		}

		// Move left/right
		if rl.IsKeyDown(.A) {
			player.velocity.x = -MOVE_RATE
		} else if rl.IsKeyDown(.D) {
			player.velocity.x = MOVE_RATE
		} else {
			player.velocity.x = 0
		}

		// Run!
		if rl.IsKeyDown(.LEFT_SHIFT) {
			player.velocity *= 1.5
		}

		player.position += player.velocity * rl.GetFrameTime()

		// Lock player to inside the screen
		if player.position.x < 0 {
			player.position.x = 0
		}
		if player.position.y < 0 {
			player.position.y = 0
		}

		x_bound := f32(rl.GetScreenWidth()) - player.size.x
		if player.position.x > x_bound {
			player.position.x = x_bound
		}
		y_bound := f32(rl.GetScreenHeight()) - player.size.y
		if player.position.y > y_bound {
			player.position.y = y_bound
		}

		rl.DrawRectangleRounded(
			rl.Rectangle {
				player.position.x,
				player.position.y,
				player.size.x,
				player.size.y,
			},
			0.25, // roundness
			10, // facets
			COLOR_PLAYER,
		)

		fps := rl.TextFormat("FPS: %v", rl.GetFPS())
		rl.DrawText(fps, 8, 8, 8, COLOR_FPS)

		rl.EndDrawing()
	}
}
