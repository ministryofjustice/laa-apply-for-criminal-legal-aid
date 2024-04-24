module Evidence
  class Rule
    GROUPS = %i[income outgoings capital none].freeze
    PERSONAS = %i[client partner other].freeze
    TIMESTAMP_FORMAT = '%Y%m%d%H%M%S'.freeze

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
          DateTime.strptime(match, TIMESTAMP_FORMAT)
        else
          DateTime.now
        end
      end

      def active?
        return true unless respond_to?(:archived)

        !archived
      end

      def valid?
        @@errors = [] # rubocop:disable Style/ClassVars
        @@errors << "Invalid group #{group} defined" unless GROUPS.include?(group)

        @@errors.empty?
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
      self.class.key.to_sym if self.class.respond_to?(:key)
    end

    def group
      self.class.group if self.class.respond_to?(:group)
    end

    def archived?
      self.class.archived if self.class.respond_to?(:archived)
    end

    # Generates client_predicate, partner_predicate, other_predicate
    PERSONAS.each do |persona|
      define_method :"#{persona}_predicate" do
        dsl_predicate = :"execute_#{persona}"
        if self.class.respond_to?(dsl_predicate)
          allowable!(
            result: self.class.send(dsl_predicate, crime_application),
            persona: persona
          )
        else
          # :nocov:
          false
          # :nocov:
        end
      end
    end

    # TODO: Consider replacing the hash with an LAA Struct or dedicated class
    def to_h # rubocop:disable Metrics/MethodLength
      {
        id: id,
        group: group,
        ruleset: nil,
        key: key,
        run: {
          client: {
            result: client_predicate,
            prompt: (show?(client_predicate) ? to_sentences(persona: :client) : []),
          },
          partner: {
            result: partner_predicate,
            prompt: (show?(partner_predicate) ? to_sentences(persona: :partner) : []),
          },
          other: {
            result: other_predicate,
            prompt: (show?(other_predicate) ? to_sentences(persona: :other) : []),
          },
        }
      }
    end

    private

    def allowable!(result:, persona:)
      return result if [true, false].include?(result)

      raise Errors::UnsupportedPredicate, "Predicate for `#{self.class.name}-#{persona}` must evaluate to True or False"
    end

    def show?(result)
      result == true
    end

    # Allow multiple sentences to be output per rule
    def to_sentences(persona:)
      [I18n.t("evidence.rule.#{id}.#{persona}", default: nil)].flatten.compact
    end
  end
end
