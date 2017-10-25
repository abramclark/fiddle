-- PHPNG.hs (C) 2008, Abram Clark
-- This code is distributed under the terms of the GNU GPL.
-- See www.gnu.org for more information. 
--
-- This code provides functions for reading and writing PNG
-- data (ByteStrings) and files.

module PHPNG (
     ColorRGBA  (ColorRGBA )
    ,ColorRGB   (ColorRGB  )
    ,ColorGreyA (ColorGreyA)
    ,ColorGrey  (ColorGrey )
    ,ColorIndex (ColorIndex)
    ,Background (BGRGB, BGGrey, BGIndex)
    ,newImage
    ,encodeImage
    ,decodeImage
    ,getCType
    ,getBitDepth
    ,setImageList
    ,setImageArray
    ,setPalette 
    --,setImage8
    ,setCType
    ,setSize
    ,setInterlaced
    ,setBitDepth
    ,setTime
    ,setBG
    ,setTimeToNow
    ,transpose2DA
  ) where

import Bits
import System.IO
import Control.Monad
import Data.Maybe
import Data.Word
import Data.Char
import Data.List
import Data.Int
import Data.Binary
import Data.Binary.Put
import Data.Binary.Get
import Data.Array.IArray
import Data.Time
import qualified Data.Array.Unboxed as UA
import qualified Data.Array.IArray as IA
import qualified Data.Array.MArray as MA
import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Lazy.Char8 as BC
import Codec.Compression.Zlib
import System.Random

newtype ColorRGBA   = ColorRGBA  (Double,Double,Double,Double)
newtype ColorRGB    = ColorRGB   (Double,Double,Double)
newtype ColorGreyA  = ColorGreyA (Double,Double)
newtype ColorGrey   = ColorGrey  Double
newtype ColorIndex  = ColorIndex Word8

class Encode16 a where encode16 :: a -> [Word16]
class CType    a where cType    :: a -> ColorType

newtype BitDepth = BitDepth Word8 deriving Show
bitDepth 1 = BitDepth 1; bitDepth  2 = BitDepth  2; bitDepth 4 = BitDepth 4; 
bitDepth 8 = BitDepth 8; bitDepth 16 = BitDepth 16;
bitDepthVal (BitDepth n) = fromIntegral n
 
instance Encode16 ColorRGBA  where encode16 (ColorRGBA  (a,b,c,d)) = map double2Word16 [a,b,c,d]
instance Encode16 ColorRGB   where encode16 (ColorRGB   (a,b,c)  ) = map double2Word16 [a,b,c]
instance Encode16 ColorGreyA where encode16 (ColorGreyA (a,b)    ) = map double2Word16 [a,b]
instance Encode16 ColorGrey  where encode16 (ColorGrey  a        ) = [double2Word16 a]
instance Encode16 ColorIndex where encode16 (ColorIndex a        ) = [fromIntegral a]
--instance Encode8  ColorRGBA  where encode8  (a,b,c,d) = map double2Word8  [a,b,c,d]
--instance Encode8  ColorRGB   where encode8  (a,b,c)   = map double2Word8  [a,b,c]
--instance Encode8  ColorGreyA where encode8  (a,b)     = map double2Word8  [a,b]
--instance Encode8  ColorGrey  where encode8  a         = [double2Word8 a]
--instance Encode8  ColorIndex where encode8  a         = [a]
instance CType ColorRGBA  where cType a = RGBA
instance CType ColorRGB   where cType a = RGB
instance CType ColorGreyA where cType a = GreyA
instance CType ColorGrey  where cType a = Grey
instance CType ColorIndex where cType a = Indexed

encode8 :: (Encode16 e) => e -> [Word8]
encode8 c = map (fromIntegral . (`shiftR` 8)) $ encode16 c

newImage :: PNGImage
newImage = PNGImage {
   imageHeader = Header {
      hdrWidth = 1
     ,hdrHeight = 1
     ,hdrBitDepth = BitDepth 8
     ,hdrColorType = RGBA
     ,hdrInterlaceMethod = 0
     }
  ,imageBackground = Nothing
  ,imagePalette = Nothing
  ,imageAlpha = Nothing
  ,imageData = [0,0,0,0] -- 1x1 transparent
  ,imageTime = Nothing
  ,imageTexts = []
  ,imageZTexts = []
  ,imageITexts = []
}

getCType img = hdrColorType $ imageHeader img
getBitDepth img = bitDepthVal $ hdrBitDepth $ imageHeader img

