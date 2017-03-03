import Mandelbrot
--import Prelude hiding (foldr,foldl,length,take,iterate,takeWhile,map)
--import Data.List.Stream;
import Data.Complex; import Control.Monad;
import Data.Word; import Foreign hiding (rotate); import Data.IORef;
import Graphics.Rendering.OpenGL; import Graphics.UI.GLUT;

type Rat = Float

main = do
  let w = 512 :: Int
      size = Size (fromIntegral w) (fromIntegral w)
  glInit size

  [tex] <- genObjectNames 1 :: IO [TextureObject]
  withArray (mandelbrotSet (-0.25) 0 2 512) $ \buf -> bindTexture buf w w tex
  displayCallback $= display tex
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
