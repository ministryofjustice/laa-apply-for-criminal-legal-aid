module Summary
  module Components
    class Property < BaseRecord
      alias property record

      private

      def answers # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        attributes =
          [
            Components::FreeTextAnswer.new(
              :house_type, house_type
            ),
            Components::FreeTextAnswer.new(
              :bedrooms, property.bedrooms.to_s
            ),
            # TODO :: Temporary fix to avoid duplicate keys in summary.yml
            Components::MoneyAnswer.new(
              :property_value, property.value
            ),
            Components::MoneyAnswer.new(
              :outstanding_mortgage, property.outstanding_mortgage
            ),
            Components::PercentageAnswer.new(
              :percentage_applicant_owned, property.percentage_applicant_owned
            )
          ]

        if property.include_partner?
          attributes << Components::PercentageAnswer.new(
            :percentage_partner_owned, property.percentage_partner_owned
          )
        end

        attributes << Components::ValueAnswer.new(:is_home_address, property.is_home_address)

        if (property.is_home_address == YesNoAnswer::NO.to_s) && property.address&.values.present?
          attributes << Components::FreeTextAnswer.new(
            :address, full_address(property.address)
          )
        end

        attributes << Components::ValueAnswer.new(:has_other_owners, property.has_other_owners)

        property.property_owners.each_with_index do |owner, index|
          attributes << Components::FreeTextAnswer.new(
            :name, owner.name, i18n_opts: { index: (index + 1).ordinalize }
          )
          attributes << Components::FreeTextAnswer.new(
            :relationship, relationship(owner)
          )
          attributes << Components::PercentageAnswer.new(
            :percentage_owned, owner.percentage_owned
          )
        end
        attributes
      end

      def name
        I18n.t(property.property_type, scope: [:summary, :sections, :property])
      end

      def house_type
        if property.house_type == ::Property::CUSTOM_HOUSE_TYPE
          property.custom_house_type
        else
          I18n.t(property.house_type, scope: [:summary, :sections, :property, :house_type])
        end
      end

      def relationship(owner)
        if owner.relationship == ::PropertyOwner::CUSTOM_RELATIONSHIP
          owner.custom_relationship
        else
          I18n.t(owner.relationship, scope: [:summary, :sections, :property_owner, :relationship])
        end
      end

      def full_address(address)
        return unless address

        address.values.compact_blank.join("\r\n")
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
