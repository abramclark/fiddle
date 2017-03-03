import System.Environment
import Data.List

main = do
  [a] <- getArgs
  let s = read a :: Int
  putStrLn $ needleArt s

needleArt size = concat $ intersperse "\n" $ map addSpaces spaceNeedle
    where width = size * 3 + 2
          addSpaces line = (replicate (width - div (length line) 2) ' ') ++ line
          topLine n = let fill = replicate (n * 3) ':' in
            "__/" ++ fill ++ "||" ++ fill ++ "\\__"
          middle = ["|" ++ (replicate (size * 6 + 2) '"') ++ "|"]
          top = map topLine [0 .. size - 1] ++ middle
          bottomLine n = "\\_" ++ (concat $ replicate (n * 3) "/\\") ++ "_/"
          bottom = reverse $ map bottomLine [1 .. size]
          tower = replicate (size * 4) "|%%||%%|"
          needle = replicate size "||"
          spaceNeedle = needle ++ top ++ bottom ++ needle ++ tower ++ top
