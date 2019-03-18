class Board:
    board = []
    square = ['-', 'X', 'O']

    def __init__(self):
        self.board = [[0, 0, 0] for i in range(3)]

    def show(self):
        for row in self.board:
            print('|'.join(self.square[x] for x in row))

    def move(self, player, x, y):
        self.board[y][x] = player

    def make_move(self, player):
        for y, row in enumerate(self.board):
            for x, square in enumerate(row):
                if not square:
                    self.move(player, y, x)
                    return (x, y)

        raise Exception('no move available')

    def move_2(self):
        self.make_move(2)


def main(argv):
    print(argv[1:])


def test_1(b):
    for i in range(10):
        b.make_move(2)
        b.show()
        print()
