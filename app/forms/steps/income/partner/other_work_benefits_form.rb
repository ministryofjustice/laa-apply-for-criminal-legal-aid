module Steps
  module Income
    module Partner
      class OtherWorkBenefitsForm < Steps::BaseFormObject
        attribute :partner_other_work_benefit_received, :value_object, source: YesNoAnswer
        attribute :amount, :pence
        attribute :frequency, :value_object, source: PaymentFrequencyType

        validates :partner_other_work_benefit_received, inclusion: { in: YesNoAnswer.values }
        validates :amount, numericality: { greater_than: 0 }, if: -> { receives_other_work_benefit? }

        def self.build(crime_application)
          payment = crime_application.income_payments.for_partner.work_benefits
          income = crime_application.income
          form = new

          form.partner_other_work_benefit_received = income.partner_other_work_benefit_received if income
          form.amount = payment.amount if payment

          form
        end

        private

        def receives_other_work_benefit?
          partner_other_work_benefit_received&.yes?
        end

        def persist!
          ::IncomePayment.transaction do
            reset!

            if receives_other_work_benefit?
              crime_application.income_payments.create!(
                payment_type: IncomePaymentType::WORK_BENEFITS.value,
                amount: amount,
                frequency: PaymentFrequencyType::ANNUALLY,
                ownership_type: OwnershipType::PARTNER.to_s
              )
            end

            update_income_attribute!
          end
        end

        def update_income_attribute!
          crime_application.income.update(
            partner_other_work_benefit_received:,
          )
        end

        def reset!
          crime_application.income_payments.for_partner.work_benefits&.destroy
        end
      end
    end
  end
end