-- Ideally there would be multiple interfaces for a variety of types
-- of image data. Should Pixel be a concrete type or a type class?
--setImageList :: [Pixel] -> Img -> Img
--setImageRaw :: ByteString -> Img -> Img
--setImageArray :: (Ix i, IArray a) => a i Pixel -> Img -> Img
--setImageMArray :: (Ix i, MArray a) => a i Pixel -> Img -> Img

setImageList idat img = img { imageData = idat }
--setImage8  idat img = setBitDepth 8  $ img { imageData = Left  idat }
setCType ct img = img { imageHeader = (imageHeader img) { hdrColorType = ct } }
setSize (w,h) img = img { imageHeader = (imageHeader img) {
  hdrWidth = fromIntegral w, hdrHeight = fromIntegral h } }
setInterlaced adam7 img = img { imageHeader = (imageHeader img) {
  hdrInterlaceMethod = (if adam7 then 1 else 0) } }
setBitDepth bd img = img { imageHeader = (imageHeader img) { hdrBitDepth = BitDepth bd } }
setTime time img = img { imageTime = Just time }
setBG bg img = img { imageBackground = Just bg }
setTimeToNow img = do t <- getCurrentTime; return img { imageTime = Just t }

setImageArray array img =
  let ct = cType (array!(0,0))
      b = bounds array
      width  = (fst.snd) b - (fst.fst) b + 1
      height = (snd.snd) b - (snd.fst) b + 1
    in img {
       imageHeader = (imageHeader img) {
         hdrWidth     = fromIntegral width
        ,hdrHeight    = fromIntegral height
        ,hdrColorType = ct
        }
      ,imageData = concatMap encode16 $ elems $ transpose2DA array
      }

-- This function is super smart in that it will intelligently handle
-- any (Encode8 e, CType e) => [e] by adding an RGB Palette chunk to
-- the image, and in the case of GreyA and RGBA an Alpha chunk too. It
-- even sets the bit depth based on number of palette entries (not
-- implemented)
setPalette :: (Encode16 p, CType p) => [p] -> PNGImage -> PNGImage
setPalette palette img
  | getCType img /= Indexed = error "Palettes only belong on indexed color images"
  | length palette == 0 = error "Must have at least one color in palette"
  | otherwise = case cType (pal!!0) of
        Grey    -> setPalRGB (\[g] -> (g,g,g))
        RGB     -> setPalRGB (\[r,g,b] -> (r,g,b))
        GreyA   -> setPalRGBA (\[g,a] -> ((g,g,g),a))
        RGBA    -> setPalRGBA (\[r,g,b,a] -> ((r,g,b),a))
        Indexed -> error "Can't have a palette of indexed colors!"
      where pal = take 256 palette 
            --bd = length pal
            setPalRGB  f = setPaletteDumb (map (f . encode8) pal) img
            setPalRGBA f = let (rgb,alph) = unzip (map (f . encode8) pal)
                             in setPaletteDumb rgb $ setAlpha (AlphaIndexed alph) img
setPaletteDumb pal img = img { imagePalette = Just $ Palette pal }
setAlpha alph img = img { imageAlpha = Just alph }

class PNGChunk a where chunkName :: a -> String -- chunk type (IHDR, zTXt, IDAT, etc)

putChunk :: (Binary c, PNGChunk c) => c -> Put
putChunk a = putLazyByteString $ encodeChunkBS (chunkName a) (runPut $ put a)
putMChunk (Just a) = putChunk a
putMChunk Nothing = put ()
  
-- Puts together chunk type, length, chunk data, and CRC code
encodeChunkBS :: String -> B.ByteString -> B.ByteString
encodeChunkBS chunkName chunkBS = runPut $ do
  putWord32be $ fromIntegral $ B.length chunkBS
  putLazyByteString $ BC.pack chunkName
  putLazyByteString chunkBS
  putWord32be $ crc32 (B.append (BC.pack chunkName) chunkBS)

type CParts = (String, B.ByteString, Bool)
getChunkParts :: Get CParts
getChunkParts = do
  length <- getWord32be
  name <- getLazyByteString 4
  cData <- getLazyByteString (fromIntegral length)
  crc <- getWord32be
  return (BC.unpack name, cData, crc32 (name `BC.append` cData) == crc)
  
