{-# LANGUAGE TypeFamilies #-} -- remove later
{-# OPTIONS_GHC -Wall #-}
----------------------------------------------------------------------
-- |
-- Module      :  Test
-- Copyright   :  (c) Conal Elliott 2008
-- License     :  BSD3
-- 
-- Maintainer  :  conal@conal.net
-- Stability   :  experimental
-- 
-- Test Reactive + FieldTrip
----------------------------------------------------------------------

module Test where

import Data.Monoid
import Control.Applicative

import Data.VectorSpace

import FRP.Reactive
import FRP.Reactive.GLUT.Adapter

import Graphics.FieldTrip
-- For Vector3 VectorSpace instance.  Why not gotten from previous import?
-- This one doesn't work either.
-- import Graphics.FieldTrip.Vector3

import FRP.Reactive.FieldTrip

-- remove the next batch (and the unamb dependency in
-- reactive-fieldtrip.cabal) when done debugging.
import FRP.Reactive.Internal.Future
import FRP.Reactive.Internal.Reactive
import Data.Unamb
import Control.Arrow (first)


main :: IO ()
main = -- anim2 $ pure.pure $ txt
       -- anim2 $ pure $ rotTxt <$> time
       -- anim2 track
       -- anim2 $ revTxt "Click me!"
       anim3 spin
       -- anim2 spin'
       -- anim2 times
       -- (anim2 . showE) (withPrevE' . snapshot_ time . framePass)
       -- anim2 $ (fmap.fmap) rotTxt (uiIntegral signFlip)
       -- anim3 $ (pure.pure) (move3Z (-5::R) (uscale3 (0.5::R) *% torusPair))
       -- anim3 $ drops . leftButtonPressed
       -- anim3 ldrops
       -- anim3 lplace
       -- anim3 motionTxt
       -- anim2 $ (fmap.fmap) utext typing
       -- anim2 rotType

showE :: Show a => (UI -> Event a) -> Anim2
showE f u = utext <$> ("" `stepper` (show <$> f u))

txt :: Geometry2
txt = utext "Reactive + FieldTrip"

times :: Anim2
times u = (utext.show) <$> theTime u

-- steps :: Anim TimeT
-- steps u = 1 `stepper` (20 <$ framePass u)

theTime :: Anim TimeT
-- theTime = steps
theTime = uiIntegral (const 1)
-- theTime = const time

-- Tue Dec 30 17:21:33 2008: when I use the uiIntegral definition, I don't
-- get updates past the first one.  Memory use shoots up to 1.7GB, and CPU
-- to 100% of a processor.
-- 
-- The problem seems to be from withPrevE, which uses joinMaybes.

-- Here's a version without joinMaybes.  Runs fine.

-- withPrevE' :: (Ord t, Bounded t) => EventG t a -> EventG t (Maybe (a,a))
-- withPrevE' e = ({- joinMaybes .-} fmap combineMaybes) $
--                (Nothing,Nothing) `accumE` fmap (shift.Just) e
--  where
--    -- Shift newer value into (new,old) pair if present.
--    shift :: u -> (u,u) -> (u,u)
--    shift newer (new,_) = (newer,new)
--    combineMaybes :: (Maybe u, Maybe v) -> Maybe (u,v)
--    combineMaybes = uncurry (liftA2 (,))


-- Here's one that uses justE.  It's easy on memory but doesn't produce
-- any output other than two of "<interactive>: <<loop>>".

withPrevE' :: (Ord t, Bounded t) => EventG t a -> EventG t (a,a)
withPrevE' e = (justE' . fmap combineMaybes) $
               (Nothing,Nothing) `accumE` fmap (shift.Just) e
 where
   -- Shift newer value into (new,old) pair if present.
   shift :: u -> (u,u) -> (u,u)
   shift newer (new,_) = (newer,new)
   combineMaybes :: (Maybe u, Maybe v) -> Maybe (u,v)
   combineMaybes = uncurry (liftA2 (,))


justE' :: (Ord t, Bounded t) => EventG t (Maybe a) -> EventG t a
justE' ~(Event (Future (t, mb `Stepper` e'))) =
  assuming (t == maxBound) mempty `unamb`
  (inEvent.inFuture.first) (max t) $
    case mb of
      Nothing -> justE e'
      Just a  -> Event (Future (t, a `Stepper` justE e'))



-- Accumulate function applications on each left button press
accumLB :: a -> (a->a) -> Anim a
accumLB a f ui = a `accumB` (f <$ leftButtonPressed ui)

-- Flip between 1 & -1 on left button press
signFlip :: Anim Double
signFlip = accumLB 1 negate

-- Reverse text on left button press
revTxt :: String -> Anim2
revTxt str = (fmap.fmap) utext (accumLB str reverse)

-- revTxt str ui = utext <$> accumLB str reverse ui
-- revTxt = (fmap.fmap.fmap) utext (flip accumLB reverse)

rotTxt :: Double -> Geometry2
rotTxt t = rotate2 t *% txt


rotType :: Anim2
rotType = (liftA2.liftA2) h (uiIntegral signFlip) typing
 where
   h :: Double -> String -> Geometry2
   h ang str = rotate2 ang *% utext str


motionTxt :: Anim3
motionTxt = (fmap.fmap) (flatG . (uscale2 (0.5::R) *%) . utext . show) mouseMotion

typing :: Anim String
typing u = reverse <$> (accumB "" ((:) <$> charPressed' u))

-- This one lags a character.  Probably due to the joinMaybes
charPressed :: UI -> Event Char
charPressed u = joinMaybes (char <$> keyPressed u)
 where
   char (Char ch) = Just ch
   char _         = Nothing

-- This one has no lag.
charPressed' :: UI -> Event Char
charPressed' u = char <$> keyPressed u
 where
   char (Char ch) = ch
   char _         = '_'

-- also try monoidB



track :: Anim2
track = (fmap.fmap) (f . uncurry Vector2) mousePosition
 where
   f = (uscale2 (0.5::Float) *%) . utext . show


-- spinAng :: Anim (Transform2 TimeT)
spinI :: UI -> Behavior (Transform2 TimeT)
spinI u = rotate2 <$> uiIntegral 1 u

spin' :: Anim2
spin' u = spinI u *% (pure txt :: Behavior Geometry2)


spin :: Anim3
spin = const . spinningG $
         -- usphere
         torusPair
         -- flatG txt

torusPair :: Geometry3
torusPair = f red (1/2) `mappend` pivot3X (f green (-1/2))
 where
   tor = torus 1 (2/5)
   f :: Col -> R -> Geometry3
   f col dx = materialG (plastic col) (move3X dx tor)

-- Start at zero with a velocity of one.  Negate velocity on each event occurrence.
reverseVel :: (UI -> Event a) -> Anim Double
reverseVel ue = uiIntegral vel
 where
    vel ui = 1 `accumB` (negate <$ ue ui)


-- Drop a ball on each event occurrence
drops :: Event () -> Behavior Geometry3
drops e = monoidB (g <$> withTimeE_ e)
 where
   g0   = uscale3 (0.3 :: R) *% torusPair
   g t0 = (f <$> time) *% pure g0
    where
      f t = translate3 (Vector3 (t-t0) 0 (-5))

-- -- Experiment.  Ought to be picked up from Vector3.
-- instance AdditiveGroup u => AdditiveGroup (Vector3 u) where
--   zeroV                   = Vector3 zeroV zeroV zeroV
--   Vector3 u v w ^+^ Vector3 u' v' w'
--                           = Vector3 (u^+^u') (v^+^v') (w^+^w')
--   negateV (Vector3 u v w) = Vector3 (negateV u) (negateV v) (negateV w)
-- instance VectorSpace u => VectorSpace (Vector3 u) where
--   type Scalar (Vector3 u) = Scalar u
--   s *^ Vector3 u v w      = Vector3 (s*^u) (s*^v) (s*^w)


-- Drop a ball on each event occurrence
drops' :: Event (Vector3 Double) -> Event () -> Behavior Geometry3
drops' starts tick = monoidB (g <$> (tick `snapRemainderE` starts))
 where
   g0              = uscale3 (0.3 :: R) *% torusPair
   g (start,tick') = f <$> integral tick' (integral tick' acc)
     where
       f pos = translate3 (start ^+^ pos) *% g0
   acc             = pure ((-2) *^ yVector3)

-- Drop a ball from the mouse on each left button press.
ldrops :: Anim3
ldrops = liftA2 drops' (liftA2 snapshot_ mouseMotion leftButtonPressed)
                       framePass

-- ldrops ui =
--   drops' (leftButtonPressed ui `snapshot_` mouseMotion ui)
--          (framePass ui)

-- Place a ball on each event occurrence
place :: Event (Vector3 Double) -> Behavior Geometry3
place starts = monoidB (g <$> starts)
 where
   g start = (translate3 start *%) <$> spinningG torusPair

-- Drop a ball from the mouse on each left button press.
lplace :: Anim3
lplace = place <$> liftA2 snapshot_ mouseMotion leftButtonPressed

-- lplace ui = place (leftButtonPressed ui `snapshot_` mouseMotion ui)


spring0 :: Vector3 Double -> Anim (Vector3 Double) -> Anim (Vector3 Double)

-- spring0 _ = id

-- spring0 pos0 _ u = pos
--  where
--    pos, vel :: Behavior (Vector3 Double)
--    pos  = pure pos0 ^+^ integ vel
--    vel  = pure $ vector3 0 (-1) 0
--    integ = integral (framePass u)

spring0 pos0 target u = pos
 where
   pos, vel :: Behavior (Vector3 Double)
   pos  = pure pos0 ^+^ integ vel
   vel  = target u ^/ mass
   mass = 1
   integ = integral (framePass u)

spring1 :: Vector3 Double -> Anim (Vector3 Double) -> Anim (Vector3 Double)
spring1 pos0 target u = pos
 where
   pos, vel :: Behavior (Vector3 Double)
   pos  = pure pos0 ^+^ integ vel
   vel  = (target u ^-^ pos) ^/ mass
   mass = 1
   integ = integral (framePass u)

-- Spring pulling a 
spring :: Vector3 Double -> Anim (Vector3 Double) -> Anim (Vector3 Double)
spring pos0 target u = pos
 where
   pos, vel, acc :: Behavior (Vector3 Double)
   pos  = pure pos0 ^+^ integ vel
   vel  = pure vel0 ^+^ integ acc
   acc  = (target u ^-^ pos) ^/ mass
   mass = 1
   vel0 = zeroV :: Vector3 Double
   integ = integral (framePass u)

springy :: Anim3
springy u = (translate3 <$> spring1 zeroV target u) *% pure usphere
 where
   target = -- mouseMotion
            -- const $ liftA3 vector3Spherical 1 time (pi/2)
            const $ liftA3 vector3 1 1 0

-- All three target variations get stuck.  Hm.

----

mouseMotion :: Anim (Vector3 Double)
mouseMotion = (fmap.fmap) f mousePosition
 where
   f (mx,my) = vector3 mx my 0

spinningG :: Geometry3 -> Behavior Geometry3
spinningG g = liftA2 (*%) spinning (pure g)

spinning :: Behavior (Transform3 Double)
spinning = xf . (*2) <$> time
 where
   xf t =           translate3 (Vector3 (0::Double) 0 (3*sin (-t/5)))
          `mappend` rotate3 t (Vector3 0.1 0.2 0.3)
          `mappend` uscale3 0.2

-- Strange bug: if I increase the scale factor more than a tiny amount
-- above 0.28, I get flat white shading.
