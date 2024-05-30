module Steps
  module Income
    module Client
      class EmploymentDetailsForm < Steps::BaseFormObject
        attribute :job_title
        attribute :amount, :pence
        attribute :before_or_after_tax, :value_object, source: BeforeOrAfterTax
        attribute :frequency, :string

        validates :job_title, :before_or_after_tax, presence: true
        validates :amount, numericality: {
          greater_than: 0
        }
        validates :frequency, presence: true, inclusion: { in: :frequencies }
        validates :before_or_after_tax, presence: true, inclusion: { in: :before_or_after_tax_options }

        def frequencies
          PaymentFrequencyType.values.map(&:to_s)
        end

        def before_or_after_tax_options
          BeforeOrAfterTax.values
        end

        def persist!
          record.update(attributes)
        end
      end
    end
  end
end
