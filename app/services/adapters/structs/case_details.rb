module Adapters
  module Structs
    class CaseDetails < BaseStructAdapter
      def charges
        offences.map { |struct| Structs::Charge.new(struct) }
      end

      def has_codefendants
        codefendants.any? ? YesNoAnswer::YES : YesNoAnswer::NO
      end
    end
  end
end
