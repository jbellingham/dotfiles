# Dotfiles

Managed with [yadm](https://yadm.io). Files live in `~` and yadm tracks them in place. There are no symlinks.

## Set up a fresh MacBook

One command does everything below. Safe to re-run.

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/jbellingham/dotfiles/trunk/install_osx.sh)
```

What `install_osx.sh` runs, in order:

1. Xcode command line tools, then Homebrew.
2. `yadm` and `git`.
3. `yadm clone` over HTTPS into `~`, then switches the remote to SSH. On a fresh Mac it replaces stock dotfiles such as `.zshrc`.
4. `brew bundle` from `~/Brewfile`.
5. oh-my-zsh, its plugins, and tmux's plugin manager.
6. `mise install`.
7. `~/osx_defaults.sh`.
8. A FileVault check.

You need to do these by hand:

- Click through the Xcode tools installer when it appears.
- Enter your password once when asked.
- Put your SSH key in place. 1Password's SSH agent works. Test with `ssh -T git@github.com`.
- Sign in to 1Password, the App Store, GitHub (`gh auth login`) and Claude Code. Mac App Store items in the Brewfile need the App Store sign-in first.
- Set the terminal font. Ghostty uses `Monaspace Argon` (`font-monaspace` in the Brewfile).
- Point Alfred at its synced settings: Preferences > Advanced > Syncing > Set preferences folder, then choose `~/.config/alfred`. Needs the Powerpack licence.
- Clone `~/dev/work/chargefox-tools`. `.zshrc` sources files from it.
- Quit and reopen the terminal.

Want antidote instead of oh-my-zsh? Add `--antidote` to the command:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/jbellingham/dotfiles/trunk/install_osx.sh) --antidote
```

This only installs antidote. Your `.zshrc` must already load it, or the script warns. See "Move from oh-my-zsh to antidote" below.

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

## Not captured by yadm

Set these up by hand on a new Mac.

- **Touch ID for sudo.** Create `/etc/pam.d/sudo_local` with the line `auth sufficient pam_tid.so`.
- **Cron job.** Restore after cloning `~/second-brain`. Add it with `crontab -e`:

  ```
  15 9 * * * /usr/bin/ruby /Users/jessebellingham/second-brain/chargefox/snippets/scripts/export-claude-sessions.rb >> /Users/jessebellingham/second-brain/chargefox/snippets/scripts/export-claude-sessions.log 2>&1
  ```

- **Local dev DNS.** `puma-dev` is in the Brewfile but not set up. Per its docs, run `sudo puma-dev -setup` then `puma-dev -install`. Not tested here.
- **Secrets and credentials.** Keep these in 1Password, not in git: `~/.ssh`, `~/.gnupg`, `~/.aws`, `~/.netrc`, `~/.wakatime.cfg`, `~/.docker/config.json`, `~/.granted`, and the `.env` files in the work repos.
- **Shell history.** `~/.zsh_history` and McFly's `history.db` do not carry over.
- **Other home items to copy or leave behind:** `~/bin`, `~/.talisman*`, `~/.zshenv`, `~/.git-template`, `~/.serverlessrc`, `~/.logseq`, `~/Documents`.
- **Claude Code.** `~/.claude.json` (MCP servers, may hold tokens) and `~/.claude/hooks/` are not tracked. `settings.json` still points at the hooks, so remove those entries or copy the folder.

## Known gaps

- `.zshrc` sources work-only paths under `~/dev/work/chargefox-tools`. Clone that repo, or the shell prints errors.
- `.zshrc` and `.zprofile` hard-code `/Users/jessebellingham`.
- `~/dev/dotfiles` is a plain clone of this repo, not managed by yadm. It can go stale.
- `nix-darwin-config/` is not applied. `darwin-rebuild` is not installed.
- `.winget` and `install-linux.sh` are for other platforms.
