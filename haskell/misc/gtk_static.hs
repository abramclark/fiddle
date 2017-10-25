import System.Environment
import Data.Word
import System.Random
import Graphics.UI.Gtk
import Graphics.UI.Gtk.Gdk.PixbufData
import Foreign.Marshal.Array
import Control.Monad

main = do
  initGUI
  let w = 512; h = 512
      static :: [Word8]
      static = map fromIntegral $ take (w * h * 3) $ (randomRs (0,255) (mkStdGen 1) :: [Int])
  
  p <- pixbufNew ColorspaceRgb False 8 w h
  (PixbufData pb ptr size) <- pixbufGetPixels p :: IO (PixbufData Int Word8)
  pokeArray ptr static

  --a <- getArgs
  --p <- pixbufNewFromFile $ a !! 0
  --(w, h) <- liftM2 (,) (pixbufGetWidth p) (pixbufGetHeight p)

  window <- windowNew
  window `onSizeRequest` return (Requisition w h)
  widgetShowAll window
  dw <- widgetGetDrawWindow window
  let d = toDrawable d
  gc <- gcNew dw

  let draw = do
      drawPixbuf dw gc p 0 0 0 0 (-1) (-1) RgbDitherNormal 0 0
      return True
  timeoutAdd draw 500

  onDestroy window mainQuit
  mainGUI
