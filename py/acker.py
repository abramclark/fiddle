def A(a, b):
    if a == 0: return b + 1
    if b == 0: return A(a - 1, 1)
    return A(a - 1, A(a, b - 1))

def acker(a, b):
    stack = []
    loops = 0
    values = []
    while 1:
        if not loops:
            loops = raw_input(str(a) +', '+ str(b) +' | '+ ','.join(map(str,stack)))
            loops = int(loops) if loops.isdigit() else 1
        loops -= 1
        if a == 0:
            b += 1
            if not len(stack): break
            a = stack.pop()
            continue
        if b == 0:
            a -= 1
            b = 1
            continue
        if a == 1:
            a = 0
            b += 1
            continue
        if a == 2:
            a = 0
            b = b * 2 + 2
            continue
        stack.append(a - 1)
        b -= 1
    return b