data PNGImage = PNGImage {
   imageHeader     :: Header
  ,imageTime       :: Maybe UTCTime
  ,imageBackground :: Maybe Background
  ,imagePalette    :: Maybe Palette -- palette for indexed color images
  ,imageAlpha      :: Maybe Alpha -- alpha of palette or a special transparent color
  --,imageSPalette   :: Maybe SPalette -- suggested palette
  ,imageData       :: [Word16]
  ,imageTexts      :: [Text] -- ASCII key -> value pairs
  ,imageZTexts     :: [ZText] -- compressed texts
  ,imageITexts     :: [IText] -- compressed/uncompressed UTF-8 texts with language string
  } deriving Show

pngSignature = [137,80,78,71,13,10,26,10] :: [Word8]

encodeImage :: PNGImage -> B.ByteString
encodeImage i = runPut $ putImage i
putImage i = do
  let hdr = (imageHeader i)
      ctype = hdrColorType hdr
      bg = imageBackground i

  mapM_ put pngSignature
  putChunk  (imageHeader i)

  putMChunk (imageTime i)

  -- If there's a background specified, verify it matches with the ColorType
  -- put background color
  if False == case bg of
      Just a -> case a of
        BGRGB   b -> ctype == RGB  || ctype == RGBA
        BGGrey  b -> ctype == Grey || ctype == GreyA
        BGIndex b -> ctype == Indexed
      Nothing -> True
    then error $ "Background \"" ++ show (fromJust bg) ++ "\" does not match image's color type " ++ show ctype
    else putMChunk bg

  -- If this is an indexed color image, verify it has a palette
  -- put palette
  if ctype == Indexed && isNothing (imagePalette i)
    then error "Indexed color images must have a palette"
    else putMChunk $ imagePalette i

  case imageAlpha i of
    Just a -> putLazyByteString $ encodeChunkBS (chunkName a) (runPut $ putAlpha a)
    Nothing -> put ()

  -- Verify bit depth is allowed for this image type
  -- put image data
  let b = getBitDepth i in if False == (elem b $ case ctype of
      Grey    -> [1, 2, 4, 8, 16]
      RGB     -> [8, 16]
      Indexed -> [1, 2, 4, 8]
      GreyA   -> [8, 16]
      RGBA    -> [8, 16])
    then error $ "Bit depth " ++ (show b) ++ " is not allowed for color type " ++ (show ctype) ++ "."
    else putLazyByteString $ encodeChunkBS "IDAT" $ compressWith BestCompression $
      encodeImageData (imageData i) (eWidth ctype) (hdrWidth hdr)
        (hdrHeight hdr) (hdrBitDepth hdr) (hdrInterlaceMethod hdr == 1)

  putChunk End

decodeImage = do
  pngSignature <- replicateM (length pngSignature) getWord8
  --hdr <- get
  --img <- imageGet (hdrBitDepth hdr)
  --pngEnd <- replicateM (length pngEnd) getWord8
  return newImage

data ColorType = Grey | Unused1 | RGB | Indexed | GreyA | Unused2 | RGBA
  deriving (Enum, Show, Eq)
instance Binary ColorType where
  put c = putWord8 $ (fromIntegral . fromEnum) c
  get = do t <- getWord8; return $ (toEnum . fromIntegral) t
eWidth Grey = 1; eWidth Indexed = 1; eWidth GreyA = 2; eWidth RGB = 3; eWidth RGBA = 4

data Header = Header {
   hdrWidth :: Word32
  ,hdrHeight :: Word32
  ,hdrBitDepth :: BitDepth
  ,hdrColorType :: ColorType
  ,hdrInterlaceMethod :: Word8
  } deriving Show
instance PNGChunk Header where chunkName a = "IHDR"
instance Binary Header where
  put h = do
    put (hdrWidth           h)
    put (hdrHeight          h)
    putWord8 (bitDepthVal $ hdrBitDepth h)
    put (hdrColorType       h)
    put (0::Word8) -- compression method always 0
    put (0::Word8) -- filter method always 0
    put (hdrInterlaceMethod h)
  get = do
    w <- get
    h <- get
    b <- get
    c <- get
    0 <- getWord8 -- compression method
    0 <- getWord8 -- filter method
    i <- get
    return Header { hdrWidth = w, hdrHeight = h, hdrBitDepth = BitDepth b,
      hdrColorType = c, hdrInterlaceMethod = i }

-- TODO: make this more sophisticated by adaptively choosing which
-- filter to use, and applying it, rather than using no filters at all
addFilters :: [[Word8]] -> [Word8]
addFilters = concatMap (0:)

-- TODO: make this work
--removeFilters :: Int -> [Word8] -> [Word8]
--removeFilters byteWidth = concatMap (0:) . chunk byteWidth

