module Summary
  module Components
    class Property < BaseRecord # rubocop:disable Metrics/ClassLength
      alias property record

      PROPERTY_TYPE_MAPPING = {
        PropertyType::RESIDENTIAL.to_s => {
          display_name: 'property',
          edit_path: 'edit_steps_capital_residential_property_path'
        },
        PropertyType::COMMERCIAL.to_s => {
          display_name: 'property',
          edit_path: 'edit_steps_capital_commercial_property_path'
        },
        PropertyType::LAND.to_s => {
          display_name: 'land',
          edit_path: 'edit_steps_capital_land_path'
        }
      }.freeze

      private

      def answers # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        attributes = []

        # property specific attributes starts
        if property.property_type == PropertyType::RESIDENTIAL.to_s
          attributes << [
            Components::FreeTextAnswer.new(
              :house_type, house_type, i18n_opts: {
                asset:
              }
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
                asset:
              }
            ),
            Components::FreeTextAnswer.new(
              :usage, property.usage, i18n_opts: { asset: }
            )
          ]
        end

        if property.property_type == PropertyType::COMMERCIAL.to_s
          attributes << [
            Components::FreeTextAnswer.new(
              :usage, property.usage, i18n_opts: { asset: }
            )
          ]
        end
        # property specific attributes ends

        # common property attributes start
        attributes << [
          # TODO: Temporary fix to avoid duplicate keys in summary.yml
          Components::MoneyAnswer.new(
            :property_value, property.value, i18n_opts: {
              asset:
            }
          ),
          Components::MoneyAnswer.new(
            :outstanding_mortgage, property.outstanding_mortgage, i18n_opts: {
              asset:
            }
          ),
          Components::PercentageAnswer.new(
            :percentage_applicant_owned, property.percentage_applicant_owned, i18n_opts: {
              asset:
            }
          )
        ]

        unless property.percentage_partner_owned.nil?
          attributes << Components::PercentageAnswer.new(
            :percentage_partner_owned, property.percentage_partner_owned, i18n_opts: {
              asset:
            }
          )
        end

        unless property.is_home_address.nil?
          attributes << Components::ValueAnswer.new(
            :is_home_address, property.is_home_address, i18n_opts: {
              asset:
            }
          )
        end

        if (property.is_home_address != YesNoAnswer::YES.to_s) && property.address&.values.present?
          attributes << Components::FreeTextAnswer.new(
            :address, full_address(property.address), i18n_opts: {
              asset:
            }
          )
        end

        attributes << Components::ValueAnswer.new(:has_other_owners, property.has_other_owners, i18n_opts: {
                                                    asset:
                                                  })

        property.property_owners.each_with_index do |owner, index|
          attributes << Components::FreeTextAnswer.new(
            :name, owner.name, i18n_opts: { index: (index + 1).ordinalize_fully }
          )
          attributes << Components::FreeTextAnswer.new(
            :relationship, relationship(owner)
          )
          attributes << Components::PercentageAnswer.new(
            :percentage_owned, owner.percentage_owned, i18n_opts: {
              asset:
            }
          )
        end
        # common property attributes end
        attributes.flatten!
      end

      def name
        I18n.t(property.property_type, scope: [:summary, :sections, :property])
      end

      def asset
        PROPERTY_TYPE_MAPPING[property.property_type][:display_name]
      end

      def house_type
        if property.house_type == ::Property::OTHER_HOUSE_TYPE
          property.other_house_type
        else
          I18n.t(property.house_type, scope: [:summary, :sections, :property, :house_type])
        end
      end

      def relationship(owner)
        if owner.relationship == ::PropertyOwner::OTHER_RELATIONSHIP
          owner.other_relationship
        else
          I18n.t(owner.relationship, scope: [:summary, :sections, :property_owners, :relationship])
        end
      end

      def full_address(address)
        return unless address

        address.values_at(*Address::ADDRESS_ATTRIBUTES.map(&:to_s)).compact_blank.join("\r\n")
      end

      def change_path
        send(PROPERTY_TYPE_MAPPING[property.property_type][:edit_path],
             id: record.crime_application_id,
             property_id: record.id)
      end

      def summary_path
        edit_steps_capital_properties_summary_path(id: record.crime_application_id)
      end

      def remove_path
        confirm_destroy_steps_capital_properties_path(id: record.crime_application_id, property_id: record.id)
      end
    end
  end
end
