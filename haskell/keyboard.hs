import Sound.SC3
import qualified Sound.ALSA.Sequencer as Am -- Alsa MIDI control
import qualified Sound.MIDI.Message.Channel as Mcm -- MIDI channel message
import qualified Sound.MIDI.Message.Channel.Voice as Mvm -- MIDI voice messae

import Foolery

import Control.Monad
import Data.Maybe
import Data.List
import System.Random
import Control.Concurrent

-- convenience shit
rs = withSC3 reset
mono u = mrg2 (out 0 u) (out 1 u)
audm u = audition $ mono u
so f = sinOsc AR f 0
s2sc f = withSC3 $ \t -> send t f
sa2sc f = withSC3 $ \t -> async t f
ctrl name defaultValue = Control KR name defaultValue
d_recv' name synth = sa2sc $ d_recv $ synthdef name synth
n_impulse nodeId name = do
    s2sc $ n_set1 nodeId name 0
    threadDelay 50000
    s2sc $ n_set1 nodeId name 1

-- control names: "freq", "harshness" (100 to 10000), "amp", "onoff", "bend"
noisyString :: IO UGen
noisyString = do
    n <- whiteNoise AR
    let nf harshness = ((iterate (flip lpf (harshness * 10000 + 100)) n) !! 3) * penv
        freq = ctrl "freq" 440 * ctrl "bend" 1
        strike = Control AR "strike" 1
        keyDown = ctrl "down" 1
        h = ctrl "harshness" 0.2
        penv = envGen AR strike 1 0 1 DoNothing (envPerc 0.01 0.2)
        senv = linen keyDown 0 1 0.1 RemoveSynth
        noisyStr = combL (nf h) (1 / freq) (1 / freq) 10 + (nf h)
    return $ noisyStr * senv * ctrl "amp" 0.2 * 0.5

-- control names: "freq", "harshness" (100 to 10000), "amp", "onoff", "bend"
simpleNoise :: IO UGen
simpleNoise = do
    n <- whiteNoise AR
    let freq = ctrl "freq" 440 * ctrl "bend" 1
        onoff = ctrl "onoff" 0
        h = ctrl "harshness" 0.1
        penv = envGen KR onoff 1 0 1 DoNothing (envPerc 0.01 2)
        senv = linen onoff 0 1 0.1 DoNothing
        nf = iterate (\i -> bpf i freq (h / 2 + 0.01)) (n) !! 5
    return $ (nf * senv * ctrl "amp" 0.2 * 100)

chordNoise n f h keyDown =
    let penv = envGen KR keyDown 1 0 1 DoNothing (envPerc 0.02 0.5)
        senv = linen keyDown 0 1 0.1 DoNothing
        resFilter f = combL ((n * (penv + 0.5))  * 0.02) (1/f) (1/f) 10
        tone f = clip (resFilter f) (-0.8) (0.8) * 10
        genChord f = tail $ map (*f) $ concatMap (\f -> [f, recip f]) [1, 3/2, 2/3, 4/5, 5/4, 2, 3, 4, 5]
        snd = lpf (chordify tone $ genChord f) (h * 5000 + 100)
    in snd * senv

chordNoiseCtrl :: IO UGen
chordNoiseCtrl = do
    n <- brownNoise AR
    let freq = ctrl "freq" 440 * ctrl "bend" 1
        keyDown = ctrl "down" 1
        h = ctrl "harshness" 0.1
        penv = envGen KR keyDown 1 0 1 DoNothing (envPerc 0.02 0.5)
        senv = linen keyDown 0 1 0.1 RemoveSynth
        resFilter f = combL ((n * (penv + 0.5))  * 0.02) (1/f) (1/f) 10
        tone f = clip (resFilter f) (-0.8) (0.8) * 10
        genChord f = tail $ map (*f) $ concatMap (\f -> [f, recip f]) [1, 3/2, 2/3, 4/5, 5/4, 2, 3, 4, 5]
        snd = lpf (chordify tone $ genChord (freq)) (h * 5000 + 100)
    return $ snd * senv * ctrl "amp" 0.2

-- western scale
scale2 :: Int -> Double
scale2 n = 440 * 2 ** ((fromIntegral n - 69) / 12)

scale3 n = 50 + (fromIntegral n) * 20

scale4 n = 440 * 2 ** ((fromIntegral n - 69) / 11)

scale5 n = 440 * 3 ** ((fromIntegral n - 69) / 12)

scale6 n = min 20000 $ max 20 $ 440 * (3/2) ** (fromIntegral n - 69)

