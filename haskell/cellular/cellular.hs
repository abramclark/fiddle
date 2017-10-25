import qualified Graphics.UI.Gtk as G; import GtkJunk;
import Data.Bits; import Data.Array; import Data.IORef; import Control.Monad;
import System.Random;

type Rule = Array (Bool,Bool,Bool) Bool

-- Haskellification of Wolfram's rule naming
nLSBits n x = map ((x::Int) `testBit`) [0..n-1]
makeRule :: Int -> Rule
makeRule id = array ((False,False,False),(True,True,True)) $ zip
  (map ((\[a,b,c] -> (a,b,c)) . reverse . (nLSBits 3)) [0..7]) (nLSBits 8 id)

cellulate :: Rule -> [Bool] -> [Bool]
cellulate rule cells = let cells' = [last cells] ++ cells ++ [head cells] in
  map (\[a,b,c] -> rule!(a,b,c)) (takeWhile ((==3) . length) $ map (take 3) $ iterate (drop 1) cells')

main = do
  let w = 1200
      h = 500
  G.initGUI
  window <- G.windowNew
  pixbuf <- G.pixbufNew G.ColorspaceRgb False 8 w h
  canvas <- G.drawingAreaNew
  canvas `G.onSizeRequest` return (G.Requisition w h)
  --canvas `G.onExpose` updateCanvas canvas pixbuf
  G.set window [ G.containerChild G.:= canvas ]
  G.onDestroy window G.mainQuit
  G.widgetShowAll window
  win <- G.widgetGetDrawWindow canvas
  gc <- G.gcNew win

  args <- getArgs
  let rule = makeRule $ (read (args!!0) :: Int)
  --let cells1 = take w $ randoms $ mkStdGen (read (args!!1) :: Int) :: [Bool]
  let cells1 = (replicate 399 False) ++ [True] ++ (replicate 399 False) ++ [True] ++ (replicate 400 False)
  cellsRef <- newIORef cells1

  let drawLine = do
        cells <- readIORef cellsRef
        let cells' = cellulate rule cells
        let newLine = listArray ((0,0),(w-1,0)) $ map
              (\x -> let v = if x then 255 else 0 in Colour (v,v,v))
              cells' :: Array (Int,Int) Colour
        G.pixbufCopyArea pixbuf 0 1 w (h-2) pixbuf 0 0
        pixbufDrawRegion pixbuf newLine 0 (h-2) w 1

        G.drawWindowBeginPaintRect win (G.Rectangle 0 0 w h)
        G.drawPixbuf win gc pixbuf 0 0 0 0 (-1) (-1) G.RgbDitherNone 0 0
        G.drawWindowEndPaint win
        --updateCanvas canvas pixbuf

        writeIORef cellsRef cells'
        return True
 
  G.timeoutAdd drawLine 20
  G.mainGUI
