import Data.Word
import Graphics.UI.Gtk
import Graphics.UI.Gtk.Gdk.PixbufData
import Foreign.Marshal.Array
import Mandelbrot
--import Data.Array.Storable
--import Foreign.Marshal.Utils

main = do
  initGUI
  let w = 500; h = 500
  pixbuf <- pixbufNew ColorspaceRgb False 8 w h
  (PixbufData pb ptr size) <- pixbufGetPixels pixbuf :: IO (PixbufData Int Word8)

  let picture = concatMap (replicate 3) $ mandelbrotSet (-0.25) 0 2 w
  pokeArray ptr picture
  --picture <- newArray_ ((0, 0, 0), (w - 1, h - 1, 2))
  --  :: IO (StorableArray (Int, Int, Int) Word8)
  --mapM_ (\(a, b, c) -> writeArray picture (a, b, c)
  --  $ mandelbrotPoint (-0.25) 0 2 w b a)
  --  $ range ((0, 0, 0), (w - 1, h - 1, 2))
  --mapM_ (\(a, b, c) -> writeArray picture (a, b, c) (if even (a + b) then 255 else 0)) $
  --  range ((0, 0, 0), (w - 1, h - 1, 2))
  --withStorableArray picture (\pic -> copyBytes ptr pic $ w * h * 3)

  window <- windowNew
  window `onSizeRequest` return (Requisition w h)
  widgetShowAll window
  dw <- widgetGetDrawWindow window
  let d = toDrawable d
  gc <- gcNew dw

  let draw = do
      drawPixbuf dw gc pixbuf 0 0 0 0 (-1) (-1) RgbDitherNormal 0 0
      return True
  timeoutAdd draw 500

  onDestroy window mainQuit
  mainGUI
