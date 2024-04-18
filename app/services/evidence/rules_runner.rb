module Evidence
  class RulesRunner
    RULES_DIR = Rails.root.join('app/services/evidence/rules/*').freeze

    # WARNING: DO NOT DELETE EXISTING KEYS, ADD NEW INSTEAD
    # Controls which rules are executed for a fresh CrimeApplication
    # Determines order of output on the Evidence Upload page
    KEYS = %i[
      national_insurance_32
    ].freeze

    attr_reader :crime_application

    def initialize(crime_application)
      @crime_application = crime_application

      load_rule_definitions
      validate!
    end

    def prompt
      @prompt ||= Prompt.new(crime_application, ruleset)
    end

    # If the crime application was already submitted, then
    # re-use the ruleset it was originally submitted under to ensure
    # consistency on submission/return of an application
    def ruleset
      @ruleset ||=
        if crime_application.resubmission? && !crime_application.evidence_ruleset.empty?
          merged_ruleset
        else
          latest_ruleset
        end
    end

    def all_rules
      @all_rules ||= Evidence::Rules.constants.map do |klass|
        "Evidence::Rules::#{klass}".constantize
      end
    end

    private

    def load_rule_definitions
      Dir.glob(RULES_DIR).each { |file| load file }
    end

    def validate!
      ruleset.each do |rule|
        raise ArgumentError, "Rule #{rule} is not valid" unless rule.valid?
      end
    end

    # Newest rule definition takes precedence when there are multiple
    # rule definitions for the same key.
    #
    # e.g. a new law came into force requiring a new rule definition, the old
    # rule definition remains in place to enable recent crime applications to be
    # processed and for auditing/change management purposes.
    def rule_for?(key:, definitions: [])
      if definitions.size > 1
        definitions.max_by(&:timestamp)
      elsif definitions.size == 1
        definitions.first
      else
        Rails.logger.warn "Key #{key} does not have a Rule definition - generate one"
        nil
      end
    end

    def latest_ruleset
      @latest_ruleset ||= KEYS.filter_map do |key|
        definitions = all_rules.select { |rule| rule.active? && rule.for?(key) }

        rule_for?(key:, definitions:)
      end
    end

    # If a CrimeApplication uses its persisted ruleset as the source then
    # still need to ensure all KEYS have an implementation, otherwise a returned
    # application will only have a subset of rules run. merged_ruleset differs
    # from latest_ruleset as archived rules are still executable. Note fallback.
    def merged_ruleset
      @merged_ruleset ||= KEYS.filter_map do |key|
        definition = executed_ruleset.find { |rule| rule.for?(key) }

        # Fallback to current rule definition
        definition || rule_for?(key: key, definitions: all_rules.select { |rule| rule.active? && rule.for?(key) })
      end
    end

    def executed_ruleset
      @executed_ruleset ||= crime_application.evidence_ruleset.filter_map do |klass|
        definition = all_rules.find { |rule| rule.name == klass.to_s }

        unless definition
          Rails.logger.error("Rule definition for persisted ruleset #{klass} not found - has it been deleted?")
        end

        definition
      end
    end
  end
end
