import curses

screen = curses.initscr()
screen.keypad(1)
curses.curs_set(1)
curses.mousemask(curses.ALL_MOUSE_EVENTS | curses.REPORT_MOUSE_POSITION)

while True:
    key = screen.getch()
    screen.clear()

    _, x, y, _, button = curses.getmouse()
    screen.addstr(0, 0, 'x, y, button = {}, {}, {}'.format(x, y, button))
    screen.addstr(1, 0, 'key: {}'.format(key))

    if key == 27:
        break

curses.endwin()
