#!/usr/bin/bash

# To use ble.sh by default in terminal sessions (part 1)
[[ $- == *i* ]] && source /home/Hasan/AUR/ble.sh/out/ble.sh --noattach

# Export
export TERM="xterm-256color"
export EDITOR="nvim"
export MANPAGER="nvim +Man!"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Starship prompt variable
PS1='[\u@\h \W]\$ '

# Path variable
[[ -d "$HOME/.bin" ]] && export PATH="$HOME/.bin:$PATH"
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/go/bin/" ]] && export PATH="$HOME/go/bin:$PATH"
# Other variables
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

[[ -d "$XDG_DATA_HOME/cargo" ]] && export CARGO_HOME="$XDG_DATA_HOME/cargo"
[[ -f "$XDG_CONFIG_HOME/npm/npmrc" ]] && export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
[[ -f "$XDG_RUNTIME_DIR/Xauthority" ]] && export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
[[ -f "$XDG_CONFIG_HOME/X11/xinitrc" ]] && export XINITRC="$XDG_CONFIG_HOME/X11/xinitrc"
[[ -d /opt/jdk-21.0.2 ]] && export JAVA_HOME=/opt/jdk-21.0.2

# Zoxide configuration variable | the database store
export _ZO_DATA_DIR="$XDG_DATA_HOME"

# Bash properties
shopt -s autocd       # Automatic cding when writng a path
shopt -s cdspell      # Autocorrecting cs misspellings
shopt -s checkwinsize # Checking the size of the terminal with each command and adjusting accordinagly

# Archive extraction
ex() {
	if [ -f "$1" ]; then
		case $1 in
		*.tar.bz2) tar xjf "$1" ;;
		*.tar.gz) tar xzf "$1" ;;
		*.bz2) bunzip2 "$1" ;;
		*.rar) unrar x "$1" ;;
		*.gz) gunzip "$1" ;;
		*.tar) tar xf "$1" ;;
		*.tbz2) tar xjf "$1" ;;
		*.tgz) tar xzf "$1" ;;
		*.zip) unzip "$1" ;;
		*.Z) uncompress "$1" ;;
		*.7z) 7z x "$1" ;;
		*.deb) ar x "$1" ;;
		*.tar.xz) tar xf "$1" ;;
		*.tar.zst) unzstd "$1" ;;
		*) echo "'$1' cannot be extracted via ex()" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

# grep colorizaton alises
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Replacments aliases
alias ls='lsd'
l.() {
	lsd -A -1 "$@" | grep -E "^\."
}
alias cat='bat'

# Arch Linux aliases
update() {
	if [[ $# -eq 0 ]]; then
		sudo pacman -Syu
	else
		sudo pacman -S --needed "$@"
	fi
}
alias install='sudo pacman -S'
alias uninstall='sudo pacman -Rns'

search() {
	if [[ $1 == '-p' ]]; then
		shift
		pacman -Ss "$@"
	elif [[ $1 == '-y' ]]; then
		shift
		yay -Ss "$@"
	elif ! pacman -Ss "$@"; then
		echo -e "\033[1;31mSearching with pacman failed. proceeding with yay...\033[0m"
		yay -Ss "$@"
	fi
}

# Arch Linux man pages
aman() {
	if [ -z "$1" ]; then
		return 1
	fi

	content=$(curl -sL "https://man.archlinux.org/man/$1.raw")
	if [ -n "$(printf "$content" | head -n 1)" ]; then
		echo "$content" | man -l -
	else
		printf "man page not found\n"
		return 1
	fi
}

# Create Python Project
#mkpro() {
#  if [[ $# -eq 0 ]]
#  then
#    if [[ ! -f ".untitled_number" ]]
#    then
#      echo -e "\033[1;31mNo .untitled_number found to create Untitled projects.\033[0m"
#      exit 1

#    elif [[ ! -s ".untitled_number" ]]
#    then
#      local untitled_number=1

#    else
#      local untitled_number=(($(cat .untitled_number)++))
#    fi

#    $untitled_number > .untitled_number

#    local base_name="Untitled"
#    local untitled_number = (($(cat .untitled_number)))
#  fi
#}

# Get fastest mirrors
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

# Adding flags automatically
alias df='df -h' # For human-readable sizes
alias free='free -h'
alias cp='cp -i' # For interactive copying [won't override a file without your permission]

# Git aliases
alias addup='git add -u'
alias addall='git add .'
alias clone='git clone'
alias commit='git commit -m'
alias push='git push origin'
alias stat='git status'
alias remote='git remote add origin'

# Shutdown alias
alias poweroff='systemctl poweroff'

# Check that passed arguments are files
checkfiles() {
	for file in "$@"; do
		if [[ ! -f "$file" ]]; then
			return 1
		fi
	done

	return 0
}

# preview/render files
preview() {
	if checkfiles "$@"; then
		case "$1" in
		*.html) lynx "$1" ;;
		*.md | *.MD) glow "$@" ;;
		*.docx) pandoc -f docx plain "$1" | cat ;;
		*.pdf | *.PDF) pdftotext -layout "$1" - | cat ;;
		esac
	else
		echo -e "\033[1;31mFailed: Some or all of the given parameters are not files.\033[0m"
	fi
}

# Open files with defaults
open() {
	if [[ -f "$1" ]]; then
		case "$1" in
		*.mp4 | .mkv | *youtube | *youtu.be) mpv "$1" ;;
		esac
	fi
}

# NetworkManger alias
connect() {
	if [[ $# -ne 2 ]]; then
		echo "Failure to connect. Missing SSID or password."
		exit 1
	fi

	sudo nmcli device wifi connect "$1" password "$2"
}

# Enable fuck command
eval "$(thefuck --alias)"

# Starship prompt
eval "$(starship init bash)"

# Enable Zoxide autojumper
eval "$(zoxide init bash)"

# To use ble.sh by default in terminal sessions (part 2)
[[ ${BLE_VERSION- } ]] && ble-attach
