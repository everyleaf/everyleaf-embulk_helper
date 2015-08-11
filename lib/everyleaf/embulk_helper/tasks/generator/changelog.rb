require "everyleaf/embulk_helper/tasks/common"

module Everyleaf
  module EmbulkHelper
    module Tasks
      module Generator
        class Changelog
          include Tasks::Common

          DEFAULT_CHANGELOG_TEMPLATE = "changelog.erb".freeze

          def install_tasks
            namespace :generate do
              desc "Generate chengelog then bump version"
              task :prepare_release => [:changelog, :bump_version]

              desc "Generate CHANGELOG.md from previous release"
              task :changelog do
                changelog
              end

              desc "Bump version. UP=major to do major version up, UP=minor, UP=patch(default) so on."
              task :bump_version do
                bump_version
                update_gemfile_lock
              end
            end
          end

          def changelog
            content = new_changelog
            File.open(changelog_path, "w") do |f|
              f.write content
            end
          end

          def bump_version
            logger.info "Version bump '#{current_version}' to '#{next_version}'"
            old_content = gemspec_path.read
            new_content = old_content.gsub(/(spec\.version += *)".*?"/, %Q!\\1"#{next_version}"!)
            File.open(gemspec_path, "w") do |f|
              f.write new_content
            end
          end

          private

          def required_options
            %w(github_name)
          end

          def current_version
            ENV["CURRENT_VER"] || Gem::Version.new(gemspec_path.read[/spec\.version += *"([0-9]+\.[0-9]+\.[0-9]+)"/, 1])
          end

          def next_version
            return ENV["NEXT_VER"] if ENV["NEXT_VER"]
            major, minor, patch = current_version.segments
            ver = case version_target
            when "patch"
              [major, minor, patch + 1].join(".")
            when "minor"
              [major, minor + 1, 0].join(".")
            when "major"
              [major + 1, 0, 0].join(".")
            end

            Gem::Version.new(ver)
          end

          def version_target
            ENV["UP"] || options[:version_target] || "patch"
          end

          def update_gemfile_lock
            system("bundle install")
          end

          def github_name
            options[:github_name]
          end

          def pull_request_numbers
            sync_git_repo
            `git log v#{current_version}..origin/master --oneline`.scan(/#[0-9]+/).map do |num_with_hash|
              num_with_hash[/[0-9]+/]
            end
          end

          def pull_request_info(number)
            body = open("https://api.github.com/repos/#{github_name}/issues/#{number}").read
            JSON.parse(body)
          end

          def changes
            pull_request_numbers.map do |number|
              payload = pull_request_info(number)
              "* [] #{payload["title"]} [##{number}](https://github.com/#{github_name}/pull/#{number})"
            end
          end

          def new_changelog
            <<-HEADER
## #{next_version} - #{Time.now.strftime("%Y-%m-%d")}
#{changes.join("\n")}

#{changelog_path.read.chomp}
            HEADER
          end

          def sync_git_repo
            system('git fetch --all')
          end

          def changelog_path
            root_dir.join("CHANGELOG.md")
          end
        end
      end
    end
  end
end
