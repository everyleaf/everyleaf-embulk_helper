require "pathname"
require "open-uri"
require "logger"
require "rake"
require "erb"
require "json"
require "rubygems"

module Everyleaf
  module EmbulkHelper
    module Tasks
      module Common
        class OptionError < StandardError; end

        include Rake::DSL

        attr_reader :options

        def initialize(options = {})
          raise "options should be a Hash, given #{options.class}: #{options} " unless options.is_a?(Hash)
          @options = options
          validate_options
        end

        def self.included(klass)
          Tasks.register(klass)
        end

        def install_tasks
          raise NotImplementedError
        end

        def validate_options
          raise OptionError, "gemspec file path is required" unless options[:gemspec]
          raise OptionError, "gemspec file '#{options[:gemspec]}' is not found" unless File.exists?(options[:gemspec])

          required_options.map(&:to_sym).each do |opt|
            raise OptionError, "#{opt} is required" unless options[opt]
          end
        end

        def logger
          ::Logger.new(STDERR)
        end

        def gemspec_path
          Pathname.new(File.expand_path(options[:gemspec]))
        end

        def root_dir
          gemspec_path.dirname
        end

        def gemfiles_dir
          root_dir.join("gemfiles")
        end

        def required_options
          [] # Implement this in subclass if needed
        end

        def embulk_tags
          @embulk_tags ||= JSON.parse(open("https://api.github.com/repos/embulk/embulk/tags").read)
        end

        def embulk_versions
          embulk_tags.map{|tag| Gem::Version.new(tag["name"][/v(.*)/, 1])}.sort
        end
      end
    end
  end
end
