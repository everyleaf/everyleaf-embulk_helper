require "everyleaf/embulk_helper/tasks/common"

module Everyleaf
  module EmbulkHelper
    module Tasks
      module Generator
        class Gemfiles
          include Tasks::Common

          DEFAULT_EMBULK_GEMFILE_TEMPLATE = "gemfiles/template.erb".freeze

          def install_tasks
            namespace :generate do
              desc "Generate gemfiles to test this plugin with released Embulk versions (since MIN_VERSION)"
              task :gemfiles do
                gemfiles
              end
            end
          end

          def gemfiles
            logger.info "Generate Embulk gemfiles from '#{min_version}' to latest"
            create_gemfiles
            logger.info "Updated Gemfiles '#{min_version}' to '#{embulk_versions.max}'"
          end

          private

          def create_gemfiles
            FileUtils.mkdir_p(gemfiles_dir)

            Dir[gemfiles_dir.join("embulk-*")].each{|f| File.unlink(f)}
            erb = ERB.new(gemfile_template_path.read)

            embulk_versions.each do |version|
              next if version < min_version
              File.open(gemfiles_dir.join("embulk-#{version}"), "w") do |f|
                f.write erb.result(binding())
              end
            end
            File.open(gemfiles_dir.join("embulk-latest"), "w") do |f|
              version = "> #{min_version}"
              f.write erb.result(binding())
            end
          end

          def min_version
            Gem::Version.new(ENV["MIN_VERSION"] || options[:min_version] || "0.0.1")
          end

          def gemfile_template_path
            root_dir.join(options[:gemfile_template] || DEFAULT_EMBULK_GEMFILE_TEMPLATE)
          end
        end
      end
    end
  end
end
