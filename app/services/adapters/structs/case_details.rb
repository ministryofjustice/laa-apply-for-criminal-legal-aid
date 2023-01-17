module Adapters
  module Structs
    class CaseDetails < BaseStructAdapter
      def charges
        offences.map do |struct|
          Charge.new(
            offence_name: struct.name,
            offence_dates_attributes: struct.dates.as_json(only: [:date_from, :date_to])
          )
        end
      end

      def codefendants
        super.map { |struct| Codefendant.new(struct.attributes) }
      end

      # This attribute is not included in the application JSON,
      # as can be implied from the `codefendants` collection.
      def has_codefendants
        codefendants.any? ? YesNoAnswer::YES : YesNoAnswer::NO
      end

      def serializable_hash(options = {})
        super(
          options.merge(
            methods: [:charges, :has_codefendants],
            except: [:offences]
          )
        )
      end
    end
  end
end
