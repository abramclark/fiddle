fib = (lambda f, x:
    1 if x == 0 or x == 1
    else f(f, x - 1) + f(f, x - 2)
)

y = lambda f: lambda x: f(f, x)

fib10 = y(fib)(10)
