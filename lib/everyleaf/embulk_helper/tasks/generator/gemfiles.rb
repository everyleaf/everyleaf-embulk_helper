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
            init
            create_gemfiles
            logger.info "Updated Gemfiles '#{min_version}' to '#{embulk_versions.max}'"
          end

          private

          def init
            FileUtils.mkdir_p File.dirname(gemfile_template_path)
            unless File.exists?(gemfile_template_path)
              logger.info "Generate gemfiles template file (#{gemfile_template_path})"
              File.open(gemfile_template_path, "w") do |f|
                f.write initial_template
              end
            end
          end

          def initial_template
            <<-ERB
source 'https://rubygems.org/'
gemspec :path => '#{gemspec_path.dirname.relative_path_from(gemfiles_dir)}/'

gem "embulk", "<%= version %>"
            ERB
          end

          def create_gemfiles
            FileUtils.mkdir_p(gemfiles_dir)

            Dir[gemfiles_dir.join("embulk-*")].each{|f| File.unlink(f)}

            target_versions.each do |version|
              create_gemfile(version)
            end

            # e.g. embulk-0.6-latest
            target_versions_without_patch.each do |version|
              create_gemfile("~> #{version}", "#{version}-latest")
            end

            # embulk-latest
            create_gemfile("> #{min_version}", "latest")
          end

          def create_gemfile(version, name = nil)
            erb = ERB.new(gemfile_template_path.read)
            File.open(gemfiles_dir.join("embulk-#{name || version}"), "w") do |f|
              f.write erb.result(binding())
            end
          end

          def min_version
            Gem::Version.new(ENV["MIN_VERSION"] || options[:min_version] || "0.0.1")
          end

          def gemfile_template_path
            root_dir.join(options[:gemfile_template] || DEFAULT_EMBULK_GEMFILE_TEMPLATE)
          end

          def target_versions
            embulk_versions.find_all do |version|
              version >= min_version
            end
          end

          def target_versions_without_patch
            target_versions.map do |version|
              major, minor, _ = version.segments
              Gem::Version.new([major, minor].join("."))
            end.compact.uniq
          end
        end
      end
    end
  end
end
