## Unreleased
### Added
- Parse and use database username from rails database.yml file.

## [0.8.2] - 2020-06-18
### Fixed
- Fixed compilation problems with TextUI.

## [0.8.1] - 2020-06-18
### Fixed
- Fixed compilation with Crystal 0.35.

## [0.8.0] - 2020-04-10
### Changed
- Compile our own version of libtermibox and static link to it, so there's no need to install termbox anymore.

### Fixed
- Updated dependencies and fix warning to compile with Crystal 0.34.
- Few UI fixes from TextUi shard.

## [0.7.0] - 2020-03-31
### Added
- Added mouse support to query editor and database list.
- You can focus query editor, database list and results view with a mouse click.
- Do not show garbage on screen in some ocasions when viewing a table result cell.

### Fixed
- Fix SQL beautifier doing weird things like transforming "counter" into "COUNTer".
- Do not highlight SQL comments inside strings.
- Highlight numbers on SQL editor.

## [0.6.0] - 2020-02-13
### Added
- Added undo/redo to query editor!

### Fixed
- Fix results box title not being highlighted when focused.
- Fix garbage on database list when resizing on certain occasions.
- Do not crash if the terminal width/height is too tiny.

## [0.5.1] - 2020-01-19
### Changed
- TextUI module (code used to render the UI) moved to its own shard.

### Fixed
- Do not print a stacktrace when passing a invalid parameter.
- Save last used query in the same place for postgres://host/db and postgresql://host/db.
- Do not print ANSI escape sequences when pressing CTRL + LEFT/RIGHT ARROW.
- Consider ALT key on shortcuts.

## [0.5.0] - 2020-01-03
### Added
- Syntax highlighting!!
- When query editor focused, CTRL+L clear editor.
- When query editor focused, CTRL+/ comment/uncomment lines.
- Show query excetuion time and number of rows in result set.
- Page up/down can be used to scroll results table.
- Page up/down can be used on query editor.
- Query editor is now scrollable.

### Fixed
- Adjust selected item on viewport on database list widget.
- Do not re-render list widget on each key press.

## [0.4.0] - 2019-12-17
### Added
- New fancy border box style.
- Render focused boxes with different colors.
- Cycle focus on TAB key.
- Show full result value when ENTER key is pressed on results table.
- Save editor contents per database URI at exit.

## [0.3.0] - 2019-12-09
### Added
- Show EXPLAIN queries as a text in result box.
- Improved query editor: Show line numbers, has word wrap and a decent cursor navigation.
- SQL beautifier implemented, still not perfect, but helps!

## [0.2.1] - 2019-11-18
### Changed
- User version_from_shard v1.0.0.

## [0.2.0] - 2019-11-18
### Added
- Detect Amber project configuration.

### Changed
- Show SQL errors on results table instead of the status bar.

### Fixed
- SQLite3 databases now works.
- Results table navigation should work.
- Let the SQL editor empty at start.

## [0.1.0] - 2019-11-07

- First release, only basic things working but still useful.
- Support for SQLite and MySQL is there, but never tested.
- Postgres is the only one tested for now.
