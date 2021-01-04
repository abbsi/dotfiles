-- Originally from: https://gitlab.com/dwt1/dotfiles

-- TODO
  -- Fix xmboar not clickable?
  -- Check all layout and disable ones not needed
  -- Move DWM autostart script
  -- Fix Trayer alignment and position
  -- Icon Root relative instead of absolute
  -- See why sometimes a workspace stays highlighted as if visible
  -- Explore implementing this https://hackage.haskell.org/package/xmonad-contrib-0.16/docs/XMonad-Layout-IndependentScreens.html
  -- Should label 'NSP' disappear after closing the scratch pad
  
-- Base
import XMonad
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

-- Actions
import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies)
import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)

    -- Data
import Data.Char (isSpace, toUpper)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory

    -- Layouts
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

    -- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

    -- Prompt
import XMonad.Prompt
import XMonad.Prompt.Input
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Man
import XMonad.Prompt.Pass
import XMonad.Prompt.Shell
import XMonad.Prompt.Ssh
import XMonad.Prompt.XMonad
import Control.Arrow (first)

   -- Utilities
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

myFont :: String
myFont = "xft:SauceCodePro Nerd Font:bold:size=12:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod4Mask -- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "kitty " -- Sets default terminal

myScratchTerminal :: String
myScratchTerminal = "kitty --name scratchpad -o initial_window_width=2300 -o initial_window_height=1100 -o background=#2b2e3b -o background_opacity=0.5 "

myBrowser :: String
myBrowser = "firefox " -- Sets qutebrowser as browser for tree select

myEditor :: String
myEditor = "code "  -- Sets emacs as editor for tree select

myBorderWidth :: Dimension
myBorderWidth = 2 -- Sets border width for windows

myNormColor :: String
myNormColor   = "#222222" -- Border color of normal windows

myFocusColor :: String
myFocusColor  = "#FFFFFF" -- Border color of focused windows

altMask :: KeyMask
altMask = mod1Mask  -- Setting this for use in xprompts

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
          spawnOnce "$HOME/.dwm/autostart.sh" -- Reusing DWM's autostart script
          spawnOnce "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 --tint 0x282c34 --height 30 &"
          setWMName "LG3D"

myColorizer :: Window -> Bool -> X (String, String)
myColorizer = colorRangeFromClassName
                  (0x28,0x2c,0x34) -- lowest inactive bg
                  (0x28,0x2c,0x34) -- highest inactive bg
                  (0xc7,0x92,0xea) -- active bg
                  (0xc0,0xa7,0x9a) -- inactive fg
                  (0x28,0x2c,0x34) -- active fg

-- gridSelect menu layout
mygridConfig :: p -> GSConfig Window
mygridConfig colorizer = (buildDefaultGSConfig myColorizer)
    { gs_cellheight   = 80
    , gs_cellwidth    = 400
    , gs_cellpadding  = 6
    , gs_originFractX = 0.5
    , gs_originFractY = 0.5
    , gs_font         = myFont
    }

myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm ]
  where
    spawnTerm  = myScratchTerminal
    findTerm   = resource =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
