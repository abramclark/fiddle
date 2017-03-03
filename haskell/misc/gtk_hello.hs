import Graphics.UI.Gtk

main :: IO ()
main = do
  initGUI
  window <- windowNew
  button <- buttonNew
  set window [ containerChild := button ]
  set button [ buttonLabel := "Hello World" ]
  onClicked button (putStrLn "Hello World")
  onDestroy window mainQuit
  widgetShowAll window
  mainGUI
