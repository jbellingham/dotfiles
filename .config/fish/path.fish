if not contains "$HOME/.local/bin" $PATH
    set -gx --prepend PATH "$HOME/.local/bin"
end

# BEGIN -- ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims
# END -- ASDF configuration code

## Android config
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk
if not contains "$ANDROID_HOME/emulator" $PATH
    set -gx --prepend PATH "$ANDROID_HOME/emulator"
end

if not contains "$ANDROID_HOME/platform-tools" $PATH
    set -gx --prepend PATH "$ANDROID_HOME/platform-tools"
end

if not contains "$HOMEBREW_PREFIX/opt/postgresql@16/bin" $PATH
    set -gx --prepend PATH "$HOMEBREW_PREFIX/opt/postgresql@16/bin"
end

## End Android config