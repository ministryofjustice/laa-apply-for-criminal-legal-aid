module Evidence
  class RulesRunner
    RULES_DIR = Rails.root.join('app/services/evidence/rules/*').freeze

    # Controls which rules are executed for a fresh CrimeApplication
    # Determines order of output on the Evidence Upload page
    KEYS = %i[
      national_insurance_32
    ].freeze

    attr_reader :crime_application

    def initialize(crime_application)
      @crime_application = crime_application

      load_rules
      validate!
    end

    def all_rules
      @all_rules ||= Evidence::Rules.constants.map do |klass|
        "Evidence::Rules::#{klass}".constantize
      end
    end

    # Newest rule definition takes precedence when there are multiple
    # rule definitions for the same key.
    #
    # e.g. a new law came into force requiring a new rule definition, the old
    # rule definition remains in place to enable recent crime applications to be
    # processed and for auditing/change management purposes.
    def latest_rules # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      @latest_rules ||= KEYS.filter_map do |key|
        definitions = all_rules.select { |rule| rule.active? && rule.for?(key) }

        if definitions.size > 1
          definitions.max_by(&:timestamp)
        elsif definitions.size == 1
          definitions.first
        else
          Rails.logger.warn "Key #{key} does not have a Rule definition - generate one"
          nil
        end
      end
    end

    def prompt
      @prompt ||= Prompt.new(crime_application, latest_rules)
    end

    private

    def load_rules
      Dir.glob(RULES_DIR).each { |file| load file }
    end

    def validate!
      latest_rules.each do |rule|
        raise ArgumentError, "Rule #{rule} is not valid" unless rule.valid?
      end
    end
  end
end
