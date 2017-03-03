-- These two functions are for dealing with drawing pixels using gdk
-- =========================================================================
module GtkJunk (Colour (Colour), pixbufDraw, pixbufDrawRegion, updateCanvas) where

import Graphics.UI.Gtk
import Data.Word (Word8); import Data.Array.Base (unsafeWrite)
import Data.Array (Array, (!), bounds);

class PixbufDrawer a where
  pixbufDraw :: Pixbuf -> a -> IO ()
  pixbufDrawRegion :: Pixbuf -> a -> Int -> Int -> Int -> Int -> IO ()
data Colour = Colour (Word8, Word8, Word8) deriving Show

instance PixbufDrawer (Int -> Int -> Colour) where
  pixbufDrawRegion pixbuf setPixel x y w h = do
    -- assert that the format is RGB8
    3 <- pixbufGetNChannels pixbuf
    8 <- pixbufGetBitsPerSample pixbuf
    -- get the pixel array
    pixelData <- pixbufGetPixels pixbuf
    -- get the dimensions
    rowStride <- pixbufGetRowstride pixbuf
    width <- pixbufGetWidth pixbuf
    height <- pixbufGetHeight pixbuf
    doFromTo y (min (y+h-1) (height-1)) $ \b ->
      doFromTo x (min (x+w-1) (width-1)) $ \a ->
        case setPixel (a-x) (b-y) of
          Colour (red, green, blue) -> do
            unsafeWrite pixelData (a*3 + b*rowStride + 0) red
            unsafeWrite pixelData (a*3 + b*rowStride + 1) green
            unsafeWrite pixelData (a*3 + b*rowStride + 2) blue
  pixbufDraw pixbuf setPixel = do
    width <- pixbufGetWidth pixbuf
    height <- pixbufGetHeight pixbuf
    pixbufDrawRegion pixbuf setPixel 0 0 width height

instance PixbufDrawer (Array (Int,Int) Colour) where
  pixbufDrawRegion pixbuf pixels x y w h = let setPixel x y = pixels!(x,y) in
    do pixbufDrawRegion pixbuf setPixel x y w h
  pixbufDraw pixbuf pixels = let ub = snd $ bounds pixels; w1 = fst ub; h1 = snd ub in do
    w2 <- pixbufGetWidth pixbuf
    h2 <- pixbufGetHeight pixbuf
    pixbufDrawRegion pixbuf pixels 0 0 (min w1 w2) (min h1 h2)

-- do the action for [from..to], ie it's inclusive.
doFromTo :: Int -> Int -> (Int -> IO ()) -> IO ()
doFromTo from to action =
  let loop n | n > to   = return ()
             | otherwise = do action n
                              loop (n+1)
   in loop from

updateCanvas :: DrawingArea -> Pixbuf -> IO ()
updateCanvas canvas pb = do
  win <- widgetGetDrawWindow canvas
  gc <- gcNew win
  drawPixbuf win gc pb 0 0 0 0 (-1) (-1) RgbDitherNone 0 0

--updateCanvas :: DrawingArea -> Pixbuf -> Event -> IO Bool
--updateCanvas canvas pb Expose { eventRegion = region } = do
--  win <- widgetGetDrawWindow canvas
--  gc <- gcNew win
--  width  <- pixbufGetWidth pb
--  height <- pixbufGetHeight pb
--  pbregion <- regionRectangle (Rectangle 0 0 width height)
--  regionIntersect region pbregion
--  rects <- regionGetRectangles region
--  --putStrLn ("redrawing: "++show rects)
--  (flip mapM_) rects $ \(Rectangle x y w h) -> do
--    drawPixbuf win gc pb x y x y w h RgbDitherNone 0 0
--  return True
