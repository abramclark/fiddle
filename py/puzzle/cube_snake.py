SNAKE_DIRS1 = [1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1]
SNAKE_DIRS2 = [1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1]
SNAKE_DIRS3 = [1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1]
SNAKE_DIRS4 = [1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0]


def three_zeros(x):
    val = 0b1 << (sys.getsizeof(x)+1)
    #print(bin(val),bin(~val))
    return any([(0b111 & ~val >> p == 0b111) for p in range(math.ceil(math.log2(val)))])



def add_one(coord, axis):
    new = list(coord)
    new[axis] += 1
    return tuple(new)

def print_flat_normalized_snake(snake):
    for i in range(len(snake)):
        print('#', end='')
        if ((i + 1) < len(snake)) and snake[i][0] == snake[i+1][0]:
            print('\n' + ' ' * snake[i][0], end='')
    print()

from functools import reduce
flat_snake = [(0, 0)]
flat_snake = reduce(
    lambda snake, axis:
        snake + [add_one(snake[-1], axis)],
    SNAKE_DIRS3,
    flat_snake
)
print_flat_normalized_snake(flat_snake)


size = round(len(flat_snake) ** (1/3))
snake = [t + (0,) for t in flat_snake]


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
checks = 0
def solve(snake, i):
    global checks
    checks += 1
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


if __name__ == '__main__':
    solve(snake, 3)
    print('checks:', checks)
