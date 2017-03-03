import System.Environment
import Data.Word
import System.Random
import Graphics.UI.Gtk
import Graphics.UI.Gtk.Gdk.PixbufData
import Foreign.Marshal.Array (pokeArray)
import Control.Monad
import Control.Concurrent

--data PlayArea = PlayArea Pixbuf 

[w :: Int, h] = [512, 512]

getPtr buf = do
  (PixbufData pb ptr size) <- pixbufGetPixels buf :: IO (PixbufData Int Word8)
  return ptr

test pb = do
  ptr <- getPtr pb
  pokeArray ptr $ replicate (w * h * 3) 0

makePlayArea = do
  initGUI

  window <- windowNew
  window `onSizeRequest` return (Requisition w h)
  widgetShowAll window
  dw <- widgetGetDrawWindow window
  let d = toDrawable d
  gc <- gcNew dw

  p <- pixbufNew ColorspaceRgb False 8 w h
  ptr <- getPtr p
  pokeArray ptr $ replicate (w * h * 3) 255
  let draw = do
      drawPixbuf dw gc p 0 0 0 0 (-1) (-1) RgbDitherNormal 0 0
      return True
  timeoutAdd draw 500

  onDestroy window mainQuit
  forkOS mainGUI
  return p
