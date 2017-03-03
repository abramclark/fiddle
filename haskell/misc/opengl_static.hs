import Prelude hiding (take, cycle, sum, (!!), drop)
import Control.Monad; import Data.Word; import Foreign hiding (rotate);
import Graphics.Rendering.OpenGL; import Graphics.UI.GLUT;
--import System.Random
import Data.List.Stream
import Control.Monad.State
import System.Random.Mersenne
import GHC.Exts
import Control.Concurrent

funkyRand :: Double -> (Word8, Double)
funkyRand x = -- (x, mod (x + 1) 251)
    let n = x * x
        (_, s) = properFraction n
      in (floor $ s * 255, if x > 50000 then s + 13478 else s + x)

--rangeTest :: Word8 -> [Word8]
rangeTest n = n : (rangeTest $ mod (n + 1) 251)

main = do
  mtgen <- newMTGen Nothing
  let w = 256 :: Int
      h = 256
      size = Size (fromIntegral w) (fromIntegral h)
  glInit size

  [tex] <- genObjectNames 1 :: IO [TextureObject]
  --let static = map fromIntegral $ take (w * w) $ (randomRs (0,255) (mkStdGen 1) :: [Int])
  --let static = map fromIntegral $ take (w * w) $ map (floor . (*255)) $ unfoldr (Just . funkyRand) 1000.55587120987 -- cycle [0,255] -- (randomRs (0,255) (mkStdGen 1) :: [Int])
  --withArray static $ bindTexture w w tex

  --display tex

  let loopDisplay s = do
        static <- liftM (take $ w * h) $ randoms mtgen :: IO [Word8]; let nextSeed = s
        --let (static, nextSeed) = (take (w * h) $ drop s $ rangeTest 0, mod (s + 1) 255)
        --let (static, nextSeed) = runState (replicateM (w * h) (State funkyRand)) s
        withArray static $ bindTexture w h tex
        display tex
        --threadDelay 30000
        --loopDisplay nextSeed
        addTimerCallback 30 $ loopDisplay nextSeed -- $ mod (s + 1) 255
        return ()

  --displayCallback $= display tex
  loopDisplay 92357.1234123 -- (randomRs (0,255) (mkStdGen 1) :: [Int])

  mainLoop

display :: TextureObject -> DisplayCallback
display tex = do
  textureBinding Texture2D $= Just tex
  loadIdentity
  renderPrimitive Quads $ mapM_ (\(x,y,u,v) -> do
      texCoord2 u v
      vertex2 x y)
    [(-1,1,0,1), (1,1,1,1), (1,-1,1,0), (-1,-1,0,0)]
  swapBuffers
  
bindTexture :: Int -> Int -> TextureObject -> Ptr Word8 -> IO ()
bindTexture width height tex buf = do
  textureBinding Texture2D $= (Just tex)
  textureFilter Texture2D $= ((Nearest, Nothing), Linear')
  let tsize = TextureSize2D (fromIntegral width) (fromIntegral height)
  texImage2D Nothing NoProxy 0 Luminance8 tsize 0 (PixelData Luminance UnsignedByte buf)

glInit size = do
  getArgsAndInitialize
  initialDisplayMode $= [DoubleBuffered, RGBAMode] 
  createWindow "Open GL Texture Demo"
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
