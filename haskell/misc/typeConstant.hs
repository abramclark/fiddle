{-# OPTIONS -fglasgow-exts #-}
newtype IntT a = IntT Int

class Foo a where
    foo :: IntT a

instance Foo () where
    foo = IntT 1

instance Foo String where
    foo = IntT 2

f :: forall a. (Foo a) => a -> Int
f _ = case foo :: IntT a of
        IntT x -> x

main = print (f (), f "foo")

data T a = (Show a) => T a