packWords :: Word8 -> [Word16] -> [Word8]
packWords 16 xs = concatMap encodeWord16be xs
packWords d xs = packWord8s d $ map fromIntegral xs
packWord8s :: Word8 -> [Word8] -> [Word8]
packWord8s 8 x = x
packWord8s d xs = map (foldl ((+) . (2 ^ d *)) 0) $ chunkUniform (div 8 d) 0 xs

-- TODO: make this work too
unpackWords :: Word8 -> [Word8] -> [Word16]
unpackWords d xs = map fromIntegral xs

--  [1,6,4,6,2,6,4,6
--   7,7,7,7,7,7,7,7
--   5,6,5,6,5,6,5,6
--   7,7,7,7,7,7,7,7
--   3,6,4,6,3,6,4,6
--   7,7,7,7,7,7,7,7
--   5,6,5,6,5,6,5,6
--   7,7,7,7,7,7,7,7]

-- Adam7 defines seven passes over the image. Each pass contains the
-- following pixels from each 8x8 chunk:
--   1 6 4 6 2 6 4 6
--   7 7 7 7 7 7 7 7
--   5 6 5 6 5 6 5 6
--   7 7 7 7 7 7 7 7
--   3 6 4 6 3 6 4 6
--   7 7 7 7 7 7 7 7
--   5 6 5 6 5 6 5 6
--   7 7 7 7 7 7 7 7
interlaceAdam7 :: [[a]] -> [[a]]
interlaceAdam7 a = let
    nth n = map head . takeWhile (not . null) . iterate (drop n)
    select fx fy ox oy l = map (nth fx . drop ox) $ nth fy (drop oy l)
  in (select 8 8 0 0 a) ++ -- pass 1
     (select 8 8 4 0 a) ++ -- pass 2
     (select 4 8 0 4 a) ++ -- pass 3
     (select 4 4 2 0 a) ++ -- pass 4
     (select 2 4 0 2 a) ++ -- pass 5
     (select 2 2 1 0 a) ++ -- pass 6
     (select 1 2 0 1 a)    -- pass 7

--deinterlaceAdam7 :: Word32 -> [a] -> [[a]]
--deinterlaceAdam7 width 

encodeImageData :: [Word16] -> Word8 -> Word32 -> Word32 -> BitDepth -> Bool -> B.ByteString
encodeImageData idat pWidth w h depth adam7 = B.pack $ addFilters
  $ map (packWords (bitDepthVal depth))
  $ (if adam7 then map concat . interlaceAdam7 . map (chunk pWidth) else id)
  $ chunk (w * fromIntegral pWidth) idat

data Palette = Palette [(Word8,Word8,Word8)] deriving Show
instance PNGChunk Palette where chunkName a = "PLTE"
instance Binary Palette where
  put (Palette p) = mapM_ put p
  get = do
    l <- remaining
    p <- replicateM (div (fromIntegral l) 3) (get :: Get (Word8,Word8,Word8))
    return $ Palette p

data Alpha = AlphaGrey     Word16
           | AlphaRGB     (Word16,Word16,Word16)
           | AlphaIndexed [Word8] deriving Show
instance PNGChunk Alpha where chunkName a = "tRNS"
putAlpha (AlphaGrey    a) = putWord16be a
putAlpha (AlphaRGB     a) = put a
putAlpha (AlphaIndexed a) = mapM_ put a
getAlpha :: ColorType -> Get Alpha
getAlpha ctype = case ctype of
  Grey    -> liftM AlphaGrey get
  RGB     -> liftM AlphaRGB get
  Indexed -> do
    p <- getRemainingLazyByteString
    return $ AlphaIndexed (B.unpack p)

data Background = BGRGB (Word16,Word16,Word16)
                | BGGrey Word16
                | BGIndex Word8 deriving Show
instance PNGChunk Background where chunkName a = "bKGD"
instance Binary Background where
  put (BGRGB (r,g,b)) = mapM_ putWord16be [r,g,b]
  put (BGGrey g) = putWord16be g
  put (BGIndex i) = putWord8 i
  get = do
    l <- remaining
    case l of
      1 -> liftM BGIndex getWord8
      2 -> liftM BGGrey getWord16be
      6 -> liftM (\[r, g, b] -> BGRGB (r, g, b)) (replicateM 3 getWord16be)

color2BG :: (Encode16 p) => p -> Background
color2BG p = case encode16 p of r:g:b:l -> BGRGB (r,g,b); g:l -> BGGrey g

