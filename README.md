# homebrew-tap

Homebrew formulae by [@bobbyrathoree](https://github.com/bobbyrathoree).

## shellmux

A content-blind topic pub/sub broker in shell with a race-free deadline scheduler.
See [bobbyrathoree/shellmux](https://github.com/bobbyrathoree/shellmux).

```bash
brew tap bobbyrathoree/tap
brew install shellmux
shellmux --help
```

> **Linux-first.** shellmux needs `flock`, GNU `timeout`, and bash ≥ 4. On Linux
> (incl. Linuxbrew) those come from the brewed deps cleanly. On macOS the formula
> brews them too and wraps `shellmux` to find them, but the broker's FIFO/flock
> semantics are only fully guaranteed on Linux — for serious use, run it on Linux.
