# Contributing

Thanks for your interest in improving Dynamic Island! 🎉

## Getting started

1. Fork and clone the repo.
2. Make your changes under `package/`.
3. Install and reload to test:
   ```bash
   ./install.sh
   kquitapp6 plasmashell && kstart plasmashell
   ```
   For faster iteration on a single state, use `plasmawindowed
   com.ifny75.dynamicisland` — QML errors print to the terminal.

## Guidelines

- **Pure QML** — there is no build step. Keep it that way unless there's a strong
  reason.
- **Match the surrounding style**: 4-space indentation, `readonly property`
  bindings where possible, descriptive ids.
- **Every new setting** needs three things, kept in sync:
  1. an entry in `contents/config/main.xml` (with a sensible default),
  2. a `cfg_<key>` alias on exactly one tab in `contents/ui/config*.qml`,
  3. a `Plasmoid.configuration.<key>` read in `main.qml`.
- **Don't break the widget on missing optionals.** Anything that depends on an
  external module (e.g. sensors) should be isolated/guarded the way
  `SystemMonitor.qml` is.
- Update `CHANGELOG.md` and bump the version in `package/metadata.json`.

## Reporting bugs

Open an issue with your Plasma/Qt version, what you expected, what happened, and
relevant output from:
```bash
journalctl --user -f -t plasmashell
```

## License

By contributing, you agree that your contributions are licensed under the
project's [MIT License](LICENSE).
