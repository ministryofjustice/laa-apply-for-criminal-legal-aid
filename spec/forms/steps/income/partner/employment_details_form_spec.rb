require 'rails_helper'

RSpec.describe Steps::Income::Partner::EmploymentDetailsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: employment,
      job_title: job_title,
      amount: 100,
      frequency: PaymentFrequencyType::MONTHLY.to_s,
      before_or_after_tax: BeforeOrAfterTax::AFTER
    }
  end

  let(:crime_application) { CrimeApplication.new }
  let(:employment) { Employment.new(crime_application: crime_application, ownership_type: OwnershipType::PARTNER.to_s) }
  let(:job_title) { nil }

  describe '#save' do
    context 'when valid attributes are provided' do
      let(:job_title) { 'abc' }

      it 'returns true' do
        expect(form.save).to be(true)
      end
    end

    context 'when `job_title` is not provided' do
      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:job_title, :blank)).to be(true)
      end
    end

    context 'when income payment amount is not provided' do
      let(:job_title) { 'abc' }

      before {
        arguments.merge!(amount: nil)
      }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        form.save
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:amount, :not_a_number)).to be(true)
      end
    end
  end

  describe '#before_or_after_tax_options' do
    it 'returns the possible options' do
      expect(form.before_or_after_tax_options).to eq([BeforeOrAfterTax::BEFORE, BeforeOrAfterTax::AFTER])
    end
  end
end
