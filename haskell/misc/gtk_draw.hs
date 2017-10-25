import System.Environment
import Data.Word
import System.Random
import Graphics.UI.Gtk
import Graphics.UI.Gtk.Gdk.PixbufData
import Foreign.Marshal.Array
import Control.Monad
import Control.Concurrent

[w :: Int, h] = [512, 512]

getPtr buf = do
  (PixbufData pb ptr size) <- pixbufGetPixels buf :: IO (PixbufData Int Word8)
  return ptr

main = do
  initGUI

  window <- windowNew
  window `onSizeRequest` return (Requisition w h)
  widgetShowAll window
  dw <- widgetGetDrawWindow window
  gc <- gcNew dw

  --p <- pixbufNew ColorspaceRgb False 8 w h
  --ptr <- getPtr p
  --pokeArray ptr $ replicate (w * h * 3) 0
  gcv <- gcGetValues gc
  gcSetValues gc $ gcv { foreground = Color 65535 0 0 }
  let draw = do
      drawRectangle dw gc True 50 50 200 100
      --drawPixbuf dw gc p 0 0 0 0 (-1) (-1) RgbDitherNormal 0 0
      return True
  timeoutAdd draw 2000


  onDestroy window mainQuit
  mainGUI
