require "everyleaf/embulk_helper/tasks/common"

module Everyleaf
  module EmbulkHelper
    module Tasks
      module Generator
        class Travis
          include Tasks::Common

          DEFAULT_TRAVIS_YML_TEMPLATE = ".travis.yml.erb".freeze

          def install_tasks
            namespace :generate do
              desc "Generate .travis.yml with gemfiles"
              task :travis do
                travis
              end
            end
          end

          def travis
            init
            create_travis_yml
            logger.info "Updated .travis.yml"
          end

          private

          def init
            FileUtils.mkdir_p File.dirname(travis_yml_template_path)
            unless File.exists?(travis_yml_template_path)
              logger.info "Generate travis.yml template (#{travis_yml_template_path})"
              File.open(travis_yml_template_path, "w") do |f|
                f.write initial_template
              end
            end
          end

          def initial_template
            <<-YML
language: ruby

jdk: oraclejdk8

rvm:
  - jruby-19mode
  - jruby-9.0.0.0

gemfile:
<% versions.each do |file| -%>
  - gemfiles/<%= file %>
<% end -%>

matrix:
  exclude:
    - jdk: oraclejdk8 # Ignore all matrix at first, use `include` to allow build
  include:
    <% matrix.each do |m| -%>
<%= m %>
    <% end %>

  allow_failures:
    - gemfile: gemfiles/embulk-0.6.22
    - gemfile: gemfiles/embulk-0.7.0
    - gemfile: gemfiles/embulk-0.7.1
    # Ignore failure for *-latest
    <% versions.find_all{|file| file.to_s.match(/-latest/)}.each do |file| -%>
- gemfile: <%= file %>
    <% end %>
            YML
          end

          def travis_yml_template_path
            root_dir.join(options[:travis_yml_template] || DEFAULT_TRAVIS_YML_TEMPLATE)
          end

          def create_travis_yml
            erb = ERB.new(travis_yml_template_path.read, nil, "-")
            File.open(root_dir.join(".travis.yml"), "w") do |f|
              f.puts erb.result(binding())
            end
          end

          def gemfiles
            Pathname.glob(gemfiles_dir.join("embulk-*"))
          end

          def versions
            # for trabis.yml.erb
            gemfiles.map(&:basename)
          end

          def matrix
            # for trabis.yml.erb
            gemfiles.map do |path|
              rvm = path.to_s.include?("0.6") ? "jruby-19mode" : "jruby-9.0.0.0"
              %Q|- {rvm: #{rvm}, gemfile: #{path.relative_path_from(root_dir)}}|
            end
          end
        end
      end
    end
  end
end
