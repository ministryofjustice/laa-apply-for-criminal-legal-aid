# New crime applications should always use the Latest ruleset

module Evidence
  module Ruleset
    class Latest < Base
      def rules
        @rules ||= keys.filter_map do |key|
          definitions = all_rules.select { |rule| rule.active? && rule.for?(key) }

          rule_for?(key:, definitions:)
        end
      end
    end
  end
end
