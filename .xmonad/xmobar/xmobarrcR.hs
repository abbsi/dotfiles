-- http://projects.haskell.org/xmobar/
-- install xmobar with these flags: --flags="with_alsa" --flags="with_mpd" --flags="with_xft"  OR --flags="all_extensions"

Config { font            =   "xft:SauceCodePro Nerd Font:pixelsize=16:antialias=true:hinting=true"
       , additionalFonts = [ "xft:SauceCodePro Nerd Font:pixelsize=16:antialias=true:hinting=true"
                           , "xft:SauceCodePro Nerd Font:pixelsize=16:antialias=true:hinting=true"
                           , "xft:FontAwesome:pixelsize=13"
                           ]
       , bgColor = "#282c34"
       , fgColor = "#ff6c6b"
       , position = Static { xpos = 6410, ypos = 80, width = 2560, height = 40 }
       , lowerOnStart = True
       , hideOnStart = False
       , allDesktops = True
       , persistent = True
       , iconRoot = "/home/abbsi/.xmonad/xpm/"  -- default: "."
       , commands = [ 
                      -- Time and date
                      Run Date "<fn=1>\xf133 </fn> %b %d %Y (%H:%M)" "date" 50
                      -- Network up and down
                    , Run Network "eth0" ["-t", "<fn=1>\xf0aa </fn> <rx>kb  <fn=1>\xf0ab </fn> <tx>kb"] 20
                      -- Cpu usage in percent
                    , Run Cpu ["-t", "<fn=1>\xf108 </fn> cpu: (<total>%)","-H","50","--high","red"] 20
                      -- Ram used number and percent
                    , Run Memory ["-t", "<fn=1>\xf233 </fn> mem: <used>M (<usedratio>%)"] 20
                      -- Disk space free
                    , Run DiskU [("/", "<fn=1>\xf0c7 </fn> hdd: <free> free")] [] 60
                      -- Runs custom script to check for pacman updates.
                      -- This script is in my dotfiles repo in .local/bin.
                    , Run Com "pacupdate" [] "pacupdate" 36000
                      -- Runs a standard shell command 'uname -r' to get kernel version
                    , Run Com "uname" ["-r"] "" 3600
                      -- Prints out the left side items such as workspaces, layout, etc.
                      -- The workspaces are 'clickable' in my configs.
                    , Run UnsafeStdinReader
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = " <action=`xdotool key control+alt+g`><icon=haskell_20.xpm/> </action><fc=#666666></fc> %UnsafeStdinReader% }{ <fc=#666666><fn=2>|</fn> </fc><fc=#b3afc2><fn=1> </fn>  %uname% </fc><fc=#666666> <fn=2>|</fn></fc> <fc=#ecbe7b> %cpu% </fc><fc=#666666> <fn=2>|</fn></fc> <fc=#ff6c6b> %memory% </fc><fc=#666666> <fn=2>|</fn></fc> <fc=#51afef> %disku% </fc><fc=#666666> <fn=2>|</fn></fc> <fc=#98be65> %eth0% </fc><fc=#666666> <fn=2>|</fn></fc> <fc=#c678dd><fn=1> </fn>  %pacupdate% </fc><fc=#666666> <fn=2>|</fn></fc> <fc=#46d9ff> %date%  </fc>"
       }