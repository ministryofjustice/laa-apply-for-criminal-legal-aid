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

        validates :amount, numericality: {
          greater_than: 0
        }

        validates :deduction_types, presence: true, inclusion: { in: :deduction_types }
        validates :frequency, presence: true, inclusion: { in: :frequencies }

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
          crime_application.employments.find(employment_id)
        end

        def delete
          employment.deductions.find_by(deduction_type:)&.delete
        end

        private

        def details_only_when_other?
          if (deduction_type == DeductionType::OTHER.to_s) && details.blank?
            errors.add(:details, :blank)
          elsif (deduction_type != DeductionType::OTHER.to_s) && details.present?
            errors.add(:details, :invalid)
          end
        end
      end
    end
  end
end
