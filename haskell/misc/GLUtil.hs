module GLUtil (with
              ,LocalSetting (Preserving, (:=))
              ,circle
              ,vertex2f
              ,rotate1f
              ,translate2f
              ,scale2f
              ,color4f
              ) where

import Graphics.Rendering.OpenGL
import Control.Monad

data LocalSetting =
      forall a g . (HasGetter g,HasSetter g) => g a := a
    | forall a g . (HasGetter g,HasSetter g) => Preserving (g a)

save (a := b)       = (a :=) `fmap` get a
save (Preserving a) = (a :=) `fmap` get a

apply (a := b)       = a $= b
apply (Preserving a) = return ()

with :: [LocalSetting] -> IO t -> IO t
with lss act = do olds <- mapM (\ls -> do saved <- save ls
                                          apply ls
                                          return saved) lss
                  ret <- act
                  mapM_ (\ls -> apply ls) (reverse olds)
                  return ret

circle radius = renderPrimitive LineLoop $ lines 0
    where lines a = when (a < 2 * pi) $ do
            vertex2f (sin a * radius) (cos a * radius)
            lines $ a + min (2 * pi / 20) (2 * pi / (radius * 100))

vertex2f :: Float -> Float -> IO ()
vertex2f a b = vertex $ Vertex2 a b
rotate1f a = rotate a $ Vector3 0 0 (-1 :: Float)
translate2f a b = translate $ Vector3 a b (0 :: Float)
scale2f a b = scale (a :: Float) b 1
color4f a b c d = currentColor $= Color4 a b c d
