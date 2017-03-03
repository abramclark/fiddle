import Data.List; import Control.Monad;
import Numeric

mRead s = case reads s of { (a, _):_ -> Just a; [] -> Nothing }

ains v [] = [[v]]
ains v (x:xs) = map (x:) (ains v xs) ++ [v:x:xs]

class DoStuff a where
  doStuff1 :: a -> String

doStuff2 :: (DoStuff a) => a -> String
doStuff2 a = (doStuff1 a) ++ "foo"

instance DoStuff Int where doStuff1 = (`showHex` "")
