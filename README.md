# Queryit

A very basic setupless terminal based SQL query runner meant to be used as a developer
tool to test queries against a project database.

## Installation

You need the project dependencies installed on your system:

 * Termbox C library - https://github.com/nsf/termbox
 * Crystal language compiler
 * Shards, the crystal language package manager

```
$ make
$ sudo make install
```

## Usage

On a rails project directory just run it.

```
$ queryit
```

Or specify the database URI
```
$ queryit --uri postgres://localhost/database
```

## Development

All this still in a very early development stage and still not so far from useless.

## Contributing

1. Fork it (<https://github.com/hugopl/queryit/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Hugo Parente Lima](https://github.com/hugopl) - creator and maintainer