-- take MIDI voice message and do shit
processMvm v = case v of
    Mvm.NoteOn p v -> do
        let n = Mvm.fromPitch p
        startSynth n (fromIntegral (Mvm.fromVelocity v) / 127)
        putStrLn $ "!:" ++ (show n)
        --s2sc $ n_set (100 + Mvm.fromPitch p)
        --    [("onoff", 1), ("amp", fromIntegral (Mvm.fromVelocity v) / 127)]
    Mvm.NoteOff p v -> do
        stopSynth $ Mvm.fromPitch p
        putStrLn $ "^:" ++ (show $ Mvm.fromPitch p)
    Mvm.PitchBend b ->
        s2sc $ n_set 0 [("bend", (fromIntegral b + 8192) * 1.413350e-5 + 0.8909)]
    Mvm.Control controller val ->
        s2sc $ n_set 0 [("harshness", fromIntegral val / 127)]
    _ -> return ()

-- init a "key" synth given a midi note
startSynth note amp = do
    s2sc $ n_free [100 + note]
    s2sc $ s_new "key" (100 + note) AddToTail 0 [("freq", scale2 note), ("amp", amp)]
stopSynth note = s2sc $ n_set (100 + note) [("down", 0)]
startSynths = mapM_ (flip startSynth 0.2) [0 .. 127]

reloadSynth = do
    synth <- chordNoiseCtrl
    s2sc $ d_free ["key"] -- in case old version is still around
    d_recv' "key" $ mono $ synth

startKeyboard = do
    reloadSynth
    rs
    startMidiClient processMvm


------------------
-- MIDI handler --
------------------

-- data MidiClientHandle = MidiClientHandle Am.Client ThreadId

-- -- fork a process that listens for midi events and calls given handler
-- startMidiClient :: (Mvm.T -> IO ()) -> IO MidiClientHandle
-- startMidiClient processMidi = do
--     mymidi <- Am.createClient Amf.openDuplex "foo"
--     Am.createOutputPort mymidi "foo-listen"
--     thread <- forkIO $ forever $ do
--         e <- Am.receiveEvent mymidi
--         case e >>= Am.eventToChannelMsg of
--             Just (Mcm.Cons _ (Mcm.Voice t)) -> processMidi t
--             _ -> return ()
--     return $ MidiClientHandle mymidi thread

-- stopMidiClient :: MidiClientHandle -> IO ()
-- stopMidiClient (MidiClientHandle mclient threadid) = do
--     killThread threadid
--     Am.deleteClient mclient


--------------
-- Not used --
--------------
--
--midiListen = Am.withEvents "foo" "foo-listen" $ \l -> mapM_
--        (\l -> case l of
--            Mcm.Cons c (Mcm.Voice (Mvm.NoteOn p v)) -> do
--                s2sc $ n_set (100 + Mvm.fromPitch p)
--                    [("onoff", 1), ("amp", fromIntegral (Mvm.fromVelocity v) / 1024)]
--            Mcm.Cons c (Mcm.Voice (Mvm.NoteOff p v)) ->
--                s2sc $ n_set (100 + Mvm.fromPitch p) [("onoff", 0)]
--            Mcm.Cons c (Mcm.Voice (Mvm.PitchBend b)) ->
--                s2sc $ n_set 0 [("bend", (fromIntegral b + 8192) * 1.413350e-5 + 0.8909)]
--            Mcm.Cons c (Mcm.Voice (Mvm.Control controller val)) ->
--                s2sc $ n_set 0 [("harshness", fromIntegral val * 78.74 + 100)]
--            _ -> return ())
--        (mapMaybe Am.eventToChannelMsg l)
--
--noisyString :: IO (UGen -> UGen -> UGen)
--noisyString = do
--    n <- whiteNoise AR
--    let nf harshness = (iterate (flip lpf harshness) n) !! 3
--    return $ \f h -> combL (nf h) (1 / f) (1 / f) 10 + (nf h)
--
---- control names: "freq", "harshness" (100 to 10000), "amp", "onoff", "bend"
--noisyStringCtrl :: IO UGen
--noisyStringCtrl = do
--    nsr <- noisyString
--    let freq = ctrl "freq" 440 * ctrl "bend" 1
--        onoff = ctrl "onoff" 0
--        env = envGen KR onoff 1 0 1 DoNothing (envPerc 0.01 5) *
--                  linen onoff 0 1 0.1 DoNothing
--    return $ nsr freq (ctrl "harshness" 1000) * env * ctrl "amp" 0.2
