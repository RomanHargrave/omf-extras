#!/usr/bin/fish
#Include other libraries in your fish scripts
#Set `fish_require_search` to add directories to the `require` search path

# Folder name to be used when autolocating search directories
set -q __require_dir_name; or set __require_dir_name    lib

# File extension for libraries
set -q __require_lib_ext; or set __require_lib_ext      fish

# Helpers

function __require_debug 
    if set -q fish_require_debug
        echo "require: $argv" 2>&1
    end
end

# Path setup functions

function __require_search_path_append
    __require_debug "__require_search_path_append $argv"
    if not set -q fish_require_path
        __require_debug "require path variable does not exist, creating it"
        set -gx fish_require_path
    end


    for path in $argv
        if not contains $path $fish_require_path
            __require_debug "adding $path to the search path"
            set fish_require_path $fish_require_path $path
        end
    end
end

function __require_setup_search_directories

    # OMF Paths
    begin
        if set -q fish_path
            set omf_require_dir "$fish_path/$__require_dir_name"
            set omf_custom_dir  "$fish_custom/$__require_dir_name"

            if not set -q fish_custom
                set omf_custom_dir "$fish_path/custom/$__require_dir_name"
            end

            __require_search_path_append $omf_require_dir
            __require_search_path_append $omf_custom_dir
        end
    end

    # Fish folder path
    begin
        set fish_home_dir
        
        # Locate the fish configuration directory
        # Fish will use $XDG_CONFIG_HOME/fish, if it exists, otherwise it will default to $HOME/.config/fish
        if set -q XDG_CONFIG_HOME
            set fish_home_dir "$XDG_CONFIG_HOME/fish"
        else
            set fish_home_dir "$HOME/.config/fish"
        end

        __require_debug "checking to see if $fish_home_dir exists"

        # Check that the fish folder exists
        if [ -d $fish_home_dir ]
            set fish_require_dir "$fish_home_dir/$__require_dir_name"
            __require_search_path_append $fish_require_dir
        else
            echo "Could not find your fish folder (where config.fish lives). I looked in $fish_home_dir." 2>&1
        end
    end

end

# Library indexing functions

function __require_strip_file_extension
    for name in $argv
        echo $name | grep --color=never -Po '^.*(?=\.[^\.]+?)'
    end
end

function __require_get_library_path -a lib_name
    __require_setup_search_directories

    for path in $fish_require_path/$lib_name.$__require_lib_ext
        if [ -f $path ]
            echo $path
            return 0
        end
    end

    return 1
end

function __require_get_library_paths
    __require_setup_search_directories
    
    # Collect .fish files in the search path.
    # Directories at the beginning of the search path will have precedence over those at the end, should there be duplicate files
    # The search will not be recursive, this should allow the library scripts to have their own subdirectories if they should need
    # to require various snippets that don't need to pollute the require candidate list

    set __libraries_found 

    for dir in $fish_require_path
        for lib in $dir/*.$__require_lib_ext
            set __lib_name (basename $lib)
            if not contains $__lib_name $__libraries_found
                set __libraries_found $__lib_name
                echo $lib
            end
        end
    end

end

function __require_list_libraries
    __require_strip_file_extension (__require_get_library_paths | xargs -n1 basename)
end

# Require function

function __require_fail -a lib_name
    echo "require: could not find a library named `$lib_name`"

    if set -q fish_require_fatal
        __require_debug "fish_require_fatal is set; exiting with non-zero status"
        exit 1
    end
end

function require
    for lib in $argv
        __require_debug "requiring $lib"
        if __require_get_library_path $lib >/dev/null
            set __lib_path (__require_get_library_path $lib)
            __require_debug "found $lib in $__lib_path"
            source $__lib_path
        else
            __require_debug "could not find $lib"
            __require_fail $lib
        end
    end
end
