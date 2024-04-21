# If a CrimeApplication uses its saved ruleset as the source then we
# still need to ensure all KEYS have a corresponding rule definition, otherwise
# a returned application will only have a subset of rules run. Hydrated Ruleset differs
# from Latest Ruleset as archived rules are still executable. Note fallback.

module Evidence
  module Ruleset
    class Hydrated < Base
      def rules
        @rules ||= keys.filter_map do |key|
          definition = persisted.find { |rule| rule.for?(key) }

          # Fallback to current rule definition
          definition || rule_for?(key: key, definitions: all_rules.select { |rule| rule.active? && rule.for?(key) })
        end
      end

      private

      def persisted
        crime_application.evidence_ruleset.filter_map do |klass|
          definition = all_rules.find { |rule| rule.name == klass.to_s }

          unless definition
            Rails.logger.error("Rule definition for persisted ruleset #{klass} not found - has it been deleted?")
          end

          definition
        end
      end
    end
  end
end
