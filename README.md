# StrongVersions

```
The right thing to guide us
Is right here inside us
               --Nickelback
```

# Overview

_StrongVersions_ enforces a strict policy on your `Gemfile` requirements:

* The pessimistic `~>` operator must be used for all gem requirement definitions.
* If the gem version is greater than 1, the requirement format must be `major.minor`, e.g. `'~> 2.5`'
* If the gem version is less than 1, the requirement format must be `major.minor.patch`, e.g. `'~> 0.8.9'`
* An upper bound can be specified as long as a valid pessimistic version is also specified, e.g. `'~> 8.4', '< 8.6.7' # Bug introduced in 8.6.7`
* All gems with a `path` or `git` source are ignored, e.g. `path: '/path/to/gem'`, `git: 'https://github.com/bobf/strong_versions'`
* All gems specified in the [ignore list](#ignore) are ignored.

Any gems that do not satisfy these rules will be included in included in the _StrongVersions_ output with details on why they did not meet the standard.

The benefit of applying this standard is that, if all gems follow [Semantic Versioning](https://semver.org/) always be relatively safe to run `bundle update` to upgrade to the latest compatible versions of all dependencies. Running `bundle update` often brings advantages both in terms of bug fixes and security updates.

![StrongVersions](doc/images/strong-versions-example.png)

## Installation

Add the gem to your `Gemfile`

```ruby
gem 'strong_versions', '~> 0.3.1'
```

And rebuild your bundle:

```bash
$ bundle install
```

Or install yourself:
```bash
$ gem install strong_versions -v '0.3.0'
```

## Usage

_StrongVersions_ is invoked with a provided executable:

```bash
$ bundle exec strong_versions
```

The executable will output all non-passing gems and will return an exit code of `1` on failure, `0` on success (i.e. all gems passing). This makes _StrongVersions_ suitable for use in a continuous integration pipeline.

### Exclusions

<a name="ignore"></a>You can tell _StrongVersions_ to ignore any of your gems (e.g. those that don't follow _semantic versioning_) by adding them to the `ignore` section of `.strong_versions.yml` in your project root, e.g.:

```yaml
# .strong_versions.yml
ignore:
  - rails
```

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
