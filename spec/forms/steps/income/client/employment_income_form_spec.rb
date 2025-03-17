require 'rails_helper'

RSpec.describe Steps::Income::Client::EmploymentIncomeForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      amount:,
      before_or_after_tax:,
      frequency:,
    }
  end

  let(:crime_application) do
    CrimeApplication.new(
      partner: Partner.new,
      partner_detail: PartnerDetail.new(involvement_in_case: 'none'),
      applicant: applicant
    )
  end

  let(:applicant) { Applicant.new }
  let(:income_payment) {
    IncomePayment.new(crime_application: crime_application,
                      payment_type: IncomePaymentType::EMPLOYMENT.to_s)
  }

  let(:amount) { nil }
  let(:before_or_after_tax) { nil }
  let(:frequency) { nil }

  describe '#before_or_after_tax_options' do
    it 'returns the possible options' do
      expect(
        form.before_or_after_tax_options
      ).to eq([
                BeforeOrAfterTax::BEFORE,
                BeforeOrAfterTax::AFTER,
              ])
    end
  end

  describe '#build' do
    subject(:form) { described_class.build(crime_application) }

    let(:existing_employment_income_payment) {
      IncomePayment.new(crime_application: crime_application,
                        payment_type: IncomePaymentType::EMPLOYMENT.to_s,
                        amount: 600,
                        frequency: 'four_weeks',
                        ownership_type: 'applicant',
                        metadata: { 'before_or_after_tax' => BeforeOrAfterTax::AFTER })
    }

    before do
      allow(applicant).to receive(:income_payments).and_return(double(employment: existing_employment_income_payment))
    end

    it 'sets the form attributes from the model metadata' do
      expect(form.amount).to eq Money.new(600)
      expect(form.before_or_after_tax).to eq(BeforeOrAfterTax::AFTER)
      expect(form.frequency).to eq(PaymentFrequencyType::FOUR_WEEKLY)
    end

    context 'when the model metadata is incomplete' do
      let(:existing_employment_income_payment) {
        IncomePayment.new(crime_application: crime_application,
                          payment_type: IncomePaymentType::EMPLOYMENT.to_s,
                          amount: 455,
                          frequency: nil,
                          ownership_type: 'applicant',
                          metadata: {})
      }

      it 'successfully sets the form attributes' do
        expect(form.amount).to eq Money.new(455)
        expect(form.before_or_after_tax).to be_nil
        expect(form.frequency).to be_nil
      end
    end
  end

  describe '#save' do
    before do
      allow(crime_application.income_payments).to receive(:create!).and_return(true)
    end

    context 'when `amount` is not provided' do
      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:amount, :not_a_number)).to be(true)
      end
    end

    context 'when `before_or_after_tax` is not valid' do
      let(:before_or_after_tax) { 'foo' }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:before_or_after_tax, :inclusion)).to be(true)
      end
    end

    context 'when `frequency` is not valid' do
      let(:frequency) { 'every six weeks' }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:frequency, :inclusion)).to be(true)
      end
    end

    context 'when all attributes are valid' do
      let(:amount) { '600' }
      let(:frequency) { PaymentFrequencyType::MONTHLY.to_s }
      let(:before_or_after_tax) { BeforeOrAfterTax::AFTER }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:amount, :invalid)).to be(false)
      end

      it 'updates the income employment payment with the correct attributes' do
        expect(crime_application.income_payments).to receive(:create!).with(
          payment_type: :employment,
          amount: Money.new(60_000),
          before_or_after_tax: BeforeOrAfterTax::AFTER,
          frequency: PaymentFrequencyType::MONTHLY,
          ownership_type: OwnershipType::APPLICANT.to_s
        )

        form.save
      end
    end
  end
end
