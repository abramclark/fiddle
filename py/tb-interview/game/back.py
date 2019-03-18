import curses
from itertools import repeat
from random import randint

mines = {}
board = []


def boom(scr):
    for x, y in mines.keys():
        scr.addstr(y, x, '*')

def main(argv):
    global mines, board

    args = map(int, argv[1:])
    xw = int(args[0]) if args else 20
    yw = int(args[1]) if len(args) > 1 else xw / 2
    mines = int(args[2]) if len(args) > 2 else int(xw * yw / 20)

    board = [' ' * xw for i in range(yw)]
    mines = {(randint(0, xw), randint(0, yw)) : True for i in range(mines)}

    scr = curses.initscr()
    scr.keypad(1)
    curses.curs_set(0)
    curses.noecho()
    curses.mousemask(curses.ALL_MOUSE_EVENTS)

    while True:
        scr.clear()

        k = scr.getch()
        scr.addstr(yw + 2, 0, ': ' + str(k))
        if k == 27:
            break
        elif k == curses.KEY_MOUSE:
            _, x, y, z, bstate = curses.getmouse()
            scr.addstr(y, x, ' '.join(str(v) for v in (z, bstate)))
        elif k == curses.KEY_DC:
            boom(scr)

    scr.clear()
    curses.endwin()
