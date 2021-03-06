# StrongVersions

# Overview

_StrongVersions_ enforces a strict policy on your `Gemfile` requirements:

* The pessimistic `~>` operator must be used for all gem requirement definitions.
* If the gem version is greater than 1, the requirement format must be `major.minor`, e.g. `'~> 2.5`'
* If the gem version is less than 1, the requirement format must be `major.minor.patch`, e.g. `'~> 0.8.9'`
* A lower/upper bound can be specified as long as a valid pessimistic version is also specified, e.g. `'~> 8.4', '< 8.6.7'`
* All gems with a `path` or `git` source are ignored, e.g. `path: '/path/to/gem'`, `git: 'https://github.com/bobf/strong_versions'`
* All gems specified in the [ignore list](#ignore) are ignored.

Any gems that do not satisfy these rules will be included in the _StrongVersions_ output with details on why they did not meet the standard.

When all gems in a `Gemfile` follow this convention it SHOULD always be safe to run `bundle update` (assuming all gems adhere to [Semantic Versioning](https://semver.org/)).

![StrongVersions](doc/images/strong-versions-example.png)

## Installation

Add the gem to your `Gemfile`

```ruby
gem 'strong_versions', '~> 0.4.5'
```

And rebuild your bundle:

```bash
$ bundle install
```

## Usage

_StrongVersions_ is invoked with a provided executable:

```bash
$ bundle exec strong_versions
```

The executable will output all non-passing gems and will return an exit code of `1` on failure, `0` on success (i.e. all gems passing). This makes _StrongVersions_ suitable for use in a continuous integration pipeline:

![StrongVersions](doc/images/ci-pipeline.png)

Auto-correct is available with the `-a/--auto-correct` option:
```bash
$ bundle exec strong_versions -a
```

### Exclusions

<a name="ignore"></a>You can tell _StrongVersions_ to ignore any of your gems (e.g. those that don't follow _semantic versioning_) by adding them to the `ignore` section of `.strong_versions.yml` in your project root, e.g.:

```yaml
# .strong_versions.yml
ignore:
  - rails
```

Gems in the ignore list will not be updated when using the `-a/--auto-correct` option.
## Contributing

Fork and create a pull request.

Run tests with _RSpec_:

```
$ bin/rspec
```

Check code with _Rubocop_:

```
$ bin/rubocop
```

## License

[MIT License](LICENSE)
