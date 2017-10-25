-- Haskell Game Clock --
--
-- Features:
-- Two analogue clock styles
-- Per move time, and option to acumulate leftover move time
-- Gui for entering times and options
-- Command line arguments for times and config to bypass gui

import Graphics.Rendering.OpenGL
import GLUtil
import Graphics.UI.GLFW;
import System.Environment
import Numeric
import System.Exit
import Control.Monad
import Data.Complex
import Data.IORef

data State = State {
     ab :: (Float, Float)
    ,cd :: (Float, Float)
    ,size :: Size
    }

main :: IO ()
main = do
    args <- getArgs
    let nums = map (fst . head . readSigned readFloat) args
        state = case nums of
            [a, b, c, d] -> State (a, b) (c, d) (Size 800 800)
            _ -> State (1, 2) (2, 1) (Size 800 800)

    -- GLFW initialization
    status <- initialize
    when (not status) exitFailure
    status <- openWindow (size state) [DisplayAlphaBits 8] Window
    when (not status) exitFailure
    windowTitle $= "Game Clock"
    windowCloseCallback $= exitWith ExitSuccess

    -- OpenGL init (for antialiasing)
    lineSmooth $= Enabled
    blend      $= Enabled
    blendFunc  $= (SrcAlpha, OneMinusSrcAlpha)
    lineWidth  $= 2

    stateRef <- newIORef $ state
    windowSizeCallback $= (\s@(Size w h) -> do
        viewport $= (Position 0 0, s)
        modifyIORef stateRef (\x -> x { size = s }))
    mouseButtonCallback $= clicked stateRef
    forever waitEvents

clicked stateRef button buttonState | buttonState == Press = return ()
                                    | buttonState == Release = do
    state <- readIORef stateRef

    Position a b <- get mousePos
    let Size w h = size state
        [x, y] = zipWith (\p s -> (fromIntegral p / fromIntegral s) * 6 - 3) [a, h - b] [w, h]

    let state2 = case button of
            ButtonLeft  -> state { ab = (x, y) }
            ButtonRight -> state { cd = (x, y) }
            _ -> state
        c = (\(a,b) (c,d) -> (a,b,c,d)) (ab state2) (cd state2)

    writeIORef stateRef state2
    print c
    draw c

draw c = do
    let rect = renderPrimitive Quads $ do
            let s = 1
            vertex2f (-s) ( s)
            vertex2f ( s) ( s)
            vertex2f ( s) (-s)
            vertex2f (-s) (-s)
        fancyPoint (px, py) = preservingMatrix $ do
            translate2f px py
            scale2f 0.05 0.05
            color4f 0.3 0.3 0.8 0.004
            rect
            scale2f 0.06 0.06
            color4f 0.8 0 0 0.1
            rect
        line ((px1,  py1), (px2, py2), c) = renderPrimitive Lines $ do
            color4f 1 c 1 1
            vertex2f px1 py1
            vertex2f px2 py2
        colors = cycle (r ++ reverse r) where r = [0, 1/255 .. 1]
        dejong (a, b, c, d) (x, y) = (sin (a*y) - cos (b*x), sin (c*x) - cos (d*y))
        dejongSet = take 300000 $ iterate (dejong c) (0, 0)

    clear [ColorBuffer]
    color4f 0 0 1 0.004
    preservingMatrix $ do
        scale2f 0.4 0.4
        mapM fancyPoint dejongSet
        --mapM line $ zip3 dejongSet (drop 1 dejongSet) colors
    swapBuffers
