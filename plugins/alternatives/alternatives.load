# vim: set ft=fish :
set __plg_dir__     (dirname (status -f))
set __plg_bin__     "$__plg_dir__/bin"
if not functions -q require
    set_color red
    echo "The `require` plugin must be installed in order to use alternatives" 1>&2
    set_color normal
else if [ -d $__plg_bin__ ]
    set -gx PATH $PATH $__plg_bin__
else
    set_color red
    echo "$__plg_bin__ not found" 1>&2
    set_color normal
end
