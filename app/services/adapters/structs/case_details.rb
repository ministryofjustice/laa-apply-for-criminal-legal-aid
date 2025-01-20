module Adapters
  module Structs
    class CaseDetails < BaseStructAdapter
      # :nocov:
      def case_type
        return super unless super == CaseType::APPEAL_TO_CROWN_COURT_WITH_CHANGES.to_s

        CaseType::APPEAL_TO_CROWN_COURT
      end
      # :nocov:

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

      def client_other_charge
        OtherCharge.new(**super.attributes, ownership_type: OwnershipType::APPLICANT) if super
      end

      def partner_other_charge
        OtherCharge.new(**super.attributes, ownership_type: OwnershipType::PARTNER) if super
      end

      def serializable_hash(options = {})
        super(
          options.merge(
            methods: [:charges, :has_codefendants],
            # `offence_class` is the overall application class, and is
            # generated and injected by the datastore, we don't use it
            except: [:offences, :offence_class]
          )
        )
      end
    end
  end
end