repeatUntil p m = m >>= \x -> if p x then return [] else liftM (x:) (repeatUntil p m)
getString = liftM (map (chr.fromIntegral)) (repeatUntil (==0) getWord8)
sanitizeKeyword = (join (.) $ reverse . dropWhile isSpace) . take 79 . filter (/='\NUL')

data Text = Text { textKeyword :: String, textContents :: String } deriving Show
instance PNGChunk Text where chunkName a = "tEXt"
instance Binary Text where
  put t = do
    putLazyByteString $ BC.pack (sanitizeKeyword $ textKeyword t)
    putWord8 0
    putLazyByteString $ BC.pack (textContents t)
  get = do
    label <- getString
    return Text { textKeyword = "foo", textContents = "bar" }

newtype ZText = ZText Text deriving Show
instance PNGChunk ZText where chunkName a = "zTXt"
instance Binary ZText where
  put (ZText t) = do
    putLazyByteString $ BC.pack (sanitizeKeyword $ textKeyword t)
    putWord8 0
    putWord8 0
    putLazyByteString $ compressWith BestCompression $ BC.pack (textContents t)
  get = do
    label <- getString
    return $ ZText $ Text { textKeyword = label, textContents = "bar" }

data IText = IText {
   iTextKeyword     :: String
  ,iTextCompressed  :: Bool
  ,iTextLanguage    :: String
  ,iTextIKeyword    :: String
  ,iTextContents    :: String
  } deriving Show
newITextEn = IText "Comment" False "en" "" ""
instance PNGChunk IText where chunkName a = "iTXt"
instance Binary IText where
  put t = put ()
  get = return newITextEn

--encodeText :: String -> String -> Bool -> 
--encodeText 
--    let key  = take 79 $ fst t
--        key' = if key == "" then "Comment" else key

instance PNGChunk UTCTime where chunkName a = "tIME"
instance Binary UTCTime where
  put t = do
    let (year, month, day) = toGregorian (utctDay t)
        time = timeToTimeOfDay (utctDayTime t)
    putWord16be $ fromIntegral year
    mapM (putWord8 . fromIntegral) [month, day, todHour time, todMin time]
    putWord8 $ fromIntegral $ round $ todSec time
  get = do
    year <- getWord16be
    [month, day, hour, min] <- liftM (map fromIntegral) $ replicateM 4 getWord8
    sec <- getWord8
    return UTCTime {
       utctDay = fromGregorian (fromIntegral year) month day
      ,utctDayTime = timeOfDayToTime $ TimeOfDay hour min (fromIntegral sec)
      }

data End = End
instance PNGChunk End where chunkName a = "IEND"
instance Binary End where put t = put (); get = get :: (Get End)

-- CRC (Cyclic Redundancy Check) defined in Annex D of the PNG spec second edition
crc32 :: B.ByteString -> Word32
crc32 = xor (2^32-1) . B.foldl
  (\crc i -> xor (crc32_table ! (xor crc (fromIntegral i) .&. 0xFF)) (shiftR crc 8))
  (2^32-1)

crc32_table :: UA.Array Word32 Word32
crc32_table = listArray (0,255) $ map
  ((!!8) . iterate (\b -> (if odd b then xor 0xEDB88320 else id) (shiftR b 1)))
  ([0..255] :: [Word32])

-- invert indices of 2D array
transpose2DA a = ixmap ((\(z,(i,j)) -> (z,(j,i))) $ bounds a) (\(x,y) -> (y,x)) a
frac2Integral s v = fromIntegral $ round $ v * s

chunk n = map (genericTake n) . takeWhile (not.null) . iterate (genericDrop n)
--chunk n l = let (x,y) = splitAt n l in x : if not $ null y then chunk n y else []
fill n d l = (++) l $ replicate (fromIntegral n - length l) d
chunkUniform n d l = map (fill n d) $ chunk n l
chunkAnal n l = let l' = chunk n l in if length (last l') < fromIntegral n
  then Nothing else Just l'
ifNothing :: String -> Maybe a -> a
ifNothing y x = case x of Nothing -> error y; (Just x) -> x

double2Word8 :: Double -> Word8
double2Word8 d = frac2Integral 255 d
double2Word16 :: Double -> Word16
double2Word16 d = frac2Integral 65535 d
encodeWord16be :: Word16 -> [Word8]
encodeWord16be v = map fromIntegral [shiftR v 8, v .&. 255]
encodeDouble16be = encodeWord16be . double2Word16
chain = foldl (.) id
