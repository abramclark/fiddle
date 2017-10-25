module BoxMoving where

import Data.Array
import Data.STRef
import Data.IORef
import Data.Maybe
import Control.Monad

type Box = String
type Location = Integer
type Region = (Location, Location)
type Space = IORef (Array Location (Maybe Box))

boxes :: [Box]
boxes = map ((:[])) $ ['A' .. 'Z'] ++ ['a' .. 'z']

lotsOfNothing = Nothing : lotsOfNothing
space :: Array Location (Maybe Box)
space = listArray (0, 150) $ (map Just boxes) ++ lotsOfNothing  
viewSpc space = putStrLn $ concatMap (fromMaybe " ") $ elems space

makeRobot = newIORef $ Nothing
makeSpace = newIORef space

-- A modifies X means A depedns on X and anything depending on X depends on A
--pickFrom :: Location -> Space -> Box -- modifies space
--putAt :: Location -> Box -> Space -- modifies space
--lookFrom :: Location -> Space -> Location -- reads space
pickFrom space loc = do
    s <- readIORef space
    let b = s ! loc
    return $ fromMaybe (error "pickFrom empty location") b

putAt space loc box = do
    s <- readIORef space
    when ((s ! loc) /= Nothing) $ error "putAt non-empty location"
    writeIORef space $ s // [(loc, Just box)]

--findBox :: Space -> Region -> Maybe Box
--findBox space (l, r) =


--moveBoxes :: space -> Region -> Region
--moveBoxes space from to = do
--    findBox space from
