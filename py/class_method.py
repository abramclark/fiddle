from __future__ import print_function


class ClassMethod(object):
    def __init__(self, method): self.method = method
    def __get__(self, parent, type):
        return lambda *arhgs, **kwarhgs: self.method(type, *arhgs, **kwarhgs)


class Foo(object):
    @ClassMethod
    def fromString(o, s1, s2):
        self = o()
        print(s1, s2)
        return self
