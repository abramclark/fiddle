import Control.Monad; import System; import System.Random; import Data.Bits hiding (rotate); import Data.Array
import Data.Word; import Foreign hiding (rotate); import Data.IORef;
import Graphics.Rendering.OpenGL; import Graphics.UI.GLUT;
import Data.Complex;

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

type Cell = Complex Double
type Cells = [Cell]
type Rule = Cell -> Cell -> Cell -> Cell

rule1 :: Rule
rule1 a b c = let avg = (a + b + c) * (1/3) in avg + (avg ** 2 + 0.75) / 100

cellulate :: Rule -> Cells -> Cells
cellulate rule cells = let wrapped = [last cells] ++ cells ++ [head cells] in
  map (\[a,b,c] -> rule a b c) (takeWhile ((==3) . length) $ map (take 3) $ iterate (drop 1) wrapped)

main = do
  let w = 1024 :: Int
      h = 512 :: Int
      panelH = 1
      size = Size (fromIntegral w) (fromIntegral h)
  glInit size
  --let cellsInit = (replicate 170 False) ++ [True] ++ (replicate 170 False) ++ [True] ++ (replicate 170 False)
  --let cellsInit = (replicate 332 1) ++ [0.5] ++ (replicate 333 1) ++ [0,1,1,0.1,0.1,1,1] ++ (replicate 327 1)
  args <- getArgs
  let rule = read (args!!0) :: Int
      seed = read (args!!1) :: Int
  --let cellsInit = take w $ randomRs (0,1) $ mkStdGen seed :: Cells
  let cellsInit = take w $ map (\[x, y] -> x :+ y) $ map (take 2) $ iterate (drop 2) $ randomRs (0.25,0.75) $ mkStdGen seed

  let count = 2 + (ceiling $ fromIntegral h / fromIntegral panelH)
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

  display rule1 sliderState cellsInit
  displayCallback $= do return ()
  mainLoop

display :: Rule -> SliderState -> Cells -> IO ()
display rule sliderState cells = do
  --sliderState <- readIORef sliderStateRef
  let rot = (offset sliderState) == 0
      pOff = panelOffset sliderState
      panelOffset' = if rot then mod (pOff + 1) (panelCount sliderState) else pOff
  cells' <- if rot then cellTex rule cells (panelWidth sliderState) (panelHeight sliderState)
    (panels sliderState ! panelOffset') else return cells
  putStrLn $ show $ cells'!!20

  loadIdentity
  translate3 0 (1 - panelScale sliderState) 0
  translate3 0 ((fromIntegral $ offset sliderState) * offsetScale sliderState) 0
  let texNums = take n $ drop (panelOffset' + 1) $ cycle [0..n] where n = panelCount sliderState - 1
  forM_ texNums $ \texNum -> do
    textureBinding Texture2D $= (Just (panels sliderState ! texNum))
    renderPrimitive Quads $ mapM_ (\(x,y,u,v) -> do 
        texCoord2 u v
        vertex2 x y)
      [(-1,0, 0,1), (1,0, 1,1), (1,(panelScale sliderState), 1,0), (-1,(panelScale sliderState), 0,0)]
    translate3 0 (-1 * panelScale sliderState) 0

  swapBuffers
  let offset' = mod (offset sliderState + 1) (panelHeight sliderState)
  addTimerCallback 10 (display rule sliderState{ offset = offset', panelOffset = panelOffset' } cells')

cellTex :: Rule -> Cells -> Int -> Int -> TextureObject -> IO Cells
cellTex rule cells width height tex = do
  let block = take height $ drop 1 $ iterate (cellulate rule) cells
  buf <- mallocArray (height * width * 3) :: IO (Ptr Word8)
  pokeArray buf $ map (round.(*510.0).abs.((-) 0.5).(snd . properFraction)) $
    concat $ map (\x -> [0.5, realPart x, imagPart x]) $ concat $ block
  textureBinding Texture2D $= (Just tex)
  textureFilter Texture2D $= ((Nearest, Nothing), Linear')
  let tsize = TextureSize2D (fromIntegral width) (fromIntegral height)
  texImage2D Nothing NoProxy 0 RGB8 tsize 0 (PixelData RGB UnsignedByte buf)
  return $ last block

glInit size = do
  getArgsAndInitialize
  initialDisplayMode $= [DoubleBuffered, RGBAMode] 
  createWindow "cellular"
  windowSize $= size
  viewport $= ((Position 0 0), size)
  matrixMode $= Projection 
  ortho2D (-1) 1 (-1) 1
  matrixMode $= Modelview 0
  texture Texture2D $= Enabled
  textureFunction $= Replace

texCoord2   :: GLfloat -> GLfloat -> IO (); texCoord2 x y = texCoord $ TexCoord2 x y
vertex2     :: GLfloat -> GLfloat -> IO (); vertex2 x y = vertex $ Vertex2 x y
color3      :: GLfloat -> GLfloat -> GLfloat -> IO (); color3 r g b = color $ Color3 r g b
translate3 :: GLfloat -> GLfloat -> GLfloat -> IO (); translate3 x y z = translate $ Vector3 x y z
