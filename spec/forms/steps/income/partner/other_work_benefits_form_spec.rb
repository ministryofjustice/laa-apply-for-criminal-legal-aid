require 'rails_helper'

RSpec.describe Steps::Income::Partner::OtherWorkBenefitsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      partner_other_work_benefit_received:,
      amount:,
    }
  end

  let(:crime_application) do
    CrimeApplication.new(
      partner: partner,
      partner_detail: PartnerDetail.new(involved_in_case: 'no', involvement_in_case: nil),
      applicant: Applicant.new
    )
  end

  let(:partner) { Partner.new }

  let(:income) { Income.new(crime_application: crime_application, partner_employment_status: ['employed']) }
  let(:partner_income_payment) {
    IncomePayment.new(crime_application: crime_application,
                      payment_type: IncomePaymentType::WORK_BENEFITS.to_s,
                      ownership_type: OwnershipType::PARTNER.to_s)
  }

  let(:partner_other_work_benefit_received) { nil }
  let(:amount) { nil }

  before do
    allow(MeansStatus).to receive_messages(full_means_required?: true, include_partner?: true)
    allow(partner).to receive(:income_payments).and_return(double(work_benefits: partner_income_payment))
  end

  describe '#build' do
    subject(:form) { described_class.build(crime_application) }

    let(:existing_income_payment) {
      IncomePayment.new(crime_application: crime_application,
                        payment_type: IncomePaymentType::WORK_BENEFITS.to_s,
                        ownership_type: OwnershipType::PARTNER.to_s,
                        amount: 150,
                        frequency: PaymentFrequencyType::ANNUALLY.to_s)
    }

    before do
      allow(partner).to receive(:income_payments).and_return(double(work_benefits: existing_income_payment))
      income.partner_other_work_benefit_received = 'yes'
    end

    it 'sets the form attributes from the model' do
      expect(form.amount).to eq Money.new(150)
      expect(form.partner_other_work_benefit_received).to eq(YesNoAnswer::YES)
    end
  end

  describe '#save' do
    before do
      allow(crime_application.income_payments).to receive(:create!).and_return(true)
      allow(crime_application).to receive(:income).and_return(income)
    end

    context 'when `partner_other_work_benefit_received` is not provided' do
      let(:partner_other_work_benefit_received) { nil }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:partner_other_work_benefit_received, :inclusion)).to be(true)
      end
    end

    context 'when `partner_other_work_benefit_received` is `Yes`' do
      let(:partner_other_work_benefit_received) { YesNoAnswer::YES.to_s }

      context 'when `amount` is not provided' do
        it 'returns false' do
          expect(form.save).to be(false)
        end

        it 'has a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:amount, :not_a_number)).to be(true)
        end
      end

      context 'when all attributes are valid' do
        let(:amount) { '200' }

        it { is_expected.to be_valid }

        it 'passes validation' do
          expect(form.errors.of_kind?(:amount, :invalid)).to be(false)
        end

        it 'updates the income payment with the correct attributes' do
          expect(crime_application.income_payments).to receive(:create!).with(
            payment_type: :work_benefits,
            amount: Money.new(200_00),
            frequency: PaymentFrequencyType::ANNUALLY,
            ownership_type: OwnershipType::PARTNER.to_s,
          )

          form.save
        end
      end
    end

    context 'when `partner_other_work_benefit_received` is `No`' do
      let(:partner_other_work_benefit_received) { YesNoAnswer::NO.to_s }

      context 'when `amount` is not provided' do
        it 'passes validation' do
          expect(form.errors.of_kind?(:amount, :invalid)).to be(false)
        end
      end

      context 'when previous values have been recorded' do
        let(:existing_income_payment) {
          IncomePayment.new(crime_application: crime_application,
                            payment_type: IncomePaymentType::WORK_BENEFITS.to_s,
                            ownership_type: OwnershipType::PARTNER.to_s,
                            amount: 150,
                            frequency: PaymentFrequencyType::ANNUALLY.to_s)
        }

        before do
          allow(partner).to receive(:income_payments).and_return(double(work_benefits: existing_income_payment))
        end

        it 'resets the attributes before saving' do
          form.send(:before_save)
          expect(form.attributes['amount']).to be_nil
        end
      end
    end
  end
end
