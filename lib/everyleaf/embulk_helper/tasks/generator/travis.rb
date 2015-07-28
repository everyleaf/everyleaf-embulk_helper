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
            create_travis_yml
            logger.info "Updated .travis.yml"
          end

          private

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
