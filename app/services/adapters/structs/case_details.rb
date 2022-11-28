module Adapters
  module Structs
    class CaseDetails < BaseStructAdapter
      def charges
        offences.map { |struct| Structs::Charge.new(struct) }
      end

      # rubocop:disable Naming/PredicateName
      def has_codefendants
        codefendants.any? ? YesNoAnswer::YES : YesNoAnswer::NO
      end
      # rubocop:enable Naming/PredicateName
    end
  end
end
