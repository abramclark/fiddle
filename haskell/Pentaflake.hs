{-# LANGUAGE NoMonomorphismRestriction #-}

{- | A first example of drawing diagrams from within GTK.  This 
     program draws a Koch snowflake with the depth controllable
     via a GTK widget.
-}
module Main where

import Graphics.UI.Gtk
import Diagrams.Prelude
import Diagrams.TwoD.Adjust (adjustSize)
import Diagrams.Backend.Cairo.Gtk
import Diagrams.Backend.Cairo (Cairo)
import qualified Data.Colour as C


-- Our drawing code, copied from
-- projects.haskell.org/diagrams/gallery/Pentaflake.html
colors = iterate (C.blend 0.1 white) blue

p = regPoly 5 1 # lw 0

-- | create a snowflake diagram of depth @n@ 
-- 
-- specifying a type here because the monoidal query type needs to be specified
-- for @drawToGtk@, otherwise get a "No instance for (PathLike ..." error.
pentaflake :: Int -> Diagram Cairo R2
pentaflake 0 = p

pentaflake n = appends (p' # fc (colors !! (n-1)))
                       (zip vs (repeat (rotateBy (1/2) p')))
  where vs = take 5 . iterate (rotateBy (1/5))
                    . (if odd n then negateV else id) $ unitY
        p' = pentaflake (n-1)

pentaflake' n = pentaflake n # fc (colors !! n)

-- end of diagrams code

-- A function to set up the main window and signal handlers
createMainWindow = do
  win <- windowNew
  onDestroy win mainQuit
  drawArea <- drawingAreaNew
  depthWidget <- spinButtonNewWithRange 1 10 1

  -- when the spinButton changes, redraw the window
  depthWidget `onValueSpinned` (widgetQueueDraw drawArea)

  -- handle the drawArea's @onExpose@ signal.  We provide a function
  -- that takes an area marked as dirty and redraws it.
  -- This program simply redraws the entire drawArea.
  --
  -- Many gtk signal handlers return True if the signal was handled, and False
  -- otherwise (in which case the signal will be propagated to the parent).
  
  drawArea `onExpose` \_dirtyRect -> do
    -- can't draw to a drawArea directly (this is a limitation of gtk2hs),
    -- so first we retrieve the drawWindow and render to that instead.
    -- Drawing to GTK requires that we manually specify the size
    -- and positioning,
    --
    -- however we can use @adjustSize@ to calculate the necessary rescaling
    -- for a full-scale image
    --
    -- the @toGtkCoords@ function performs two tasks.  It centers the diagram
    -- in the drawWindow, and reflects it about the Y-axis.  The Y-axis
    -- reflection is due to an orientation mismatch between Cairo and
    -- diagrams.
    (canvasX,canvasY) <- widgetGetSize drawArea  -- size in pixels (Int)
    curDepth <- spinButtonGetValueAsInt depthWidget
    let dia = pentaflake curDepth
        fI  = fromIntegral
        spec = mkSizeSpec (Just $ fI canvasX) (Just $ fI canvasY)
        scaledDia = toGtkCoords $ transform (adjustSize spec (size2D dia)) dia
    drawWindow <- widgetGetDrawWindow drawArea
    renderToGtk drawWindow scaledDia
    return True

  -- add the depthWidget control and drawArea to the main window
  hbox <- hBoxNew False 0
  boxPackStart hbox depthWidget PackNatural 0
  boxPackStart hbox drawArea PackGrow 0
  containerAdd win hbox
  return win

-- Gtk application
-- 
-- initial the library, create and show the main window,
-- finally enter the main loop
main :: IO ()
main = do
  initGUI
  win <- createMainWindow
  widgetShowAll win
  onDestroy win mainQuit
  onSizeRequest win $ return (Requisition 200 200) -- request minimum size
  mainGUI
  
