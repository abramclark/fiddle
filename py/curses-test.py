import curses
screen = curses.initscr()
curses.mousemask(curses.ALL_MOUSE_EVENTS | curses.REPORT_MOUSE_POSITION)

while True:
    key = screen.getch()
    if key == curses.KEY_MOUSE:
        _, x, y, _, button = curses.getmouse()
        screen.clear()
        screen.addstr(
            0, 0,
            'x, y, button = {}, {}, {}'.format(x, y, button)
        )
    elif key == ord('q'):
        break
    else:
        screen.addstr(0, 0, 'key: {}'.format(key))
curses.endwin()

