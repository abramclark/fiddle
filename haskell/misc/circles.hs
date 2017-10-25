import Data.Word
import Data.Char
import Data.List
import System.IO
--import System.Environment
--import Foreign.Marshal.Array
import Data.Array.IO
import Control.Monad
import System.Random

type Rat = Float

main = do
  --args <- getArgs
  --let size = read $ args !! 0
  let sizeX = 800; sizeY = 600

  picture <- newArray ((0, 0), (sizeY - 1, sizeX - 1)) (0,0,0)
    :: IO (IOArray (Int, Int) (Rat,Rat,Rat))
  -- a nice X11 style background
  --mapM_ (\(a, b) -> writeArray picture (a, b) (if even $ a + b then 1 else 0)) $
  --  range ((0, 0), (sizeX - 1, sizeY - 1))
  
  [xs, ys, ss, rs, gs, bs] <- mapM (replicateM 20 . randomRIO)
    [(0, fromIntegral sizeX), (0, fromIntegral sizeY), (5, 300), (0, 1), (0, 1), (0, 1)] :: IO [[Rat]]
  ws <- mapM (\s -> randomRIO (1, s/4)) ss
  let xyswc = zip5 xs ys ss ws $ zip3 rs gs bs
  let updater (r1, g1, b1) (r2, g2, b2) a = (blend r1 a r2, blend g1 a g2, blend b1 a b2)
  mapM_ (\ (x,y,s,w,c) -> updateElems (updater c) picture $ drawCircle x y s w) xyswc

  --writeElems picture $ drawCircle 100 100.0 15 1 255
  --writeElems picture $ drawCircle 135 100.2 15 1 255
  --writeElems picture $ drawCircle 170 100.4 15 1 255
  --writeElems picture $ drawCircle 205 100.6 15 1 255
  --writeElems picture $ drawCircle 240 100.8 15 1 255
  --writeElems picture $ drawCircle 275 101.0 15 1 255
  --writeElems picture $ drawCircle 310 101.2 15 1 255
  --writeElems picture $ drawCircle 345 101.4 15 1 255

  pixels <- getElems picture
  writePPM "out.pnm" sizeX sizeY pixels

drawCircle :: Rat -> Rat -> Rat -> Rat -> [((Int, Int), Rat)]
drawCircle x y r w =
  let rr = ceiling r; wr = ceiling w
      xh = round x; xf = frac x
      yh = round y; yf = frac y
      dists :: [((Int, Int), Rat)]
      dists = [((y, x),
            abs $ ((fromIntegral x + xf)**2 + (fromIntegral y + yf)**2) ** 0.5 - r)
          | x <- span, y <- span, abs x + abs y > rr - wr - 1]
        where span = [-rr - wr .. rr + wr]
    in map (\ ((b, a), d) -> ((b+yh, a+xh), 1 - d / w))
      $ filter ((< w) . snd) dists

writePGM file width height pixels =
  withFile file WriteMode $ \h -> do
    hPutStrLn h "P5"
    hPrint    h width
    hPrint    h height
    hPrint    h 255
    hPutStr   h $ map (chr . floor . (*255)) pixels

writePPM file width height pixels =
  withFile file WriteMode $ \h -> do
    hPutStrLn h "P6"
    hPrint    h width
    hPrint    h height
    hPrint    h 255
    hPutStr   h $ concatMap (\(r,g,b) -> map (chr . floor . (*255)) [r,g,b]) pixels

writeElems array newElems = do
  bounds <- getBounds array
  mapM_ (\(i, e) -> writeArray array i e) $ filter (inRange bounds . fst) newElems

updateElems updater array newElems = do
  bounds <- getBounds array
  mapM_ (\(i, a) -> do
      o <- readArray array i
      writeArray array i $ updater o a)
    $ filter (inRange bounds . fst) newElems

blend :: Rat -> Rat -> Rat -> Rat
blend color alpha back = alpha * color + (1 - alpha) * back
frac = snd . properFraction

--root2o2 = 0.5 ** 0.5 :: Rat
--  let i = round $ root2o2 * r;
--      points :: (Int, Int) -> [((Int, Int), Rat)]
--      points (0, _) = []
--      points (a, b) =
--        let a' = a - 1; a'2 = fromIntegral $ a'*a'
--            dist2circ :: Int -> Rat
--            dist2circ y = let y' = fromIntegral y in abs $ (a'2 + y'*y') ** 0.5 - r
--            [v1, v2, v3] = map dist2circ [b-1, b, b+1]
--          in (concat [[((x+dx,y+dy+(fst aas)), snd aas), ((x+dy,y+dx+(fst aas)), snd aas)] | dy <- [b,-b], dx <- [a,-a], aas <- zip [-1, 0, 1] $ map (fromIntegral . round . (* fromIntegral c)) [v1, v2, v3]])
--            ++ (points (a', if v2 < v3 then b else b+1))
--    in points (i, i)
