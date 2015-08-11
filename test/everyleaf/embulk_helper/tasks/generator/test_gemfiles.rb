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

          class TestInitialContent < self
            def setup
              FileUtils.mkdir_p root
              FileUtils.touch gemspec_path

              task = Gemfiles.new(options.merge({
                github_name: "dummy/dummy",
                gemspec: gemspec_path,
                gemfile_template_path: gemfile_template_path,
              }))
              mute_logger(task)
              task.send(:init)
            end

            def teardown
              FileUtils.rm_rf root
            end

            def test_relative_path
              content = File.read(gemfile_template_path)
              assert content.include?("path => '../'") # the gemspec path from each gemfiles/* as relative
            end

            def test_embulk_version_contain
              content = File.read(gemfile_template_path)
              assert content.include?(%Q|gem "embulk", "<%= version %>"|)
            end

            private

            def gemfile_template_path
              root.join("gemfiles/template.erb")
            end

            def root
              Pathname.new("/tmp/foo")
            end

            def gemspec_path
              root.join("bar.spec")
            end
          end

          def test_task_installed
            Everyleaf::EmbulkHelper::Tasks.install(options)
            gemfiles_task = Rake::Task.tasks.find do |task|
              task.name == "generate:gemfiles"
            end
            assert gemfiles_task
          ensure
            Rake::Task.clear
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
              gemspec: gemspec,
              github_name: "everyleaf/everyleaf-embulk_helper",
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
