import Graphics.UI.Gtk hiding (fill)
import Graphics.Rendering.Cairo
import Data.Time.Clock.POSIX

frac = snd . properFraction

modf a b = frac (a / b) * b

normalizeAngle a | a < 0 = 2*pi + (a `modf` (2*pi))
normalizengle a         = a `modf` (2*pi)

floorf = fromInteger . fst . properFraction

angularDistance a b =
  f (na - nb)
  where na = normalizeAngle a
        nb = normalizeAngle b
        f a | a > pi  = a - 2*pi
        f a | a < -pi = a + 2*pi
        f a           = a

cylinderProjection r (x, y) = (r * sin (x/r), y)

scaleP f (x,y) = (x*f, y*f)
translateP u v (x,y) = (x+u, y+v)
rotateP a (x,y) = (cos a * x - sin a * y, sin a * x + cos a * y)

gon n =
  map nrot [0..n-1]
  where nrot i = let a = 2*pi*i/n in
                 (cos a, sin a)
hexagon = gon 6

drawHexagon col rot r rows i = do
  let y = if floor i `mod` 2 == 0
          then 0
          else 1.732
  let rhex = map (scaleP (2*pi*r/rows) . translateP (rows*rot/(2*pi) + i) (y+col*1.732*2) . rotateP (pi/2)) hexagon
  let hex = map (cylinderProjection r) rhex
  save
  newPath
  uncurry moveTo $ head hex
  mapM_ (uncurry lineTo) hex
  closePath
  setLineWidth 1
  if floor (i+col) `mod` 4 == 0
    then fill
    else stroke
  restore

drawHexagons col rot r rows i = do
  drawHexagon col rot r rows (i*2)
  drawHexagon col rot r rows (i*2+1)

exposeHandler widget = do
  drawWin <- widgetGetRootWindow widget
  (wi,hi) <- widgetGetSizeRequest widget
  let (w,_) = (realToFrac wi, realToFrac hi)
  t <- getPOSIXTime
  let rot = normalizeAngle $ realToFrac t / 5
  let rows = 50
  let columns = 20
  let radius = 150
  let hexagonRadius = 2*pi*radius / rows
  renderWithDrawWindow drawWin $ do
    save
    setSourceRGBA 1 1 1 1
    paint
    setSourceRGBA 0 0 0 1
    translate (w/2) (-3*hexagonRadius)
    mapM_ (\i -> mapM_ (drawHexagons i rot radius rows) [i*2..i*2+rows/6-4])
      [0..columns-1]
    scale 0.5 0.5
    mapM_
      (\i -> mapM_ (drawHexagons i (-rot*4) radius rows) [i*2..i*2+rows/6-4])
      [0..columns*2-1]
    restore
  widgetQueueDraw widget
  return True

main = do
  initGUI
  window <- windowNew
  windowSetDefaultSize window 410 450
  widgetShowAll window
  window `on` exposeEvent $ liftIO (exposeHandler window) >> return False
  mainGUI
