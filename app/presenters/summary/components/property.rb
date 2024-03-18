module Summary
  module Components
    class Property < BaseRecord # rubocop:disable Metrics/ClassLength
      alias property record

      PROPERTY_MAPPING = {
        'residential' => 'property',
        'commercial' => 'property',
        'land' => 'land'
      }.freeze

      private

      def answers # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        attributes = []

        if property.property_type == PropertyType::RESIDENTIAL.to_s
          attributes << [
            Components::FreeTextAnswer.new(
              :house_type, house_type, i18n_opts: { asset: PROPERTY_MAPPING[property.property_type] }
            ),
            Components::FreeTextAnswer.new(
              :bedrooms, property.bedrooms.to_s
            )
          ]
        end

        if property.property_type == PropertyType::LAND.to_s
          attributes << [
            Components::FreeTextAnswer.new(
              :size_in_acres, "#{property.size_in_acres} acres", i18n_opts: {
                asset: PROPERTY_MAPPING[property.property_type]
              }
            ),
            Components::FreeTextAnswer.new(
              :usage, property.usage, i18n_opts: { asset: PROPERTY_MAPPING[property.property_type] }
            )
          ]
        end

        if property.property_type == PropertyType::COMMERCIAL.to_s
          attributes << [
            Components::FreeTextAnswer.new(
              :usage, property.usage, i18n_opts: { asset: PROPERTY_MAPPING[property.property_type] }
            )
          ]
        end

        attributes << [
          # TODO: Temporary fix to avoid duplicate keys in summary.yml
          Components::MoneyAnswer.new(
            :property_value, property.value, i18n_opts: { asset: PROPERTY_MAPPING[property.property_type] }
          ),
          Components::MoneyAnswer.new(
            :outstanding_mortgage, property.outstanding_mortgage, i18n_opts: {
              asset: PROPERTY_MAPPING[property.property_type]
            }
          ),
          Components::PercentageAnswer.new(
            :percentage_applicant_owned, property.percentage_applicant_owned, i18n_opts: {
              asset: PROPERTY_MAPPING[property.property_type]
            }
          )
        ]

        unless property.percentage_partner_owned.nil?
          attributes << Components::PercentageAnswer.new(
            :percentage_partner_owned, property.percentage_partner_owned, i18n_opts: {
              asset: PROPERTY_MAPPING[property.property_type]
            }
          )
        end

        attributes << Components::ValueAnswer.new(
          :is_home_address, property.is_home_address, i18n_opts: { asset: PROPERTY_MAPPING[property.property_type] }
        )

        if (property.is_home_address == YesNoAnswer::NO.to_s) && property.address&.values.present?
          attributes << Components::FreeTextAnswer.new(
            :address, full_address(property.address), i18n_opts: { asset: PROPERTY_MAPPING[property.property_type] }
          )
        end

        attributes << Components::ValueAnswer.new(:has_other_owners, property.has_other_owners, i18n_opts: {
                                                    asset: PROPERTY_MAPPING[property.property_type]
                                                  })

        property.property_owners.each_with_index do |owner, index|
          attributes << Components::FreeTextAnswer.new(
            :name, owner.name, i18n_opts: { index: (index + 1).ordinalize_fully }
          )
          attributes << Components::FreeTextAnswer.new(
            :relationship, relationship(owner)
          )
          attributes << Components::PercentageAnswer.new(
            :percentage_owned, owner.percentage_owned, i18n_opts: { asset: PROPERTY_MAPPING[property.property_type] }
          )
        end
        attributes.flatten!
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

      def change_path # rubocop:disable
        case record.property_type
        when 'residential'
          edit_steps_capital_residential_property_path(id: record.crime_application_id, property_id: record.id)
        when 'commercial'
          edit_steps_capital_commercial_property_path(id: record.crime_application_id, property_id: record.id)
        when 'land'
          edit_steps_capital_land_path(id: record.crime_application_id, property_id: record.id)
        end
      end

      def remove_path
        confirm_destroy_steps_capital_properties_path(id: record.crime_application_id, property_id: record.id)
      end
    end
  end
end
