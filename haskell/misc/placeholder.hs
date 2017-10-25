ucase_infer xs _ | const False (xs :: String) = undefined
ucase_infer xs ph = map ph xs
ucase xs = ucase_infer xs undefined

-- ucase :: String -> <ph>
-- ucase s = map <ph> s

fac :: Int -> Int
fac 1 = 1
fac n = fac_infer n undefined
fac_infer n ph = fac (n - 1) * ph

-- fac :: Int -> Int
-- fac 1 = 1
-- fac n = fac (n - 1) * <ph>


data Exp a where
  Zero :: Exp Int
  One :: Exp Int
  Plus :: Exp Int -> Exp Int -> Exp Int
  IsZero :: Exp Int -> Exp Bool
  If :: Exp Bool -> Exp a -> Exp a -> Exp a


--[xs, ys, ss, rs, gs, bs] <- mapM (replicateM 20 . randomRIO)
--  [(0, fromIntegral sizeX), (0, fromIntegral sizeY), (5, 300), (0, 1), (0, 1), (0, 1)] :: IO [[Rat]]
--ws <- mapM (\s -> randomRIO (1, s/4)) ss
--let xyswc = zip5 xs ys ss ws $ zip3 rs gs bs
--let updater (r1, g1, b1) (r2, g2, b2) a = (blend r1 a r2, blend g1 a g2, blend b1 a b2)
--mapM_ (\ (x,y,s,w,c) -> updateElems (updater c) picture $ drawCircle x y s w) xyswc
--
--drawCircle :: Rat -> Rat -> Rat -> Rat -> [((Int, Int), Rat)]
--drawCircle x y r w =
--  let rr = ceiling r; wr = ceiling w
--      xh = round x; xf = frac x
--      yh = round y; yf = frac y
--      dists :: [((Int, Int), Rat)]
--      dists = [((y, x),
--            abs $ ((fromIntegral x + xf)**2 + (fromIntegral y + yf)**2) ** 0.5 - r)
--          | x <- span, y <- span, abs x + abs y > rr - wr - 1]
--        where span = [-rr - wr .. rr + wr]
--    in map (\ ((b, a), d) -> ((b+yh, a+xh), 1 - d / w))
--      $ filter ((< w) . snd) dists
