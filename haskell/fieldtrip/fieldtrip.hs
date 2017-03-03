import Data.Monoid
import Graphics.FieldTrip

torusPair :: Geometry3
torusPair = f red (1/2) `mappend` pivot3X (f green (-1/2))
    where tor = torus 1 (2/5)
          f :: Col -> R -> Geometry3
          f col dx = materialG (plastic col) (move3X dx tor)


