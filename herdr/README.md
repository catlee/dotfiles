# Herdr

`config.toml` is linked to `~/.config/herdr/config.toml` by `./install`.
It uses only Linux/macOS-compatible Herdr settings.

The `Ctrl+h/j/k/l` bindings require the separately installed
[`vim-herdr-navigation`](https://github.com/RooseveltAdvisors/vim-herdr-navigation)
plugin, which declares support for both Linux and macOS:

```sh
herdr plugin install RooseveltAdvisors/vim-herdr-navigation
```

The repository's Neovim configuration loads that plugin automatically when
running inside Herdr. Reload Herdr after installing it (`Ctrl+Space`, then `q`).

The `prefix+space` / `prefix+shift+space` layout-cycling bindings require the
[`herdr-layout-cycle`](https://github.com/amiramay/herdr-layout-cycle) plugin:

```sh
herdr plugin install amiramay/herdr-layout-cycle
```

The `prefix+a` binding opens pi in a tiled split via the local `pi-pane`
plugin in `plugins/pi-pane/`. `./install` links it automatically when `herdr`
is on `PATH`; to link it manually:

```sh
herdr plugin link herdr/plugins/pi-pane
```

On macOS, configure the terminal to send Option as Meta/Esc for the `alt+…`
bindings. The core `Ctrl+…` bindings work without that setting. If macOS binds
`Ctrl+Space` to input-source switching, disable or change that system shortcut.
