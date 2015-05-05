module Main
import Effect.StdIO
import Effect.State

--main : { [STDIO] } Eff IO ()
--main = putStrLn "Hello world!"

--data P = Vect (S (S Z))
--x = P 1 2

x : Maybe Int
y : Maybe Int
x = Just 10
y = Nothing

--y : Type -> Type
--y = Vect 2
--
--z : y String
--z = ["aoeu", "f"]
--
--x : Vect 2 Integer
--x = [10, 9]
--
--n : Integer
--n = 10

--f : Integer -> Integer -> String
--f x y = believe_me (x + y)

--sqr : Integer -> Integer
--sqr x = x * x

--main : IO ()
--main = run hello

data Foo = A | B

data BTree a = Leaf
  | Node (BTree a) a (BTree a)
testTree : BTree String
testTree =
  Node (Node Leaf "Jim" Leaf) "Fred"
  (Node (Node Leaf "Alice" Leaf)
    "Sheila"
    (Node Leaf "Bob" Leaf))

treeTagAux0 : (i : Int) -> BTree a -> (Int, BTree (Int, a))
treeTagAux0 i Leaf = (i, Leaf)
treeTagAux0 i (Node l x r) =
    let (i', l') = treeTagAux0 i l in
    let x' = (i', x) in
    let (i'', r') = treeTagAux0 (i' + 1) r in
        (i'', Node l' x' r')
treeTag0 : (i : Int) -> BTree a -> BTree (Int, a)
treeTag0 i x = snd (treeTagAux0 i x)

treeTagAux : BTree a ->
    Eff m (BTree (Int, a)) [STATE Int] (\x => [STATE Int])
treeTagAux Leaf = pure Leaf
treeTagAux (Node l x r) = do
    l' <- treeTagAux l
    i <- get
    put (i + 1)
    r' <- treeTagAux r
    pure (Node l' (i, x) r')
treeTag : (i : Int) -> BTree a -> BTree (Int, a)
treeTag i x = runPure $ do
    put i
    treeTagAux x

vec : (n : Nat ** Vect n Int)
vec = (2 ** [3, 4])

--main : IO ()
--main = do
--  putStrLn "aoeuaoeu"
--  putStrLn "moo"
--  x <- getLine
--  putStrLn x
