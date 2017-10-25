import Control.Monad
import System.Environment (getArgs, getProgName)
import System.Exit (exitFailure)
import Text.Read (readMaybe)
import Data.Maybe (fromJust)
import System.Random
import Data.Bits hiding (rotate)
import Data.Array
import Data.Word
import Foreign hiding (rotate)
import Data.IORef
import Graphics.UI.GLUT

type Cell = Double
type Cells = [Cell]
type RuleArgs = [Double]
type Rule = Cell -> Cell -> Cell -> RuleArgs -> Cell

rules = [
   \ a b c _ -> b

  ,\ a b c _ -> snd $ properFraction $ 1.01 * (a + b + c) / 3

  ,\ a b c _ -> snd $ properFraction $ 1.001 * max (a + b) (b + c) / 2

  ,\ a b c _ -> snd $ properFraction $ min (a + b) (b + c) / 1.8

  ,\ a b c _ -> let avg = (a + b + c) / 3 in
    (*) avg (if any ((>0.05).abs) [a-b,a-c,b-c] then 0.8 else 1.01)

  ,\ a b c _ -> if any ((>0.2).abs) [a-b,a-c,b-c]
    then (min a b + min (max a b) c) * 0.49
    else let avg = (a + b + c) / 3 in avg + exp avg / 500

  ,\ a b c p -> let avg = (a + b + c) / 3 in avg + sin avg / head p

  ] :: [Rule]

cellulate :: Rule -> RuleArgs -> Cells -> Cells
cellulate rule args cells = let wrapped = [last cells] ++ cells ++ [head cells] in
  map (\[a,b,c] -> rule a b c args) (takeWhile ((==3) . length) $ map (take 3) $ iterate (drop 1) wrapped)

usage = do
  argv0 <- getProgName
  putStrLn ("Usage: " ++ argv0 ++ " RULE [SEED [P1 P2 ..]]\n" ++
    "  where RULE is 0-" ++ show (length rules - 1) ++
    " and SEED is a natural number" )
  exitFailure

parseArgs :: [String] -> Maybe (Int, Int, RuleArgs)
parseArgs [x1] | Just i <- readMaybe x1 = return (i, 0, [])
parseArgs (x1:x2:xs) = do
  i <- readMaybe x1
  j <- readMaybe x2
  rs <- traverse readMaybe xs
  return (i, j, rs)
parseArgs _ = Nothing

processArgs args = case parseArgs args of
    Just a -> return a
    Nothing -> usage

data SliderState = SliderState {
   panels :: Array Int TextureObject
  ,panelCount :: Int
  ,panelOffset :: Int
  ,panelWidth :: Int
  ,panelHeight :: Int
  ,offset :: Int
  ,panelScale :: GLfloat
  ,offsetScale :: GLfloat
}

main = do
  (rule, seed, args) <- processArgs =<< getArgs
  let w = 1024 :: Int
      h = 512 :: Int
      panelH = 1
      size = Size (fromIntegral w) (fromIntegral h)
      cellsInit = take w $ randomRs (0,1) $ mkStdGen seed :: Cells
      --let cellsInit = (replicate 100 0) ++ [1] ++ (replicate 100 0) ++ (replicate 100 1) ++ [0] ++ (replicate 100 1) ++ (replicate 100 0.5) ++ [0] ++ (replicate 100 0.5) ++ [1] ++ (replicate 100 0.5) ++ ( take 50 (cycle [0,1]) )
      --cellsInit = (replicate 100 0) ++ [1] ++ (replicate 100 0) ++ (replicate 100 1) ++ [0] ++ (replicate 100 1) ++ (replicate 100 0.5) ++ [0] ++ (replicate 100 0.5) ++ [1] ++ (replicate 100 0.5) ++ take 50 (cycle [0,1]) ++ (replicate 100 0) ++ [0, 0.02 .. 1] ++ [1, 0.98 .. 0] ++ (replicate 68 0)
      --cellsInit = [0, 2/1024 .. 2]
      count = 2 + ceiling (fromIntegral h / fromIntegral panelH)
  glInit size
  cellTexes <- genObjectNames count :: IO [TextureObject]
  let sliderState = SliderState {
     panels = listArray (0,count - 1) cellTexes
    ,panelCount = count
    ,panelWidth = w
    ,panelHeight = panelH
    ,panelOffset = 0
    ,offset = 0
    ,panelScale = 2.0 / (fromIntegral count - 2)
    ,offsetScale = panelScale sliderState / fromIntegral panelH
  }

  display (rules!!rule) args sliderState cellsInit
  displayCallback $= return ()
  mainLoop

