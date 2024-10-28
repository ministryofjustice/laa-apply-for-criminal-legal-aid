# Newest rule definition takes precedence when there are multiple
# rule definitions for the same key.
#
# e.g. a new law came into force requiring a new rule definition, the old
# rule definition remains in place to enable recent crime applications to be
# processed and for auditing/change management purposes.

module Evidence
  module Ruleset
    class Base
      include Enumerable

      attr_reader :crime_application, :keys

      def initialize(crime_application, keys = Evidence::Ruleset::Runner::KEYS)
        @crime_application = crime_application
        @keys = keys
      end

      def rules
        raise NotImplementedError, 'Child class must implement #rules'
      end

      def all_rules
        @all_rules ||= Evidence::Rules.constants.map do |klass|
          "Evidence::Rules::#{klass}".constantize
        end
      end

      def rule_for?(key:, definitions: [])
        if definitions.size > 1
          definitions.max_by(&:timestamp)
        elsif definitions.size == 1
          definitions.first
        else
          Rails.logger.error "Key #{key} does not have a Rule definition - generate one"
          false
        end
      end

      def each(&block)
        if block
          Array.wrap(rules).each(&block)
        else
          # :nocov:
          to_enum(:each)
          # :nocov:
        end
      end

      def to_s
        self.class.name.demodulize
      end
    end
  end
end
