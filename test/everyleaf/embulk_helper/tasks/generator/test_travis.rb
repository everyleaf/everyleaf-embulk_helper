module Everyleaf
  module EmbulkHelper
    module Tasks
      module Generator
        class TestTravis < Test::Unit::TestCase
          def setup
            FileUtils.touch(gemspec)

            @task = Travis.new(options)
            mute_logger(@task)
            File.open(template_path, "w") do |f|
              f.write <<-ERB
<% versions.each do |v| -%>
  - <%= v %>
<% end -%>
              ERB
            end
            stub(@task).embulk_versions { embulk_versions }
          end

          def test_task_installed
            Everyleaf::EmbulkHelper::Tasks.install(options)
            travis_task = Rake::Task.tasks.find do |task|
              task.name == "generate:travis"
            end
            assert travis_task
          ensure
            Rake::Task.clear
          end

          def test_travis_yml_create
            stub(@task).gemfiles { %w(/tmp/foo /tmp/bar).map{|f| Pathname.new(f) } }
            @task.travis
            file = @task.root_dir.join(".travis.yml")

            assert_equal(<<-YML, file.read)
  - foo
  - bar
YML
          end

          private

          def gemspec
            "/tmp/foo.gemspec"
          end

          def template_path
            Pathname.new("/tmp/travis.erb")
          end

          def options
            {
              gemspec: gemspec,
              travis_yml_template: template_path.to_s,
            }
          end

          def mute_logger(task)
            stub(task).logger { ::Logger.new(File::NULL) }
          end
        end
      end
    end
  end
end