display :: Rule -> RuleArgs -> SliderState -> Cells -> IO ()
display rule args sliderState cells = do
  --sliderState <- readIORef sliderStateRef
  let rot = offset sliderState == 0
      pOff = panelOffset sliderState
      panelOffset' = if rot then mod (pOff + 1) (panelCount sliderState) else pOff
  cells' <- if rot then cellTex rule args cells (panelWidth sliderState)
    (panelHeight sliderState) (panels sliderState ! panelOffset')
    else return cells
  print (cells !! 10, cells !! 333, cells !! 1000)

  loadIdentity
  translate3 0 (1 - panelScale sliderState) 0
  let x = fromIntegral (offset sliderState) * offsetScale sliderState in
    translate3 0 x 0
  let n = panelCount sliderState - 1
      texNums = take n $ drop (panelOffset' + 1) $ cycle [0..n]
  forM_ texNums $ \texNum -> do
    textureBinding Texture2D $= Just (panels sliderState ! texNum)
    renderPrimitive Quads $ mapM_ (\(x,y,u,v) -> do 
        texCoord2 u v
        vertex2 x y)
      [(-1,0, 0,1), (1,0, 1,1), (1, panelScale sliderState, 1,0),
        (-1, panelScale sliderState , 0,0)]
    translate3 0 (-1 * panelScale sliderState) 0

  swapBuffers
  let offset' = mod (offset sliderState + 1) (panelHeight sliderState)
  addTimerCallback 10 $ display rule args sliderState{
    offset = offset', panelOffset = panelOffset' } cells'

cellTex :: Rule -> RuleArgs -> Cells -> Int -> Int -> TextureObject -> IO Cells
cellTex rule args cells width height tex = do
  let block = take height $ drop 1 $ iterate (cellulate rule args) cells
  --    s = fromIntegral $ width * height :: Double
  buf <- mallocArray (height * width) :: IO (Ptr Word8)
  --pokeArray buf $ map (round.(*510.0).abs.(0.5 -).snd.properFraction.(/2)) [0, 3/s .. 3]
  pokeArray buf $ map (floor.(*510.0).abs.(0.5 -).snd.properFraction.(/2)) (
    concat block)
  textureBinding Texture2D $= Just tex
  textureFilter Texture2D $= ((Nearest, Nothing), Linear')
  let tsize = TextureSize2D (fromIntegral width) (fromIntegral height)
  texImage2D Texture2D NoProxy 0 Luminance8 tsize 0
    (PixelData Luminance UnsignedByte buf)
  return $ last block

glInit size = do
  getArgsAndInitialize
  initialDisplayMode $= [DoubleBuffered, RGBAMode] 
  createWindow "cellular"
  windowSize $= size
  viewport $= (Position 0 0, size)
  matrixMode $= Projection 
  ortho2D (-1) 1 (-1) 1
  matrixMode $= Modelview 0
  texture Texture2D $= Enabled
  textureFunction $= Replace

texCoord2   :: GLfloat -> GLfloat -> IO (); texCoord2 x y = texCoord $ TexCoord2 x y
vertex2     :: GLfloat -> GLfloat -> IO (); vertex2 x y = vertex $ Vertex2 x y
color3      :: GLfloat -> GLfloat -> GLfloat -> IO (); color3 r g b = color $ Color3 r g b
translate3 :: GLfloat -> GLfloat -> GLfloat -> IO (); translate3 x y z = translate $ Vector3 x y z
