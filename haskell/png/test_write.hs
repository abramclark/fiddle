import PHPNG
import System.Random
import System.IO
import qualified Data.Array.Diff as DA
import qualified Data.ByteString.Lazy as B

--setImageList :: [Word16] -> Int -> Int -> PNGImage -> PNGImage
--setImageList list width height img
--
--setImageArray :: (CType e, IArray a e, Ix b, Integral b, Encode16 e) =>
--                 (b, b) e -> PNGImage -> PNGImage
--setImageArray array img
--
--setImageMArray :: (CType e, MArray a e, Ix b, Integral b, Encode16 e) =>
--                  (b, b) e -> PNGImage -> PNGImage
--setImageMArray marray img

main = do
  let w = 420; h = 420
  
  let blank :: DA.Array (Int,Int) ColorRGBA
      blank = DA.listArray ((0,0),(w-1,h-1)) $ replicate (w*h) $ ColorRGBA (0,0,0,0)
      testPixels = drawCircle blank 120 120 260 $ ColorRGBA (1,0,0,1)
      image = setBG (BGRGB (0,0,0)) $ setImageArray testPixels newImage
  writeImage "test0.png" image

  let blank :: DA.Array (Int,Int) ColorIndex
      blank = DA.listArray ((0,0),(w-1,h-1)) $ map ColorIndex static -- $ replicate (w*h) 0
      static = map fromIntegral $ take (w * h) $ (randomRs (0,1) (mkStdGen 2) :: [Int])
      testPixels = drawCircle blank 120 120 260 $ ColorIndex 1
      image = setPalette (map ColorRGBA [(0,0,0,0), (0.2,0.9,0.4,1.0), (0.8,0.3,0.7,1.0)])
        $ setInterlaced True $ setBitDepth 1 $ setBG (BGIndex 2)
        $ setImageArray testPixels newImage
  writeImage "test1.png" image


writeImage fileName img = do
  h <- openFile fileName WriteMode
  B.hPut h (encodeImage img)
  hClose h
  
drawCircle a x y r c = DA.accum (\_ p -> p) a $ map (\i -> (i,c)) $
  filter (DA.inRange $ DA.bounds a) $
    map (\a -> (round (cos a * r) + x, round (sin a * r) + y)) [0, 1/r .. 2*pi]
