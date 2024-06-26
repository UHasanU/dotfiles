#!/usr/bin/fish


function ex
    for arg in $argv
        if test -f "$arg"
            switch "$arg"
                case *.tar.bz2
                    tar xjf "$arg"
                case *.tar.gz
                    tar xzf "$arg"
                case *.bz2
                    bunzip2 "$arg"
                case *.rar
                    unrar x "$arg"
                case *.gz
                    gunzip "$arg"
                case *.tar
                    tar xf "$arg"
                case *.tbz2
                    tar xjf "$arg"
                case *.tgz
                    tar xzf "$arg"
                case *.zip
                    unzip "$arg"
                case *.Z
                    uncompress "$arg"
                case *.7z
                    7z x "$arg"
                case *.deb
                    ar x "$arg"
                case *.tar.xz
                    tar xf "$arg"
                case *.tar.zst
                    unzstd "$arg"
                case *
                    echo "'$arg' cannot be extracted via ex()"
            end
        else
            echo "'$arg' is not a valid file"
        end
    end
end

function fish_user_key_bindings
    set fish_cursor_default block
    # Set the insert mode cursor to a line
    set fish_cursor_insert line
    # Set the replace mode cursors to an underscore
    set fish_cursor_replace_one underscore
    set fish_cursor_replace underscore
    # Set the external cursor to a line. The external cursor appears when a command is started.
    # The cursor shape takes the value of fish_cursor_default when fish_cursor_external is not specified.
    set fish_cursor_external line
    # The following variable can be used to configure cursor shape in
    set fish_cursor_visual block

    fish_vi_key_bindings --no-erase insert
end


# Override the fish_add_path function
function add_to_path
    for dir in $argv
        if test -d $dir
            fish_add_path --path $dir
        end

        fish_user_key_bindings
    end
end

function l.
    lsd -A -1 "$argv" | grep -E "^/."
end

set --export --universal TERM alacritty
set --export --universal EDITOR nvim
set --export --universal MANPAGER "nvim +Man!"
set --export --universal LESS '-R --use-color -Dd+r$Du+b$'

add_to_path "$HOME/.bin" "$HOME/.local/bin" "$HOME/go/bin"

set --export --universal XDG_CONFIG_HOME "$HOME/.config"
set --export --universal XDG_DATA_HOME "$HOME/.local/share"
set --export --universal XDG_CACHE_HOME "$HOME/.cache"
set --export --universal XDG_STATE_HOME "$HOME/.local/state"

set --export --universal _ZD_DATA_DIR "$XDG_DATA_HOME"

abbr --add grep "grep --color=auto"
abbr --add egrep "egrep --color=auto"
abbr --add fgrep "fgrep --color=auto"
abbr --add ls lsd
abbr --add cat bat
abbr --add diff "diff --color=auto"
abbr --add ip "ip -color=auto"
abbr --add gcc colorgcc
abbr --add make colormake

function last_history_item
    echo $history[1]
end

abbr --add !! --position anywhere --function last_history_item

function update
    if test (count $argv) -eq 0
        sudo pacman -Syu
    else
        sudo pacman -S --needed "$argv"
    end
end

abbr --add install "sudo pacman -S"
abbr --add uninstall "sudo pacman -Rns"

function search
    if test $1 == -p
        shift
        pacman -Ss "$argv"
        elif test $1 == -y
        shift
        yay -Ss "$argv"
        elif ! pacman -Ss "$argv" 2>/dev/null
        echo -e "\033[1;31mSearching with pacman failed. proceeding with yay"
        yay -Ss "$argv"
    end
end

abbr --add mirror "sudo reflector --fastest 30 --latest 30 --number 20 --verbose --save /etc/pacman.d/mirrorlist"
abbr --add mirror_score "sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"

abbr --add df "df -h"
abbr --add du "du -h"
abbr --add free "free -h"

function connect
    if test (count $argv) -ne 2
        echo "Failure to connect. Missing SSID or password"
        exit 1
    end

    sudo nmcli device wifi connect "$1" password "$2"
end

thefuck --alias | source

starship init fish | source
