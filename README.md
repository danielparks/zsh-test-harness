# Zsh Test Harness

```
❯ ./run-tests.zsh --help
Usage: run-tests.zsh [--help] [--show-output] [--keep] [test-files]

  --help         Show this message.
  --show-output  Show output from all tests, not just the ones that fail.
  --keep         Keep the test working directory instead of deleting it.

test-files:
  Optional path to tests to run. If a path is a directory, it will run all
  files found within the directory.

  Default: ./tests
```

You can define test helpers in files matching the glob `test-*.zsh`, e.g.
`test-helpers.zsh`. If functions named `before_test` and `after_test` are
defined, they will be run before and after each test, respectively.

See [danielparks-zsh-theme][] for an example of a repo with tests.

## Installation

Copy run-test.zsh into `$PATH`, or just copy it into the repo with the tests.

## Other shell testing projects

Other shell testing frameworks include:

 * [ShellSpec](https://shellspec.info) ([GitHub](https://github.com/shellspec/shellspec))
 * [ZUnit](https://zunit.xyz) ([GitHub](https://github.com/zunit-zsh/zunit))

## Development status

I don’t have plans to add features to this, but I might add things if it’s
helpful for another project. That said, if you think this is a good fit for you
but need changes I’m open to [suggestions][] and [PRs][].

## License

This project dual-licensed under the Apache 2 and MIT licenses. You may choose
to use either.

 * [Apache License, Version 2.0](LICENSE-APACHE)
 * [MIT license](LICENSE-MIT)

### Contributions

Unless you explicitly state otherwise, any contribution you submit as defined
in the Apache 2.0 license shall be dual licensed as above, without any
additional terms or conditions.


[danielparks-zsh-theme]: https://github.com/danielparks/danielparks-zsh-theme
[suggestions]: https://github.com/danielparks/zsh-test-harness/issues
[PRs]: https://github.com/danielparks/zsh-test-harness/pulls
