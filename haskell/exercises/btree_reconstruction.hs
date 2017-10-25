data Tree a = Node (Tree a) a (Tree a)
            | Nill
            deriving (Show, Eq)
leaf a = Node Nill a Nill

preOrder :: Tree a -> [a]
preOrder Nill = []
preOrder (Node left a right) = a : concat [preOrder left, preOrder right]

inOrder :: Tree a -> [a]
inOrder Nill = []
inOrder (Node left a right) = concat [inOrder left, [a], inOrder right]

recons :: (Eq a) => [a] -> [a] -> Tree a
recons [] _ = Nill
recons (h : t) inList = Node (recons leftPre leftIn) h (recons rightPre rightIn)
                        where (leftIn, _ : rightIn) = break (==h) inList
                              (leftPre, rightPre) = splitAt (length leftIn) t

t = Node Nill 1 (Node (Node (leaf 5) 4 (leaf 6)) 2 (leaf 3))
test = recons (preOrder t) (inOrder t) == t

--reconstruct :: (Eq a) => [a] -> [a] -> Tree a
--reconstruct preList inList = snd $ f preList inList
--    where f p [] = (p, Nill)
--          f (h : t) i = (remainderR, Node left h right)
--              where (iLeft, _ : iRight) = break (==h) i
--                    (remainderL, left) = f t iLeft
--                    (remainderR, right) = f remainderL iRight
