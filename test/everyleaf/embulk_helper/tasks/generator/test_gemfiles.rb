module Everyleaf
  module EmbulkHelper
    module Tasks
      module Generator
        class TestGemfiles < Test::Unit::TestCase
          def setup
            FileUtils.touch(gemspec)

            @task = Gemfiles.new(options)
            mute_logger(@task)
            template = Pathname.new("/tmp/gem.erb")
            stub(@task).gemfile_template_path { template }
            File.open(template, "w") do |f|
              f.write <<-ERB
gem "embulk", "<%= version %>"
              ERB
            end
            stub(@task).embulk_versions { embulk_versions }
          end

          class TestMinVersion < self
            def test_without_specified
              @task.gemfiles
              files = Dir["#{@task.root_dir}/gemfiles/embulk-*"]

              # all versions + latest version
              assert_equal(embulk_versions.length + 1, files.length)
            end

            def test_0_1_1_with_env
              ENV["MIN_VERSION"] = "0.1.1"
              @task.gemfiles
              files = Dir["#{@task.root_dir}/gemfiles/embulk-*"]

              # all versions + latest version - 0.1.1
              assert_equal(4, files.length)
            ensure
              ENV.delete("MIN_VERSION")
            end

            def test_0_1_1_with_options
              opt = options
              stub(self).options { opt[:min_vesion] = "0.1.1"; opt }
              files = Dir["#{@task.root_dir}/gemfiles/embulk-*"]

              # all versions + latest version - 0.1.1
              assert_equal(4, files.length)
            end
          end

          class TestContent < self
            def test_content_latest
              @task.gemfiles
              content = @task.root_dir.join("gemfiles/embulk-latest").read
              assert_equal(<<-TXT, content)
gem "embulk", "> 0.0.1"
              TXT
            end

            def test_content_0_1_2
              @task.gemfiles
              content = @task.root_dir.join("gemfiles/embulk-0.1.2").read
              assert_equal(<<-TXT, content)
gem "embulk", "0.1.2"
              TXT
            end
          end

          def test_task_installed
            Everyleaf::EmbulkHelper::Tasks.install(options)
            gemfiles_task = Rake::Task.tasks.find do |task|
              task.name == "generate:gemfiles"
            end
            assert gemfiles_task
          end

          def test_gemfiles_create
            @task.gemfiles
            files = Dir["#{@task.root_dir}/gemfiles/embulk-*"]

            # each version + latest version
            assert_equal(embulk_versions.length + 1, files.length)
          end

          private

          def gemspec
            "/tmp/foo.gemspec"
          end

          def embulk_versions
            %W(0.1.0 0.1.1 0.1.2 0.2.0).map{|v| Gem::Version.new(v)}
          end

          def options
            {
              gemspec: gemspec
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
