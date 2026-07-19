package main

import "core:math/rand"

regions := [len(level_map)][len(level_map[0])]int{}
current_region := 0

generate_map :: proc(room_attempts: int, min_size: int, max_size: int) {
	// rand.reset(2)
	add_rooms(room_attempts, min_size, max_size)
	fill_with_mazes()
	// connect_regions()
	prune_dead_ends()
}

// Step 1: place random non-overlapping rooms
add_rooms :: proc(room_attempts: int, min_size: int, max_size: int) {
	height := len(level_map)
	width := len(level_map[0])

	for _ in 0 ..< room_attempts {
		// Keep sizes and positions odd t line up cleanly with the maze grid
		w := rand.int_range(min_size, max_size + 1) | 1
		h := rand.int_range(min_size, max_size + 1) | 1
		x := rand.int_range(1, width - w - 2) | 1
		y := rand.int_range(1, height - h - 2) | 1

		overlap := false
		for r in y ..= y + h {
			for c in x ..= x + w {
				if level_map[r][c] == .FLOOR {
					overlap = true
					break
				}
			}
		}

		if overlap {
			continue
		}

		// Carve out room and assign a distinct region ID
		current_region += 1
		for r in y ..= y + h {
			for c in x ..= x + w {
				level_map[r][c] = .FLOOR
				regions[r][c] = current_region
			}
		}
	}
}

// Step 2: flood fill empty areas with recursive backtracking maze
fill_with_mazes :: proc() {
	for r := 1; r < len(level_map); r += 2 {
		for c := 1; c < len(level_map[0]); c += 2 {
			if level_map[r][c] == .WALL {
				current_region += 1
				grow_maze(c, r)
			}
		}
	}
}

// Standard recursive backtracking algorithm
grow_maze :: proc(start_x: int, start_y: int) {
	deltas := [4][2]int{{-2, 0}, {2, 0}, {0, -2}, {0, 2}}

	stack := make([dynamic][2]int, 0, 128)
	defer delete(stack)

	append(&stack, [2]int{start_x, start_y})
	level_map[start_y][start_x] = .FLOOR
	regions[start_y][start_x] = current_region

	for len(stack) > 0 {
		center := stack[len(stack) - 1]
		neighbors := make([dynamic][2]int, 0, 4)
		defer delete(neighbors)

		// Look 2 cells away to bypass walls cleanly
		for delta in deltas {
			neighbor := [2]int{center.x + delta.x, center.y + delta.y}
			if neighbor.y > 0 &&
			   neighbor.y < len(level_map) &&
			   neighbor.x > 0 &&
			   neighbor.x < len(level_map[0]) &&
			   level_map[neighbor.y][neighbor.x] == .WALL {
				append(&neighbors, neighbor)
			}
		}

		if len(neighbors) > 0 {
			neighbor := rand.choice(neighbors[:])
			// Carve through the intermediate wall cell
			y := int(center.y + (neighbor.y - center.y) / 2)
			x := int(center.x + (neighbor.x - center.x) / 2)
			level_map[y][x] = .FLOOR
			regions[y][x] = current_region
			level_map[neighbor.y][neighbor.x] = .FLOOR
			regions[neighbor.y][neighbor.x] = current_region
			append(&stack, neighbor)
		} else {
			unordered_remove(&stack, len(stack) - 1)
		}
	}
}

prune_dead_ends :: proc() {
	dirs := [4][2]int{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}
	done := false

	for !done {
		done = true
		for r in 1 ..< len(level_map) - 1 {
			for c in 1 ..< len(level_map[0]) - 1 {
				if level_map[r][c] == .FLOOR {
					wall_count := 0
					for dir in dirs {
						if level_map[r + dir.y][c + dir.x] == .WALL {
							wall_count += 1
						}
					}

					// if 3 surrounding sides are solid walls, fill it back in
					if wall_count >= 3 {
						level_map[r][c] = .WALL
						done = false
					}
				}
			}
		}
	}
}
