module Evidence
  class Rule
    GROUPS = %i[income outgoings capital none].freeze
    PERSONAS = %i[client partner other].freeze

    attr_reader :crime_application

    cattr_reader :errors

    class << self
      def for?(key)
        return false unless respond_to?(:key)

        self.key == key
      end

      # Look for rule's date in class filename.
      # Assume today's date as fallback
      def timestamp
        filename = Object.const_source_location(name)&.first
        match = filename.match(/(\d{14})_/)&.captures&.first

        if match
          DateTime.strptime(match, '%Y%m%d%H%M%S')
        else
          DateTime.now
        end
      end

      def active?
        return true unless respond_to?(:archived)

        !archived
      end

      def valid?
        @errors = []
        @errors << "Invalid group #{group} defined" unless GROUPS.include?(group)

        @errors.empty?
      end
    end

    def initialize(crime_application = nil)
      @crime_application = crime_application
      @errors = []

      setup if respond_to?(:setup)
    end

    # Setup code that subclasses might override, e.g., initializing data
    def setup; end

    def id
      self.class.name.demodulize
    end

    def key
      self.class.key if self.class.respond_to?(:key)
    end

    def group
      self.class.group if self.class.respond_to?(:group)
    end

    def archived?
      self.class.archived if self.class.respond_to?(:archived)
    end

    def client_predicate
      return false unless self.class.respond_to?(:execute_client)

      self.class.execute_client(crime_application)
    end

    def partner_predicate
      return false unless self.class.respond_to?(:execute_partner)

      self.class.execute_partner(crime_application)
    end

    def other_predicate
      return false unless self.class.respond_to?(:execute_other)

      self.class.execute_other(crime_application)
    end
  end
end
