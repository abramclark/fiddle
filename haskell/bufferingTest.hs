import Control.Monad
import System.IO

listdo = do
    l <- [1, 2, 3]
    [True, False]
    ["one", "two", "three"]
    return l

main = do
    hSetBuffering stdin NoBuffering
    c <- getChar
    putChar c

withNoBuf f = do
    hSetBuffering stdin NoBuffering
    f
