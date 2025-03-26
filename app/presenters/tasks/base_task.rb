module Tasks
  class BaseTask
    include Routing

    attr_accessor :crime_application

    delegate :applicant, :ioj, to: :crime_application

    def initialize(crime_application:)
      @crime_application = crime_application
    end

    def name
      self.class.name.demodulize.underscore.to_sym
    end

    def self.build(name, **)
      class_name = "Tasks::#{name.to_s.camelize}"

      if const_defined?(class_name)
        class_name.constantize.new(**)
      else
        new(**)
      end
    end

    def fulfilled?(task_class)
      task_status = task_class.new(crime_application:).status
      task_status.not_applicable? || task_status.completed?
    end

    # Used by the `Routing` module to build the urls
    def default_url_options
      { id: crime_application }
    end

    def status
      return TaskStatus::NOT_APPLICABLE if not_applicable?
      return TaskStatus::UNREACHABLE unless can_start?
      return TaskStatus::NOT_STARTED unless in_progress?
      return TaskStatus::COMPLETED if completed?

      TaskStatus::IN_PROGRESS
    end

    def path
      ''
    end

    def not_applicable?
      !validator.applicable?
    end

    def completed?
      validator.complete?
    end

    # :nocov:
    def can_start?
      raise 'implement in task subclasses'
    end

    def in_progress?
      raise 'implement in task subclasses'
    end

    private

    def validator
      raise 'implement in task subclasses'
    end
    # :nocov:
  end
end
