import qualified Graphics.UI.Gtk as G;
import GtkJunk (Colour (Colour), pixbufDraw, updateCanvas)
import Data.Array (Array, array, (!)); import List; import Data.IORef; import Text.Printf;
import qualified Data.Map as M; import Control.Monad; import System.Random;

data NdArray a = NdArray [Int] (Array Int a) deriving Show

cosInterp :: Int -> Int -> Double -> Int
cosInterp from to at = round (((fromIntegral from - fromIntegral to) / 2) *
  (1 + cos (pi * at))) + to :: Int

smoothBox :: Int -> Int -> [Int] -> [Int] -> Int
smoothBox dim width box | (2^dim) /= (length box) = error "Must have 2^dim elements in box"
                        | dim == 1 = (\[x] -> cosInterp (box!!0) (box!!1)
                            (fromIntegral x / fromIntegral width))
                        | otherwise =
  let
    getSubBox subBox = ndArray (replicate (dim-1) (width-1)) (map
      (\coord -> (coord, (smoothBox (dim-1) width subBox coord)))
      (replicateM (dim-1) [0..width-1]))
    subBox1 = getSubBox $ (take (2^(dim-1))) box
    subBox2 = getSubBox $ (drop (2^(dim-1))) box
  in (\coord -> cosInterp (subBox1 @! (drop 1 coord)) (subBox2 @! (drop 1 coord))
    (fromIntegral (head coord) / fromIntegral width))

smoothNoise :: Int -> Int -> [Int] -> Int -> [Int] -> Int
smoothNoise dim width stream freqInv = let
    freq = div width freqInv
    fnArray = ndArray (replicate dim (freq+1)) $ take ((freq+1)^dim) $ map
      (\(coord,box) -> (coord, smoothBox dim freqInv box)) (stream2boxes dim stream)
  in (\l -> (fnArray @! (map (flip div freqInv) l)) (map (flip mod freqInv) l))
 
perlin :: Int -> Int -> StdGen -> [Int] -> Int
perlin dim width g = let
    layerFns = zipWith (smoothNoise dim width)
      (zipWith randomRs [(0,x) | x <- [128, 256, 512, 1024]] (unfoldr (Just . split) g))
      [5, 10, 20, 40]
  in (\l -> sum $ flip sequence l layerFns)

draw :: (Int -> Int -> Int) -> (Int -> Colour) -> Int -> Int -> Colour
draw f pallette x y = pallette (f x y)

pal1 :: Int -> Colour
pal1 = let { gradient =
    array (0,299) (zipWith (,) [0..299] (map
      (\x -> Colour (round $ max 0 $ 255 * sin (fromIntegral x * pi / 200), 0,
        round $ max 0 $ 255 * sin (fromIntegral (x - 100) * pi / 200)))
      [0..299]))
  } in (\x -> gradient ! (mod x 300))

main = let size = 256 in do
  G.initGUI
  window <- G.windowNew
  pixbuf <- G.pixbufNew G.ColorspaceRgb False 8 size size
  canvas <- G.drawingAreaNew

  -- Perlin animation (slices through 3D block)
  frameRef <- newIORef 0 :: IO (IORef Int)
  let perlin1 = perlin 3 size (mkStdGen 10)
      perlinFrame frame = draw (\x y -> perlin1 [frame, x, y]) pal1
      drawPerlin frame = do pixbufDraw pixbuf (perlinFrame frame)
      drawFrame = do
        frame <- readIORef frameRef
        drawPerlin frame
        G.widgetQueueDraw canvas
        --G.pixbufSave pixbuf (printf "frame_%03d.png" frame) "png" []
        putStrLn (show frame)
        modifyIORef frameRef (+1)
        return True
    in do drawFrame; G.timeoutAdd drawFrame 2000

  -- Series of frames of Perlin noise
  --frameRef <- newIORef 0 :: IO (IORef Int)
  --let perlin1 seed = perlin 2 size (mkStdGen seed)
  --    perlinFrame frame = let perl = perlin1 frame in draw (\x y -> perl [x, y]) pal1
  --    drawPerlin frame = do pixbufDraw pixbuf (perlinFrame frame)
  --    drawFrame = do
  --      frame <- readIORef frameRef
  --      drawPerlin frame
  --      G.widgetQueueDraw canvas
  --      --G.pixbufSave pixbuf (printf "frame_%03d.png" frame) "png" []
  --      putStrLn (show frame)
  --      modifyIORef frameRef (+1)
  --      return True
  --  in do drawFrame; G.timeoutAdd drawFrame 1000

  canvas `G.onSizeRequest` return (G.Requisition size size)
  canvas `G.onExpose` updateCanvas canvas pixbuf
  G.set window [ G.containerChild G.:= canvas ]
  G.onDestroy window G.mainQuit
  G.widgetShowAll window
  G.mainGUI

ndArray_array (NdArray inds a) = a
ndArray_inds (NdArray inds a) = inds
ndArray :: [Int] -> [([Int], a)] -> NdArray a
ndArray dims contents =
  let inds = [1] ++ (map (foldl (*) 1) (map (flip take (map (+1) dims)) [1..length dims])) in
    NdArray inds $ array (0, sum $ zipWith (*) dims inds)
      (map (\(k,v) -> (sum $ zipWith (*) inds k,v)) contents)
(@!) :: NdArray a -> [Int] -> a
x @! y = (ndArray_array x) ! (sum $ zipWith (*) (ndArray_inds x) y)

-- Take's stream and assembles it into a list of (coordinate, dim dimensional box),
-- where the box's corners are elements of stream
stream2boxes :: Int -> [a] -> [([Int], [a])]
stream2boxes dim stream = let {
    boxCoords = replicateM dim [0,1];
    getEdge n strm = M.fromAscList $ zipWith (,) (filter (elem n) $ replicateM dim [0..n]) strm;
    nextBoxes n edge strm = let edge2 = getEdge n strm; boxes = M.union edge edge2 in
      (map (\(k, v) -> (k, map ((M.!) boxes) (map (zipWith (+) k) boxCoords))) (M.toList edge))
        ++ nextBoxes (n + 1) edge2 (drop (M.size edge2) strm);
  } in nextBoxes 1 (M.singleton (replicate dim 0) (head stream)) (tail stream)
