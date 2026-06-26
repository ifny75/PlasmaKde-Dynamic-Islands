# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project follows
loose [Semantic Versioning](https://semver.org/) while pre-1.0.

## [0.8.0]
### Added
- "Layout" settings tab.
- Optional **"/" separators** between compact modules.
- Reorderable compact blocks (Content · Time · FPS) with 6 presets.
- FPS counter with two styles (accent badge / plain clock font).
- **Distance from panel** setting (0–120) to stop the expanded panel from
  overlapping the capsule.

### Changed
- Plain FPS style now reads `N fps` in the clock font.

## [0.7.0]
### Added
- Reorderable compact segments via config.

## [0.6.0]
### Added
- Split settings into multiple tabbed categories.
- Permanent FPS counter next to the clock.
### Fixed
- CPU/RAM monitor moved to the isolated sensors API (`SystemMonitor.qml`) so an
  unavailable module can't break the widget.
- Orange sharing dot now reliably appears for "screen sharing + music".

## [0.5.0]
### Added
- System monitor mode: CPU & RAM usage alternating with the clock.
- Per-module enable/disable switches.
- Separate widths for music / notification / status panels.
- Clock seconds and date options; configurable idle & sharing dot colors.
- Orange sharing indicator left of the music.

## [0.4.0]
### Changed
- Notifications redesigned (wider, cleaner, multi-line body).

## [0.3.0]
### Added
- Configurable background, opacity, corner radius, border and accent color.
- Compact capsule transparent by default; filled background on the big panel.

## [0.2.0]
### Added
- Settings UI and configuration keys.
- IntelliJ IDEA build-result capsule.
### Fixed
- Popup no longer lingers on another monitor when closing.

## [0.1.0]
### Added
- Initial dynamic-island capsule: clock, MPRIS media, notifications, keyboard
  layout, downloads and screen-sharing states with an expandable popup.
