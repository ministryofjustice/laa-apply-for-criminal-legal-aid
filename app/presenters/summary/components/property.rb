module Summary
  module Components
    class Property < BaseRecord
      alias property record

      private

      def answers # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        [
          Components::FreeTextAnswer.new(
            :house_type, property.house_type
          ),
          Components::FreeTextAnswer.new(
            :bedrooms, property.bedrooms.to_s
          ),
          Components::MoneyAnswer.new(
            :value, property.value
          ),
          Components::MoneyAnswer.new(
            :outstanding_mortgage, property.outstanding_mortgage
          ),
          Components::PercentageAnswer.new(
            :percentage_applicant_owned, property.percentage_applicant_owned
          ),
          Components::PercentageAnswer.new(
            :percentage_partner_owned, property.percentage_partner_owned
          ),
          Components::ValueAnswer.new(
            :is_home_address, property.is_home_address
          ),
          Components::ValueAnswer.new(
            :has_other_owners, property.has_other_owners
          ),
        ]
      end

      def name
        I18n.t(property.property_type, scope: [:summary, :sections, :property])
      end

      def change_path
        edit_steps_capital_residential_property_path(id: record.crime_application_id, property_id: record.id)
      end

      def remove_path
        confirm_destroy_steps_capital_properties_path(id: record.crime_application_id, property_id: record.id)
      end
    end
  end
end
