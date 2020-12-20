# Moslty borrowed from Derek Taylor https://gitlab.com/dwt1/dotfiles

# Set -U fish_user_paths $fish_user_paths $HOME/.local/bin/
set fish_greeting
set TERM "xterm-256color"
set EDITOR "vim"
set VISUAL "code"
set -gx PATH $HOME/bin $HOME/.local/bin $PATH
# Spark functions
function letters
    cat $argv | awk -vFS='' '{for(i=1;i<=NF;i++){ if($i~/[a-zA-Z]/) { w[tolower($i)]++} } }END{for(i in w) print i,w[i]}' | sort | cut -c 3- | spark | lolcat
    printf  '%s\n' 'abcdefghijklmnopqrstuvwxyz'  ' ' | lolcat
end

function commits
    git log --author="$argv" --format=format:%ad --date=short | uniq -c | awk '{print $1}' | spark | lolcat
end

# Functions needed for !! and !$
function __history_previous_command
  switch (commandline -t)
  case "!"
    commandline -t $history[1]; commandline -f repaint
  case "*"
    commandline -i !
  end
end

function __history_previous_command_arguments
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end

# The bindings for !! and !$
if [ $fish_key_bindings = fish_vi_key_bindings ];
  bind -Minsert ! __history_previous_command
  bind -Minsert '$' __history_previous_command_arguments
else
  bind ! __history_previous_command
  bind '$' __history_previous_command_arguments
end

# Function for copying files and directories, even recursively.
# ex: copy DIRNAME LOCATIONS
# result: copies the directory and all of its contents.
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
	set from (echo $argv[1] | trim-right /)
	set to (echo $argv[2])
        command cp -r $from $to
    else
        command cp $argv
    end
end

# Function for creating a backup file
# # ex: backup file.txt
# # result: copies file as file.txt.bak
function backup --argument filename
  cp $filename $filename.bak
end

### ALIASES ###
# spark aliases
# alias clear='clear; seq 1 (tput cols) | sort -R | spark | lolcat; echo'

# root privileges
# alias doas="doas --"

# navigation
alias ..='cd ..' 
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# broot
alias br='broot -dhp'
alias bi='broot -dhpi'
alias bs='broot --sizes'

# Changing "ls" to "exa"
alias ls='exa -al --color=always --group-directories-first' # my preferred listing
alias la='exa -a --color=always --group-directories-first'  # all files and dirs
alias ll='exa -l --color=always --group-directories-first'  # long format
alias lt='exa -aT --color=always --group-directories-first' # tree listing

# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'

# adding flags
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB

## get top process eating memory
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'

# pacman and yay
alias pacsyu='sudo pacman -Syyu'                 # update only standard pkgs
alias pacs='sudo pacman -S'                      # install package
alias yaysua='yay -Sua --noconfirm'              # update only AUR pkgs
alias yaysyu='yay -Syu --noconfirm'              # update standard pkgs and AUR pkgs
alias unlock='sudo rm /var/lib/pacman/db.lck'    # remove pacman lock
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'  # remove orphaned packages

# get fastest mirrors
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

# git
alias addup='git add -u'
alias addall='git add .'
alias branch='git branch'
alias checkout='git checkout'
alias clone='git clone'
alias commit='git commit -am'
alias fetch='git fetch'
alias pull='git pull origin'
alias push='git push origin'
alias gstatus='git status'
alias tag='git tag'
alias newtag='git tag -a'

# get error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# youtube-dl
alias yta-aac="youtube-dl --extract-audio --audio-format aac "
alias yta-best="youtube-dl --extract-audio --audio-format best "
alias yta-flac="youtube-dl --extract-audio --audio-format flac "
alias yta-m4a="youtube-dl --extract-audio --audio-format m4a "
alias yta-mp3="youtube-dl --extract-audio --audio-format mp3 "
alias yta-opus="youtube-dl --extract-audio --audio-format opus "
alias yta-vorbis="youtube-dl --extract-audio --audio-format vorbis "
alias yta-wav="youtube-dl --extract-audio --audio-format wav "
alias ytv-best="youtube-dl -f bestvideo+bestaudio "

# switch between shells
alias tobash="sudo chsh $USER -s /bin/bash && echo 'Now log out.'"
alias tozsh="sudo chsh $USER -s /bin/zsh && echo 'Now log out.'"
alias tofish="sudo chsh $USER -s /bin/fish && echo 'Now log out.'"

alias gen="/environment/mercer_docs/generate.sh"

alias sucode="sudo code --user-data-dir='/root/.vscode-root'"
alias bld-dwm="cd /env/suckless/dwm; make clean && make && sudo make install && make clean"
alias bld-blocks="cd /env/suckless/dwmblocks; make clean && make && sudo make install && make clean"
alias bld-dmenu="cd /env/suckless/dmenu; make clean && make && sudo make install && make clean"
alias bld-sls="cd /env/suckless/slstatus; make clean && make && sudo make install && make clean"

starship init fish | source

###### Bud Spencer Settings
# set -U budspencer_nocmdhist c d ll ls m s la lt
# set -U budspencer_no_cd_bookmark
# set -U budspencer_night 000000 083743 D7005F fdf6e3 3792DD cb4b16 dc121f af005f 6c71c4 FFFFFF 2aa198 859900
# set -U budspencer_day 000000 333333 666666 ffffff ffff00 ff6600 ff0000 ff0033 3300ff 00aaff 00ffff 00ff00
# set -U budspencer_colors $budspencer_night

######  Bob the fish Settings
# set -g theme_display_git yes
# set -g theme_display_git_untracked yes
# set -g theme_display_git_ahead_verbose yes
# set -g theme_git_worktree_support yes
# set -g theme_display_vagrant yes
# set -g theme_display_docker_machine yes
# set -g theme_display_hg yes
# set -g theme_display_virtualenv yes
# set -g theme_display_ruby yes
# set -g theme_display_user yes
# set -g theme_display_vi yes
# set -g theme_display_date no
# set -g theme_display_cmd_duration yes
# set -g theme_title_display_process yes
# set -g theme_title_display_path no
# set -g theme_title_use_abbreviated_path no
# set -g theme_date_format "+%H:%M"
# set -g theme_avoid_ambiguous_glyphs yes
# set -g theme_powerline_fonts yes
# set -g theme_nerd_fonts no
# set -g theme_show_exit_status yes
# set -g default_user nabil
# set -g theme_color_scheme dark
# set -g fish_prompt_pwd_dir_length 3
# set -g theme_project_dir_length 1

