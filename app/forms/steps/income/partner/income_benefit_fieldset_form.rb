module Steps
  module Income
    module Partner
      class IncomeBenefitFieldsetForm < Steps::BaseFormObject
        include Steps::PaymentFieldsetValidation

        attribute :id, :string
        attribute :payment_type, :string
        attribute :amount, :pence
        attribute :frequency, :string
        attribute :details, :string

        validate :validate_amount
        validate :validate_frequency
        validates :payment_types, presence: true, inclusion: { in: :payment_types }
        validate :details_only_when_other?

        # Needed for `#fields_for` to render the uuids as hidden fields
        def persisted?
          id.present?
        end

        def persist!
          unless persisted?
            delete
            record.crime_application = crime_application
          end

          record.save!
        end

        def delete
          crime_application.partner.income_benefits.find_by(payment_type:)&.delete
        end

        private

        def payment_types
          IncomeBenefitType.values.map(&:to_s) - ['none']
        end

        def frequencies
          PaymentFrequencyType.values.map(&:to_s)
        end

        def details_only_when_other?
          if (payment_type == IncomeBenefitType::OTHER.to_s) && details.blank?
            errors.add(:details, :blank)
          elsif (payment_type != IncomeBenefitType::OTHER.to_s) && details.present?
            errors.add(:details, :invalid)
          end
        end

        def payment_type_label
          I18n.t(
            payment_type,
            scope: [:helpers, :label, :steps_income_income_benefits_form, :types_options]
          )&.downcase!
        end
      end
    end
  end
end
