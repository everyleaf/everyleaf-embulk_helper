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
rvm:
  - jruby-19mode
jdk:
  - oraclejdk8

gemfile:
<% versions.each do |file| -%>
  - gemfiles/<%= file %>
<% end -%>
            YML
          end

          def travis_yml_template_path
            root_dir.join(options[:travis_yml_template] || DEFAULT_TRAVIS_YML_TEMPLATE)
          end

          def create_travis_yml
            erb = ERB.new(travis_yml_template_path.read, nil, "-")
            versions = gemfiles.map(&:basename)
            File.open(root_dir.join(".travis.yml"), "w") do |f|
              f.puts erb.result(binding())
            end
          end

          def gemfiles
            Pathname.glob(gemfiles_dir.join("embulk-*"))
          end
        end
      end
    end
  end
end
