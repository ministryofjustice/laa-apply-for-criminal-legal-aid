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
        @dates.map { |date| { date: } }
      end

      # For a datastore application, this is always true
      def complete?
        true
      end
    end
  end
end
