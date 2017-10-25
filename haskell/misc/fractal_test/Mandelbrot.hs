module Mandelbrot (mandelbrotSet) where

import Data.Word;
import Data.Char;
import System.IO;
import Data.Complex

type Rat = Double

mandelbrot :: (Rat, Rat) -> Word8
mandelbrot !(a, b) = iter 0 0 a b 0 where
  iter !r !i !cr !ci !n
      | r2 + i2 > 4 || n == 50 = n
      | otherwise = iter (r2 - i2 + cr) (2 * r * i + ci) cr ci (n+1)
    where (!r2, !i2) = (r*r, i*i)

mandelbrotSet x y s res = [mandelbrot (scale x s res a, scale y s res b) |
  b <- [0..res-1], a <- [0..res-1] ]

scale :: Rat -> Rat -> Int -> Int -> Rat
scale !o !size !resolution !x = let
    fact = size / fromIntegral resolution
    sum = size * o - size / 2
  in fact * (fromIntegral x) + sum


-- this is only about 20% slower than the tupple version
--mandelbrot :: Complex Rat -> Word8
--mandelbrot !c = iter c 0 where
--  iter !z@(r :+ i) !n
--      | r*r + i*i > 4 || n == 255 = n
--      | otherwise = iter (z*z + c) (n+1)

--mandelbrot :: Complex Rat -> Word8
--mandelbrot !c = fromIntegral $ length $ takeWhile check $ take 255 $ iterate eq 0
--  where eq !z = z * z + c
--        check !(r :+ i) = r*r + i*i <= 2


-- Failed attempts at optimization by ugglification

--mandelbrot :: Rat -> Rat -> Word8
--mandelbrot a b = fromIntegral $ length $
--  takeWhile (\(c,d) -> c*c + d*d <= 2) $ take 255 $
--    iterate (\(c,d) -> (c*c - d*d + a, 2*c*d + b)) (0,0)

--mandelbrotSet x0 y0 s res =
--  let scaleX = scale x0 s res
--      mandelbrot :: Complex Rat -> Complex Rat -> Word8 -> Word8
--      mandelbrot c z@(i :+ r) n | n >= 255 = 255
--                                | i*i + r*r >= 2 = n
--                                | otherwise = mandelbrot c (z * z + c) (n+1)
--      loop y b x | y >= res = []
--                 | x >= res = loop (y+1) (scale y0 s res (y+1)) 0
--                 | otherwise = mandelbrot (scaleX x :+ b) 0 0 : loop y b (x+1)
--    in loop (-1) 0 res

-- This actually _slower_ than the list comprehension version
--printMandelbrotSet :: Handle -> Rat -> Rat -> Rat -> Int -> IO ()
--printMandelbrotSet h x y size res = loopY yi $ fromIntegral res
--  where loopY y 0 = return () :: IO ()
--        loopY y n = do
--          loopX xi y $ fromIntegral res
--          loopY (y + scaleFactor) (n - 1)
--          
--        loopX x y 0 = return () :: IO ()
--        loopX x y n = do
--          hPutChar h $ chr $ fromIntegral $ mandelbrot (x, y)
--          loopX (x + scaleFactor) y (n - 1)
--        
--        scaleFactor = size / fromIntegral res
--        xi = x - size / 2
--        yi = y - size / 2
