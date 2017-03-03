import Control.Arrow ((&&&))
import qualified Data.Map as M
import Data.List;

states = ["alabama","alaska","arizona","arkansas","california","colorado",
          "connecticut","delaware","florida","georgia","hawaii","idaho",
          "illinois","indiana","iowa","kansas","kentucky","louisiana",
          "maine","maryland","massachusetts","michigan","minnesota",
          "mississippi","missouri","montana","nebraska","nevada",
          "newhampshire","newjersey","newmexico","newyork","northcarolina",
          "northdakota","ohio","oklahoma","oregon","pennsylvania","rhodeisland",
          "southcarolina","southdakota","tennessee","texas","utah","vermont",
          "virginia","washington","westvirginia","wisconsin","wyoming"]

countDups :: Ord a => [a] -> M.Map a Int
countDups l = foldr (\a b -> M.insertWith (+) a 1 b) M.empty l
answer = M.filter (>1) $ countDups [sort (x ++ y) | (x:r) <- tails states, y <- r]

--clusterBy f = M.elems . M.map reverse . M.fromListWith (++) . map (f &&& return)
--answer = filter ((>1).length) $ clusterBy sort  [x++y | (x:r) <- tails states, y <- r]
--solve = filter ((>1) . length) . clusterBy sort . ucombos
--ucombos xs = [[x,y] | x <- xs, y <- xs, x < y]

--pairs l = [(x,y) | (x:r) <- tails l, y <- r]
--statePairs = map (\(x,y) -> (sort (x ++ y),(x,y))) $ pairs states
--answer = filter (\((x,_),(y,_)) -> x == y) $ pairs statePairs
