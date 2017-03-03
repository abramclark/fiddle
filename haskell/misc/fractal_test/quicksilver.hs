import Data.Complex; import Control.Monad;
import Data.Word; import Foreign hiding (rotate); import Data.IORef;
import Graphics.Rendering.OpenGL; import Graphics.UI.GLUT;
import Data.Time.Clock
import Data.Array.Storable

type Rat = Float

w = 512 :: Int

sc x o s = (fromIntegral x / fromIntegral w - 0.5 + o) * s; sc :: Int -> Rat -> Rat -> Rat
points = [ sc x (-0.25) 2 :+ sc y 0 2 | y <- [0..w-1], x <- [0..w-1] ]
mandelbrot c = fromIntegral $ length $
  takeWhile (\x -> realPart (abs x) <= 2) $ take 255 $
  iterate (\z -> z * z + c) 0; mandelbrot :: Complex Rat -> Word8

--w = 512 :: Int
size = Size (fromIntegral w) (fromIntegral w)
--
--sc :: Int -> Double -> Double -> Double
--sc x o s = (fromIntegral x / fromIntegral w - 0.5 + o) * s
--
--points :: [Complex Double]
--points = [ sc x (-0.25) 2 :+ sc y 0 2 | x <- [0..w-1], y <- [0..w-1] ]
--
--mandelbrot :: Complex Double -> Word8
--mandelbrot c = fromIntegral . length . take 255 
--        . takeWhile (\(xr :+ xi) -> xr*xr+xi*xi <= 4)
--        $ iterate (\z -> z * z + c) 0

main = do
  glInit size

  [tex] <- genObjectNames 1 :: IO [TextureObject]

  start <- getCurrentTime
  withArray (map mandelbrot points) $ \buf -> bindTexture buf w w tex
  end <- getCurrentTime

  putStrLn $ "Time to withArray was " ++ show (end `diffUTCTime` start)
  displayCallback $= display tex
  mainLoop

-- Time to pokeArray was 36.422505s
-- Time to withArray was 35.659046s
-- Time to withArray (rewritten check) was 3.64s

display :: TextureObject -> DisplayCallback
display tex = do
  textureBinding Texture2D $= Just tex
  loadIdentity
  renderPrimitive Quads $ mapM_ (\(x,y,u,v) -> do
      texCoord2 u v
      vertex2 x y)
    [(-1,1,0,1), (1,1,1,1), (1,-1,1,0), (-1,-1,0,0)]
  swapBuffers
  
bindTexture :: Ptr Word8 -> Int -> Int -> TextureObject -> IO ()
bindTexture buf width height tex = do
  textureBinding Texture2D $= (Just tex)
  textureFilter Texture2D $= ((Nearest, Nothing), Linear')
  let tsize = TextureSize2D (fromIntegral width) (fromIntegral height)
  texImage2D Nothing NoProxy 0 Luminance8 tsize 0 (PixelData Luminance UnsignedByte buf)

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
