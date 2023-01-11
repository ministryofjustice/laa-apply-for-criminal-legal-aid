module Adapters
  module Structs
    class Charge < BaseStructAdapter
      # {
      #   "name": "Attempt robbery",
      #   "offence_class": "Class C",
      #   "dates": ["2020-05-11", "2020-08-11"]
      # }
      def initialize(offence_struct)
        @dates = offence_struct.dates

        super(
          ::Charge.new(offence_name: offence_struct.name)
        )
      end

      def offence_dates
        @dates.map { |date_from, date_to| { date_from:, date_to: } }
      end

      # For a submitted datastore application, following methods
      # are assumed to be always true (schema is enforced).
      def complete?
        true
      end

      def valid_dates?
        true
      end
    end
  end
end
