# Lucid Yard

The Lucid Yard gem acts as a YARD extension to process Gherkin-style feature files.

The gem itself is called `yard-lucid` (rather than `lucid-yard`) because the YARD tool provides built-in support for gems being used as plugins. In order for that to work, the gems in question must have the prefix `yard-`.

Gherkin objects like features, backgrounds, scenarios, tags, steps, step definitions, and transforms are integrated into a YARD template.

Lucid Yard provides a parser component, which is the first component in YARD's processing pipeline. This parser runs before any handling is done on the source itself. Lucid Yard provides a hook into the Gherkin parser rather than attempting to recreate the parser.

The parser translates the source into a set of statements that can be understood by the handlers that run immediately afterward. Handling is done after parsing to abstract away the implementation details of lexical and semantic analysis on the source and to only deal with the logic regarding recognizing source statements as particular types of code objects. Lucid Yard provides handlers that recognize the base level constructs of a Gherkin-style document. In other words, Gherkin feature files are being treated as a form of source code.

The handler is taking parsed statements, processing them, and in that action, creating what are called code objects. Code objects are Ruby objects that describe the code being documented. Lucid Yard provides a specific set of code objects that match any constructs that can be found in a Gherkin feature file. These code objects in turn create tags (essentially, metadata) that are attached to the objects.

These code objects are then added to an internal registry, which is a data store component.

The final act of this is the processing of objects from the registry via a templating engine, which is what allows output to be generated.

## Installation

To get the latest stable release, add this line to your application's Gemfile:

```ruby
gem 'yard-lucid'
```

To get the latest code:

```ruby
gem 'yard-lucid', git: 'https://github.com/jeffnyman/yard-lucid'
```

After doing one of the above, execute the following command:

    $ bundle

You can also install Lucid Yard just as you would any other gem:

    $ gem install yard-lucid

## Usage

Since `yard-lucid` is acting as an extension to YARD, you have to enable the automatic loading of such extensions by YARD. The easiest way to do this is:

```bash
$ mkdir ~/.yard
$ yard config load_plugins true
```

Once that is done, you can run YARD as you normally would and have your Gherkin repository captured as a YARD documentation artifact.

```bash
$ yardoc 'features/**/*.feature' 'steps/**/*.rb'
```

### Documentation Server

You can also use the YARD server to serve up a copy of a documentation repository. In the directory where you generated your documentation, do this:

```
yard server
```

This will start up a server at http://localhost:8808 that you can then view your repository at.

### Configuration

By default the yardoc output will generate a search field for features and tags. This can be configured through the yard configuration file `~/.yard/config`. By default the configuration, YAML format, that is generate by the `yard config` command will save a `SymbolHash`. You can still edit this file add the entry for `:"yard-lucid":` and the sub-entry `menus:`. Here's an example:

```yaml
--- !map:SymbolHash
:load_plugins: true
:ignored_plugins: []

:autoload_plugins: []

:safe_mode: false

:"yard-lucid":
  menus: [ 'features', 'directories', 'tags', 'steps', 'step definitions' ]
```

This allows you to add or remove these search fields. The `menus` section can contain all of the above mentioned menus or simply an empty array `[]` if you want no additional menus.

You can exclude any feature or scenario from the yardoc by adding predefined tags to them. To define tags that will be excluded in the yard configuration file, just do this:

```yaml
  :"yard-lucid":
    exclude_tags: [ 'practice', 'demo' ]
```

Here any scenarios or features marked with the tags `@practice` or `@demo` would not be included in the documentation.

Finally, you may want to add other step definition keywords. Lucid Yard already supports the English step definition keywords, but you might want to add foreign language ones. Or you might be using some variant of Gherkin that allows for different step definitions. Using the yard configuration file, you can define additional step definitions that can be matched.

```yaml
:"yard-lucid":
  language:
    step_definitions: [ 'Given', 'When', 'Then', 'And', '*', 'Soit', 'Etantdonné', 'Lorsque', 'Lorsqu', 'Alors', 'Et' ]
```

Note that when doing this you'll want to include the defaults that Lucid Yard provides as well.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Given the nature of Lucid Yard, it's difficult to provide unit tests for it, so you won't find a great deal of them. In fact, you'll find basically none.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/jeffnyman/yard-lucid](https://github.com/jeffnyman/yard-lucid). The testing ecosystem of Ruby is very large and this project is intended to be a welcoming arena for collaboration on yet another test-supporting tool. As such, contributors are very much welcome but are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

The Lucid Yard gems follows [semantic versioning](http://semver.org).

To contribute to Lucid Yard:

1. [Fork the project](http://gun.io/blog/how-to-github-fork-branch-and-pull-request/).
2. Create your feature branch. (`git checkout -b my-new-feature`)
3. Commit your changes. (`git commit -am 'new feature'`)
4. Push the branch. (`git push origin my-new-feature`)
5. Create a new [pull request](https://help.github.com/articles/using-pull-requests).

## Author

* [Jeff Nyman](http://testerstories.com)

## Credits

This code is based upon the [Yard-Cucumber](https://github.com/burtlo/yard-cucumber) gem. The reason for this approach rather than a fork is that I wanted to clean up a lot of the code decisions made by the original author. I also wanted to move away from a strict Cucumber terminology. Finally, the original author hasn't necessarily been as responsive to pull requests which I felt would limit my options.

## License

Lucid Yard is distributed under the [MIT](http://www.opensource.org/licenses/MIT) license.
See the [LICENSE](https://github.com/jeffnyman/yard-lucid/blob/master/LICENSE.md) file for details.
