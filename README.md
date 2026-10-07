# Dotfiles

Managed with [yadm](https://yadm.io). Files live in `~` and yadm tracks them in place. There are no symlinks.

## Set up a fresh MacBook

### 1. Install the basics

```sh
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install yadm git gnupg
```

### 2. Get your SSH key onto the machine

The remote is SSH, so the clone needs a key GitHub accepts.

- Install 1Password, sign in, and enable its SSH agent. Or copy your key into `~/.ssh`.
- Fix permissions: `chmod 700 ~/.ssh && chmod 600 ~/.ssh/*`
- Test it: `ssh -T git@github.com`

### 3. Clone the dotfiles

```sh
yadm clone git@github.com:jbellingham/dotfiles.git
```

If yadm says files would be overwritten, keep the repo's version:

```sh
yadm reset --hard origin/trunk
```

### 4. Install apps and tools

```sh
brew bundle --file ~/Brewfile
brew install starship
```

- `brew bundle` can report errors for Java. Run it again after Java installs.
- `starship` is missing from the `Brewfile`. Add it there.

### 5. Install the shell setup

`~/.zshrc` expects Oh My Zsh and these plugins.

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc
C=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins
git clone --depth=1 https://github.com/mroth/evalcache $C/evalcache
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting $C/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions $C/zsh-autosuggestions
git clone --depth=1 https://github.com/Aloxaf/fzf-tab $C/fzf-tab
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

`--keep-zshrc` stops the installer from replacing your `.zshrc`.

Planning to use antidote? Run only the `tpm` clone from that block. Then follow "Move from oh-my-zsh to antidote" below.

### 6. Install languages with mise

```sh
mise install
```

- Config is in `~/.config/mise/config.toml` (Ruby 3). Add more tools there.

### 7. Finish by hand

- Open a new terminal. Set the font to `MesloLGS Nerd Font`.
- Restart the terminal. `exec zsh` does not reload fonts.
- Turn on FileVault: System Settings > Privacy & Security.
- Optional: `bash ~/osx_defaults.sh` to apply macOS settings. It lists only non-default values.
- Sign in to apps: 1Password, GitHub (`gh auth login`), Claude Code.

## Daily use

```sh
yadm status
yadm add <file>
yadm commit -m "type(scope): message"
yadm push
```

Run `yadm` anywhere. It works like `git` for these files.

## Move from oh-my-zsh to antidote

`~/.zsh_plugins.txt` is ready and does nothing until `.zshrc` loads it. Do this once on this machine. On a fresh machine, do it instead of step 5.

1. Install it: `brew install antidote`
2. In `~/.zshrc`, delete these lines:

   ```sh
   export ZSH=${HOME}/.oh-my-zsh
   DISABLE_UPDATE_PROMPT="true"
   export UPDATE_ZSH_DAYS=10
   plugins=(evalcache brew sudo zsh-autosuggestions macos direnv zsh-syntax-highlighting fzf-tab)
   source $ZSH/oh-my-zsh.sh
   ```

3. Put this where `source $ZSH/oh-my-zsh.sh` was. Keep the `ENABLE_CORRECTION` and `HIST_STAMPS` lines above it.

   ```sh
   source "$(brew --prefix)/share/antidote/antidote.zsh"
   antidote load
   autoload -Uz compinit && compinit
   ```

   Keep the `fzf-tab` zstyle lines below it.
4. Open a new terminal. The first start clones the plugins, so it is slow once.
5. Check that these work: `sudo` double-Escape, Tab completion with fzf-tab, autosuggestions, syntax colours, `brew` completion.
6. Clean up once happy:
   - `rm -rf ~/.oh-my-zsh`
   - Remove `zsh-autosuggestions` and `zsh-syntax-highlighting` from the `Brewfile`. antidote loads its own copies.
   - Add `antidote` to the `Brewfile`.
   - Delete `.p10k.zsh`. `starship` replaced it.

Roll back: restore `.zshrc` with `yadm checkout ~/.zshrc`. This works only until you commit the change.

Notes:
- Plugin order is changed on purpose. The fzf-tab docs say to load it before autosuggestions and syntax-highlighting. Your old list put it last.
- `evalcache` is dropped. Nothing in your shell files calls it.
- `lib` keeps oh-my-zsh's history, correction and key bindings. Remove that line later to see what you really use.
- After editing `.zsh_plugins.txt`, antidote rebuilds its cache on the next start.

## Known gaps

- `.zshrc` sources work-only paths under `~/dev/work/chargefox-tools`. Clone that repo, or the shell prints errors.
- `.zshrc` and `.zprofile` hard-code `/Users/jessebellingham`.
- `~/dev/dotfiles` is a plain clone of this repo, not managed by yadm. It can go stale.
- `fresh_install_of_osx.sh` is an older, mostly commented-out script. It stops partway on purpose. Prefer the steps above.
- `nix-darwin-config/` is not applied. `darwin-rebuild` is not installed.
- `.winget` and `install-linux.sh` are for other platforms.