tall     = renamed [Replace "tall"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 15
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 Full
threeCol = renamed [Replace "threeCol"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           $ mySpacing' 15
           $ ThreeCol 1 (3/100) (1/2)
tabs     = renamed [Replace "tabs"]
           $ tabbed shrinkText myTabTheme
floats   = renamed [Replace "floats"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 simplestFloat
-- magnify  = renamed [Replace "magnify"]
--           $ windowNavigation
--           $ addTabs shrinkText myTabTheme
--           $ subLayout [] (smartBorders Simplest)
--           $ magnifier
--           $ limitWindows 12
--           $ mySpacing 8
--           $ ResizableTall 1 (3/100) (1/2) []
-- grid     = renamed [Replace "grid"]
--            $ windowNavigation
--            $ addTabs shrinkText myTabTheme
--            $ subLayout [] (smartBorders Simplest)
--            $ limitWindows 12
--            $ mySpacing 8
--            $ mkToggle (single MIRROR)
--            $ Grid (16/10)
-- spirals  = renamed [Replace "spirals"]
--            $ windowNavigation
--            $ addTabs shrinkText myTabTheme
--            $ subLayout [] (smartBorders Simplest)
--            $ mySpacing' 8
--            $ spiral (6/7)
-- threeRow = renamed [Replace "threeRow"]
--            $ windowNavigation
--            $ addTabs shrinkText myTabTheme
--            $ subLayout [] (smartBorders Simplest)
--            $ limitWindows 7
--            $ mySpacing' 4
--            $ Mirror
--            $ ThreeCol 1 (3/100) (1/2)

myTabTheme = def { fontName            = myFont
                 , activeColor         = "#46d9ff"
                 , inactiveColor       = "#313846"
                 , activeBorderColor   = "#46d9ff"
                 , inactiveBorderColor = "#282c34"
                 , activeTextColor     = "#282c34"
                 , inactiveTextColor   = "#d0d0d0"
                 }

-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font              = "xft:Ubuntu:bold:size=60"
    , swn_fade              = 1.0
    , swn_bgcolor           = "#1c1f24"
    , swn_color             = "#ffffff"
    }

-- The layout hook
myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               myDefaultLayout =     tall
                                 ||| monocle
                                 ||| threeCol
                                 ||| tabs
                                 ||| floats
                                 --- ||| magnify
                                 --- ||| grid
                                 --- ||| spirals
                                 --- ||| threeRow

myWorkspaces = [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]
-- myWorkspaces = [" dev ", " www ", " sys ", " doc ", " vbox ", " chat ", " mus ", " vid ", " gfx "]

xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

myClickableWorkspaces :: [String]
myClickableWorkspaces = clickable . (map xmobarEscape)
               $ [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]
               -- $ [" dev ", " www ", " sys ", " doc ", " vbox ", " chat ", " mus ", " vid ", " gfx "]
  where
        clickable l = [ "<action=xdotool key super+" ++ show (n) ++ ">" ++ ws ++ "</action>" |
                      (i,ws) <- zip [1..9] l,
                      let n = i ]

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
     -- I'm doing it this way because otherwise I would have to write out the full
     -- name of my workspaces, and the names would very long if using clickable workspaces.
     [ className =? "Code"                                --> doShift ( myWorkspaces !! 0 )
     , title =? "Mozilla Firefox"                         --> doShift ( myWorkspaces !! 2 )
     , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  
     , className =? "realvnc-vncviewer"                   --> doFloat
     , className =? "Sxiv"                                --> doFloat
     , className =? "Galculator"                          --> doFloat
     , className =? "Pcmanfm"                             --> doFloat
     , className =? "Slack"                               --> doShift ( myWorkspaces !! 4 )
     , className =? "whatsapp-nativefier-930aa1"          --> doShift ( myWorkspaces !! 4 )
     , className =? "Discord"                             --> doShift ( myWorkspaces !! 4 )
     , className =? "Zoom"                                --> doShift ( myWorkspaces !! 5 )
     , className =? "Thunderbird"                         --> doShift ( myWorkspaces !! 8 )
     , className =? "mpv"                                 --> doShift ( myWorkspaces !! 7 )
     , resource  =? "Dialog"                              --> doFloat  
     , className =? "Xmessage"  --> doFloat
     ] <+> namedScratchpadManageHook myScratchPads

myLogHook :: X ()
myLogHook = fadeInactiveLogHook fadeAmount
    where fadeAmount = 1.0

myKeys :: [(String, X ())]
myKeys =
    --Xmonad
        [ ("M-C-r",            spawn ("xmonad --recompile")) -- Recompiles xmonad
        , ("M-C-S-q",          spawn ("xmonad --restart")) -- Restarts xmonad
        , ("M-S-q",            io exitSuccess) -- Quits xmonad

    --Kill windows
        , ("M-q",               kill1) -- Kill the currently focused client
        , ("M-S-w",             killAll) -- Kill all windows on current workspace

    --Launchers
        , ("M-S-<Return>",      spawn (myTerminal)) -- Spawn Terminal
        , ("M-<Space>",         spawn ("rofi-app")) -- Opens Rofi App Launcher
        , ("M-x",               spawn ("rofi-run")) -- Opens Rofi Combi Modi Launcher
        , ("M-w",               spawn ("rofi-win")) -- Opens Window Selector
        , ("M-e",               spawn ("rofi-fm")) -- Opens Fullscreen Rofi File Browser
        , ("M-p",               spawn ("dmenu_run -g 3 -l 20 -fn 'Source Code Pro:pixelsize=20' -p 'Run:'")) -- Shell Prompt

    -- Other
        , ("M-l",               spawn ("slock"))
        , ("M-c t",             spawn ("m-todo"))
        , ("M-c s",             spawn ("m-todo2"))
        , ("M-c n",             spawn ("m-notifications"))
        , ("M-c m",             spawn ("m-sysmon"))
        , ("M-c e",             spawn ("m-edit-configs"))
        
    --OK Workspaces
        , ("M-]",               nextScreen) -- Switch focus to next monitor
        , ("M-[",               prevScreen) -- Switch focus to prev monitor
        , ("M-S-]",             shiftTo Next nonNSP >> moveTo Next nonNSP) -- Shifts focused window to next ws
        , ("M-S-[",             shiftTo Prev nonNSP >> moveTo Prev nonNSP) -- Shifts focused window to prev ws

    -- Floating windows
        , ("M-S-<Space>",       sendMessage (T.Toggle "floats")) -- Toggles my 'floats' layout
        , ("M-t",               withFocused $ windows . W.sink) -- Push floating window back to tile
        , ("M-S-t",             sinkAll) -- Push ALL floating windows to tile

    -- Increase/decrease spacing (gaps)
        , ("M-d",               decWindowSpacing 4) -- Decrease window spacing
        , ("M-i",               incWindowSpacing 4) -- Increase window spacing
        , ("M-S-d",             decScreenSpacing 4) -- Decrease screen spacing
        , ("M-S-i",             incScreenSpacing 4) -- Increase screen spacing

    -- Grid Select (CTR-g followed by a key)
        , ("M-g t",             goToSelected $ mygridConfig myColorizer) -- goto selected window
        , ("M-g b",             bringSelected $ mygridConfig myColorizer) -- bring selected window

    -- Windows navigation
        , ("M-<Home>",          windows W.focusMaster)  -- Move focus to the master window
        , ("M-S-<Home>",        windows W.swapMaster) -- Swap the focused window and the master window
        , ("M-<Down>",          windows W.focusDown) -- Move focus to the next window
        , ("M-<Up>",            windows W.focusUp) -- Move focus to the prev window
        , ("M-S-<Up>",          windows W.swapDown) -- Swap focused window with next window
        , ("M-S-<Down>",        windows W.swapUp) -- Swap focused window with prev window
        , ("M-<Enter>",         promote) -- Moves focused window to master, others maintain order
        , ("M-S-<Tab>",         rotSlavesDown) -- Rotate all windows except master and keep focus in place
        , ("M-C-<Tab>",         rotAllDown) -- Rotate all the windows in the current stack

    -- Layouts
        , ("M-<Tab>",           sendMessage NextLayout) -- Switch to next layout
        , ("M-C-M1-<Up>",       sendMessage Arrange)
        , ("M-C-M1-<Down>",     sendMessage DeArrange)
       
        , ("M-C-<Space>",       sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles noborder/full
        , ("M-S-<Space>",       sendMessage ToggleStruts) -- Toggles struts
        , ("M-S-n",             sendMessage $ MT.Toggle NOBORDERS)  -- Toggles noborder

    -- Increase/decrease windows in the master pane or the stack
        , ("M-<KP_Add>",        sendMessage (IncMasterN 1)) -- Increase number of clients in master pane
        , ("M-<KP_Subtract>",   sendMessage (IncMasterN (-1))) -- Decrease number of clients in master pane
        , ("M-S-<KP_Add>",      increaseLimit) -- Increase number of windows
        , ("M-S-<KP_Subtract>", decreaseLimit) -- Decrease number of windows

    -- Window resizing
        , ("M-<Left>",          sendMessage Shrink) -- Shrink horiz window width
        , ("M-<Right>",         sendMessage Expand) -- Expand horiz window width
        , ("M-S-<Left>",        sendMessage MirrorShrink) -- Shrink vert window width
        , ("M-S-<Right>",       sendMessage MirrorExpand) -- Exoand vert window width

    -- Sublayouts
    -- This is used to push windows to tabbed sublayouts, or pull them out of it.
        , ("M-C-<Left>",        sendMessage $ pullGroup L)
        , ("M-C-<Right>",       sendMessage $ pullGroup R)
        , ("M-C-<Up>",          sendMessage $ pullGroup U)
        , ("M-C-<Down>",        sendMessage $ pullGroup D)
        , ("M-C-m",             withFocused (sendMessage . MergeAll))
        , ("M-C-u",             withFocused (sendMessage . UnMerge))
        , ("M-C-/",             withFocused (sendMessage . UnMergeAll))
        , ("M-C-,",             onGroup W.focusUp') -- Switch focus to next tab
        , ("M-C-.",             onGroup W.focusDown')  -- Switch focus to prev tab

    -- TODO, look into below Scratchpads
        , ("M-`",               namedScratchpadAction myScratchPads "terminal")
        
    -- Screen Shots
        , ("<Print>",           spawn ("sleep 0.25; shot select"))
        , ("M-<Print>",         spawn ("m-scrot"))
        , ("C-<Print>",         spawn ("sleep 0.25; shot"))
        , ("S-<Print>",         spawn ("sleep 0.25; shot focused"))

    -- Multimedia Keys
        , ("<XF86AudioPlay>",        spawn ("playerctl play-pause"))
        , ("<XF86AudioStop>",        spawn ("playerctl stop"))
        , ("<XF86AudioPrev>",        spawn ("playerctl previous"))
        , ("<XF86AudioNext>",        spawn ("playerctl next"))
        , ("<XF86AudioMute>",        spawn ("amixer set Master toggle"))
        , ("<XF86Launch8>",          spawn ("amixer set Master 5%+ unmute"))
        , ("<XF86Launch7>",          spawn ("amixer set Master 10%- unmute"))
        , ("<XF86AudioRaiseVolume>", spawn ("amixer set Master 5%+ unmute"))
        , ("<XF86AudioLowerVolume>", spawn ("amixer set Master 10%- unmute"))
        ]
    
    -- The following lines are needed for named scratchpads.
          where nonNSP          = WSIs (return (\ws -> W.tag ws /= "nsp"))
                nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "nsp"))

main :: IO ()
main = do
    -- Launching three instances of xmobar on their monitors.
    xmproc0 <- spawnPipe "xmobar -x 0 $HOME/.xmonad/xmobar/xmobarrcM.hs"
    xmproc1 <- spawnPipe "xmobar -x 1 $HOME/.xmonad/xmobar/xmobarrcL.hs"
    xmproc2 <- spawnPipe "xmobar -x 2 $HOME/.xmonad/xmobar/xmobarrcR.hs"
    
    xmonad $ ewmh def
        { manageHook = ( isFullscreen --> doFullFloat ) <+> myManageHook <+> manageDocks
        -- Run xmonad commands from command line with "xmonadctl command". Commands include:
        -- shrink, expand, next-layout, default-layout, restart-wm, xterm, kill, refresh, run,
        -- focus-up, focus-down, swap-up, swap-down, swap-master, sink, quit-wm. You can run
        -- "xmonadctl 0" to generate full list of commands written to ~/.xsession-errors.
        -- To compile xmonadctl: ghc -dynamic xmonadctl.hs
        , handleEventHook    = serverModeEventHookCmd
                               <+> serverModeEventHook
                               <+> serverModeEventHookF "XMONAD_PRINT" (io . putStrLn)
                               <+> docksEventHook
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = showWName' myShowWNameTheme $ myLayoutHook
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        , logHook = workspaceHistoryHook <+> myLogHook <+> dynamicLogWithPP xmobarPP
                        { ppOutput          = \x -> hPutStrLn xmproc0 x  >> hPutStrLn xmproc1 x >> hPutStrLn xmproc2 x
                        , ppCurrent         = xmobarColor "#98be65" "" . wrap "[" "]" -- Current workspace in xmobar
                        , ppVisible         = xmobarColor "#98be65" ""                -- Visible but not current workspace
                        , ppHidden          = xmobarColor "#82AAFF" "" . wrap "*" ""  -- Hidden workspaces in xmobar
                        , ppHiddenNoWindows = xmobarColor "#c792ea" ""                -- Hidden workspaces (no windows)
                        , ppTitle           = xmobarColor "#b3afc2" "" . shorten 60   -- Title of active window in xmobar
                        , ppSep             =  "<fc=#666666> <fn=2>|</fn> </fc>"      -- Separators in xmobar
                        , ppUrgent          = xmobarColor "#C45500" "" . wrap "!" "!" -- Urgent workspace
                        , ppExtras          = [windowCount]                           -- # of windows current workspace
                        , ppOrder           = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                        }
        } `additionalKeysP` myKeys
