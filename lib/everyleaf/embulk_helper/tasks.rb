require "everyleaf/embulk_helper/tasks/common"

module Everyleaf
  module EmbulkHelper
    module Tasks
      def self.tasks
        @tasks ||= []
      end

      def self.register(task_class)
        tasks << task_class
      end

      def self.install(options = {})
        tasks.each do |task_class|
          task_class.new(options).install_tasks
        end
      end
    end
  end
end

dir = File.expand_path("../tasks", __FILE__)
Dir["#{dir}/**/*.rb"].each{|f| require f}
