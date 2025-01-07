module TaskList
  class Section
    attr_reader :crime_application, :name

    def initialize(crime_application, name:, task_names:)
      @crime_application = crime_application
      @name = name
      @task_names = task_names
    end

    def tasks
      @tasks ||= task_names.map do |name|
        Tasks::BaseTask.build(name, crime_application:)
      end
    end

    private

    attr_reader :task_names
  end
end
