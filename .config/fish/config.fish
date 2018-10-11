
# 
# PROMPT
#


# https://www.martinklepsch.org/posts/git-prompt-for-fish-shell.html

# Fish git prompt
set __fish_git_prompt_show_informative_status 'yes'
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch yellow
set __fish_git_prompt_color_upstream_ahead green
set __fish_git_prompt_color_upstream_behind red

# Status Chars
# set __fish_git_prompt_char_dirtystate '⚡'
# set __fish_git_prompt_char_stagedstate '→'
# set __fish_git_prompt_char_untrackedfiles '☡'
# set __fish_git_prompt_char_stashstate '↩'
# set __fish_git_prompt_char_upstream_ahead '+'
# set __fish_git_prompt_char_upstream_behind '-'

# name: Nim
# author: Guilhem "Nim" Saurel − https://github.com/nim65s/dotfiles/

function fish_prompt
    and set retc green; or set retc red
    tty|grep -q tty; and set tty tty; or set tty pts

    set_color $retc
    if [ $tty = tty ]
        echo -n .-
    else
        echo -n '┬─'
    end
    set_color -o green
    echo -n [
    if test $USER = root -o $USER = toor
        set_color -o red
    else
        set_color -o yellow
    end
    echo -n $USER
    set_color -o white
    echo -n @
    if [ -z "$SSH_CLIENT" ]
        set_color -o blue
    else
        set_color -o cyan
    end
    echo -n (hostname)
    set_color -o white
    #echo -n :(prompt_pwd)
    echo -n :(pwd|sed "s=$HOME=~=")
    set_color -o green
    echo -n ']'
    set_color normal
    set_color $retc
    if [ $tty = tty ]
        echo -n '-'
    else
        echo -n '─'
    end
    set_color -o green
    echo -n '['
    set_color normal
    set_color $retc
    echo -n (date +%X)
    set_color -o green
    echo -n ]
    set_color normal
    echo -n (__fish_git_prompt)
    set_color normal
    
    # Check if acpi exists
    if not set -q __fish_nim_prompt_has_acpi
    	if type acpi > /dev/null 2>&1
    		set -g __fish_nim_prompt_has_acpi ''
    	else
    		set -g __fish_nim_prompt_has_acpi '' # empty string
    	end
    end
    	
    if test "$__fish_nim_prompt_has_acpi"
		if [ (acpi -a 2> /dev/null | grep off) ]
			echo -n '─['
			set_color -o red
			echo -n (acpi -b|cut -d' ' -f 4-)
			set_color -o green
			echo -n ']'
		end
	end
    echo
    set_color normal
    for job in (jobs)
        set_color $retc
        if [ $tty = tty ]
            echo -n '; '
        else
            echo -n '│ '
        end
        set_color brown
        echo $job
    end
    set_color normal
    set_color $retc
    if [ $tty = tty ]
        echo -n "'->"
    else
        echo -n '╰─>'
    end
    set_color -o red
    echo -n '$ '
    set_color normal
end

#
# COLORS
#

# http://ethanschoonover.com/solarized#the-values

# Use these settings if you've applied a Solarized theme to your terminal (for
# example, if "ls -G" produces Solarized output). i.e. if "blue" is #268bd2, not
# whatever the default is. (See "../etc/Solarized Dark.terminal" for OS X.)

set -l base03  "--bold black"
set -l base02  "black"
set -l base01  "--bold green"
set -l base00  "--bold yellow"
set -l base0   "--bold blue"
set -l base1   "--bold cyan"
set -l base2   "white"
set -l base3   "--bold white"
set -l yellow  "yellow"
set -l orange  "--bold red"
set -l red     "red"
set -l magenta "magenta"
set -l violet  "--bold magenta"
set -l blue    "blue"
set -l cyan    "cyan"
set -l green   "green"

# Use these settings if your terminal supports term256 and your terminal hasn't
# been configured with a Solarized theme.i.e. if "blue" is the default blue, not
# Solarized blue.

# set -l base03  002b36
# set -l base02  073642
# set -l base01  586e75
# set -l base00  657b83
# set -l base0   839496
# set -l base1   93a1a1
# set -l base2   eee8d5
# set -l base3   fdf6e3
# set -l yellow  b58900
# set -l orange  cb4b16
# set -l red     dc322f
# set -l magenta d33682
# set -l violet  6c71c4
# set -l blue    268bd2
# set -l cyan    2aa198
# set -l green   859900

# Used by fish's completion; see
# http://fishshell.com/docs/2.0/index.html#variables-color

set -g fish_color_normal      $base0
set -g fish_color_command     $base0
set -g fish_color_quote       $cyan
set -g fish_color_redirection $base0
set -g fish_color_end         $base0
set -g fish_color_error       $red
set -g fish_color_param       $blue
set -g fish_color_comment     $base01
set -g fish_color_match       $cyan
set -g fish_color_search_match "--background=$base02"
set -g fish_color_operator    $orange
set -g fish_color_escape      $cyan

# # Used by fish_prompt

set -g fish_color_hostname    $cyan
set -g fish_color_cwd         $yellow
set -g fish_color_git         $green


# 
# OTHER
#


# cat ~/.cache/wal/sequences
alias ll='ls -alF'
set --erase fish_greeting
