module Steps
  module Income
    module Client
      class DeductionFieldsetForm < Steps::BaseFormObject
        attribute :id, :string
        attribute :deduction_type, :string
        attribute :amount, :pence
        attribute :frequency, :string
        attribute :details, :string
        attribute :employment_id, :string

        validate { presence_with_deduction_type :amount }
        validate { presence_with_deduction_type :frequency }

        validates :amount, numericality: { greater_than: 0 }
        validates :frequency, inclusion: { in: :frequencies }
        validates :deduction_type, presence: true, inclusion: { in: :deduction_types }

        validate :details_only_when_other?

        def deduction_types
          DeductionType.values.map(&:to_s) - ['none']
        end

        def frequencies
          PaymentFrequencyType.values.map(&:to_s)
        end

        # Needed for `#fields_for` to render the uuids as hidden fields
        def persisted?
          id.present?
        end

        def persist!
          unless persisted?
            delete
            record.employment = employment
          end

          record.save!
        end

        def employment
          crime_application.client_employments.find(employment_id)
        end

        def delete
          employment.deductions.find_by(deduction_type:)&.delete
        end

        private

        def details_only_when_other?
          if deduction_type_other? && details.blank?
            errors.add(:details, :blank)
          elsif !deduction_type_other? && details.present?
            errors.add(:details, :invalid)
          end
        end

        def presence_with_deduction_type(attribute)
          return if send(attribute).present?

          deduction_type_str = deduction_type_label
          deduction_type_str&.downcase! if deduction_type_other?
          error_type = deduction_type_other? && attribute == :amount ? :blank_alt : :blank

          errors.add(
            attribute,
            error_type,
            deduction_type: deduction_type_str,
            count: deduction_type_other? ? 2 : 1
          )
        end

        def deduction_type_other?
          deduction_type == DeductionType::OTHER.to_s
        end

        def deduction_type_label
          I18n.t(
            deduction_type,
            scope: [:helpers, :label, :steps_income_client_deductions_form, :types_options]
          )
        end
      end
    end
  end
end
