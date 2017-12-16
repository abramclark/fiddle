# this would be a lot less confusing if Python curried function arguments

def square(x): return x * x

#compose_self :: (x -> x) -> (x -> x)
# decorates like : @compose_self
def compose_self(f): return lambda x: f(f(x))

@compose_self
def cube(x): return x * x

# I'm not sure if this is actually precisely Knuth's Arrow function,
# but it does exhibit outrageous growth
#recurse :: Integer -> (x -> x) -> (x -> x)
# decorates like : @recurse(Integer)
def knuth_arrow(n):
    def inner2(f):
        def inner1(x):
            def inner0(ff, n): return (inner0(compose_self(ff), n - 1) if n
                else ff(x)
            )
            return inner0(f, n)
        return inner1
    return inner2

# this would be (x * x) up_arrow 3
@knuth_arrow(2)
def yikes(x): return x * x

def arrow_series(f, n, x): return map(
    lambda g: g(x)
  , map(
        lambda g: g(f)
      , map(knuth_arrow, range(n))
    )
  )
