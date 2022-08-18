module Tasks
  class BaseTask
    attr_accessor :crime_application

    def initialize(crime_application:)
      @crime_application = crime_application
    end

    def self.build(name, **kwargs)
      class_name = "Tasks::#{name.to_s.camelize}"

      if const_defined?(class_name)
        class_name.constantize.new(**kwargs)
      else
        new(**kwargs)
      end
    end

    def status
      return TaskStatus::NOT_APPLICABLE if not_applicable?
      return TaskStatus::UNREACHABLE unless can_start?

      return TaskStatus::COMPLETED if completed?
      return TaskStatus::IN_PROGRESS if in_progress?

      TaskStatus::NOT_STARTED
    end

    def path
      ''
    end

    def not_applicable?
      true
    end

    # :nocov:
    def can_start?
      raise 'implement in task subclasses'
    end

    def in_progress?
      raise 'implement in task subclasses'
    end

    def completed?
      raise 'implement in task subclasses'
    end
    # :nocov:
  end
end
