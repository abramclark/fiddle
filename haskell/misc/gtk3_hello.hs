import Graphics.UI.Gtk
import Control.Monad.IO.Class

main :: IO ()
main = do
  initGUI
  window <- windowNew
  button <- buttonNew
  set window [ containerChild := button ]
  set button [ buttonLabel := "Hello World" ]
  button `on` buttonPressEvent $ liftIO mainQuit >> return False -- putStrLn "Hello World"
  window `on` deleteEvent $ liftIO mainQuit >> return False
  widgetShowAll window
  mainGUI
