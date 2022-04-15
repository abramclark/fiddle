FLAT_SNAKE = [
    (0, 0), (0, 1), (0, 2), (1, 2), (1, 3), (2, 3), (3, 3), (3, 4), (3, 5),
    (4, 5), (4, 6), (5, 6), (5, 7), (6, 7), (6, 8), (7, 8), (7, 9), (8, 9),
    (8, 10), (9, 10), (9, 11), (10, 11), (11, 11), (11, 12), (11, 13),
    (12, 13), (12, 14)
]
size = round(len(FLAT_SNAKE) ** (1/3))


def print_flat_normalized_snake(snake):
    for i in range(len(snake)):
        print('#', end='')
        if ((i + 1) < len(snake)) and snake[i][0] == snake[i+1][0]:
            print('\n' + ' ' * snake[i][0], end='')


snake = [t + (0,) for t in FLAT_SNAKE]


def rotate(origin, axis, point):
    a1 = (axis + 1) % 3
    a2 = (a1 + 1) % 3
    v1 = -1 * (point[a2] - origin[a2]) + origin[a1]
    v2 = point[a1] - origin[a1] + origin[a2]

    if axis == 0:
        return (point[axis], v1, v2)
    elif axis == 1:
        return (v2, point[axis], v1)
    else:
        return (v1, v2, point[axis])


def rotate_snake(snake, i):
    origin = snake[i]
    prev = snake[i - 1]
    axis = next(j for j in (0, 1, 2) if origin[j] != prev[j])
    return snake[:i + 1] + [rotate(origin, axis, p) for p in snake[i + 1:]]


solutions = []
def solve(snake, i):
    head = snake[i]
    for tail in snake[:i]:
        if head == tail or not all(
            -size < (head[j] - tail[j]) < size for j in (0, 1, 2)
        ):
            return

    if i == len(snake) - 1:
        if snake not in solutions:
            solutions.append(snake[:])
            print(snake)
        return

    new_snake = snake[:]
    solve(new_snake, i + 1)
    for c in range(3):
        new_snake = rotate_snake(new_snake, i)
        solve(new_snake, i + 1)


solve(snake, 3)
