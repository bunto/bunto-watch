# Bunto Watch

Rebuild your Bunto site when a file changes with the `--watch` switch.

[![Build Status](https://travis-ci.org/bunto/bunto-watch.svg?branch=master)](https://travis-ci.org/bunto/bunto-watch)
[![Gem Version](https://badge.fury.io/rb/bunto-watch.svg)](https://badge.fury.io/rb/bunto-watch)

## Installation

**`bunto-watch` comes pre-installed with Bunto 1.0 or greater.**

Add this line to your application's Gemfile:

    gem 'bunto-watch'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bunto-watch

## Usage

Pass the `--watch` flag to `bunto build` or `bunto serve`:

```bash
$ bunto build --watch
$ bunto serve --watch # this flag is the default, so no need to specify it here for the 'serve' command
```

The `--watch` flag can be used in combination with any other flags for those
two commands, except `--detach` for the `serve` command.

## Contributing

1. Fork it ( https://github.com/bunto/bunto-watch/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
