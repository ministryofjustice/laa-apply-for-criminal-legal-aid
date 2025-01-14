require 'rails_helper'

RSpec.describe Steps::Income::IncomeBenefitFieldsetForm do
  it_behaves_like 'a payment fieldset form', described_class

  describe '#metadata' do
    subject { described_class.new(arguments) }

    before { subject.valid? }

    let(:arguments) do
      {
        crime_application: crime_application,
        id: '12345',
        amount: 1000,
        frequency: 'month',
        payment_type: payment_type,
        details: details,
      }
    end

    let(:crime_application) { instance_double(CrimeApplication) }

    context 'when `other` payment type selected with details' do
      let(:payment_type) { 'other' }
      let(:details) { 'Side hustle on weekends' }

      it { is_expected.to be_valid }
    end

    context 'when `other` payment type selected without details' do
      let(:payment_type) { 'other' }
      let(:details) { '' }

      it { is_expected.not_to be_valid }
      it { expect(subject.errors.of_kind?(:details, :blank)).to be(true) }
    end

    context 'when unsupported payment type selected and `details` provided' do
      subject(:fieldset_form) { described_class.new(arguments) }

      let(:payment_type) { 'incapacity' }
      let(:details) { 'I tampered with the form!' }

      it { is_expected.not_to be_valid }
      it { expect(subject.errors.of_kind?(:details, :invalid)).to be(true) }
    end

    context 'when unsupported payment type selected and `details` not provided' do
      subject(:fieldset_form) { described_class.new(arguments) }

      let(:payment_type) { 'incapacity' }
      let(:details) { '' }

      it { is_expected.to be_valid }
    end
  end
end
