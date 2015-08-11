[![Build Status](https://travis-ci.org/everyleaf/everyleaf-embulk-helper.svg?branch=master)](https://travis-ci.org/everyleaf/everyleaf-embulk-helper)
[![Code Climate](https://codeclimate.com/github/everyleaf/everyleaf-embulk-helper/badges/gpa.svg)](https://codeclimate.com/github/everyleaf/everyleaf-embulk-helper)
[![Test Coverage](https://codeclimate.com/github/everyleaf/everyleaf-embulk-helper/badges/coverage.svg)](https://codeclimate.com/github/everyleaf/everyleaf-embulk-helper/coverage)

# Everyleaf::EmbulkHelper



## Installation

Add this line to your application's Gemfile:

```ruby
gem 'everyleaf-embulk_helper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install everyleaf-embulk_helper

Load rake tasks at your Rakefile:

    require "bundler/gem_tasks"
    require "everyleaf/embulk_helper/tasks"

    Everyleaf::EmbulkHelper::Tasks.install({
      gemspec: "./embulk-input-your-plugin.gemspec",
      github_name: "uu59/embulk-input-your-plugin",
    })

## Usage

    $ bundle exec rake -T
    rake build                     # Build embulk-input-your-plugin-0.1.0.gem into the pkg directory
    rake generate:bump_version     # Bump version
    rake generate:changelog        # Generate CHANGELOG.md from previous release
    rake generate:gemfiles         # Generate gemfiles to test this plugin with released Embulk versions (since MIN_VERSION)
    rake generate:prepare_release  # Generate chengelog then bump version
    rake generate:travis           # Generate .travis.yml with gemfiles
    rake install                   # Build and install embulk-input-your-plugin-0.1.0.gem into system gems
    rake release                   # Create tag v0.1.0 and build and push embulk-input-your-plugin-0.1.0.gem to Rubygems

### generate:gemfiles

    $ mkdir gemfiles
    $ cat > gemfiles/template.erb
    source 'https://rubygems.org/'
    gemspec :path => '../'

    gem "embulk", "<%= version %>"

    $ tree gemfiles
    gemfiles
    └── template.erb

    0 directories, 1 file
    $ bundle exec rake generate:gemfiles MIN_VERSION=0.6.10
    I, [2015-08-11T11:03:37.202083 #10238]  INFO -- : Generate Embulk gemfiles from '0.6.10' to latest
    I, [2015-08-11T11:03:38.966539 #10238]  INFO -- : Updated Gemfiles '0.6.10' to '0.6.21'
    $ tree gemfiles
    gemfiles
    ├── embulk-0.6.10
    ├── embulk-0.6.11
    ├── embulk-0.6.12
    ├── embulk-0.6.13
    ├── embulk-0.6.14
    ├── embulk-0.6.15
    ├── embulk-0.6.16
    ├── embulk-0.6.17
    ├── embulk-0.6.18
    ├── embulk-0.6.19
    ├── embulk-0.6.20
    ├── embulk-0.6.21
    ├── embulk-latest
    └── template.erb
    $ cat gemfiles/embulk-latest
    source 'https://rubygems.org/'
    gemspec :path => '../'

    gem "embulk", "> 0.6.10"

    $ cat gemfiles/embulk-0.6.18
    source 'https://rubygems.org/'
    gemspec :path => '../'

    gem "embulk", "0.6.18"

### generate:travis

NOTE: `versions` in template is assigned by file globbing from `gemfiles/*`, thus run `rake generate:gemfiles` before `rake generate:travis`.

    $ cat > .travis.yml.erb
    gemfiles:
    <% versions.each do |v| -%>
      - <%= v %>
    <% end -%>

    $ bundle exec rake generate:travis
    I, [2015-08-11T11:06:53.375018 #10911]  INFO -- : Updated .travis.yml
    $ cat .travis.yml
    gemfiles:
      - embulk-0.6.10
      - embulk-0.6.11
      - embulk-0.6.12
      - embulk-0.6.13
      - embulk-0.6.14
      - embulk-0.6.15
      - embulk-0.6.16
      - embulk-0.6.17
      - embulk-0.6.18
      - embulk-0.6.19
      - embulk-0.6.20
      - embulk-0.6.21
      - embulk-latest

## Contributing

1. Fork it ( https://github.com/[my-github-username]/everyleaf-embulk_helper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
