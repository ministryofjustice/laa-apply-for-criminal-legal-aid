require 'rails_helper'

RSpec.describe Steps::Outgoings::OutgoingPaymentFieldsetForm do
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
        case_reference: case_reference,
      }
    end

    let(:crime_application) { instance_double(CrimeApplication) }

    context 'when `legal_aid_contribution` payment type selected with case reference' do
      let(:payment_type) { 'legal_aid_contribution' }
      let(:case_reference) { 'CASE1234' }

      it { is_expected.to be_valid }
    end

    context 'when `legal_aid_contribution` payment type selected without case reference' do
      let(:payment_type) { 'legal_aid_contribution' }
      let(:case_reference) { '' }

      it { is_expected.not_to be_valid }
      it { expect(subject.errors.of_kind?(:case_reference, :blank)).to be(true) }
    end

    context 'when unsupported payment type selected and `case_reference` provided' do
      subject(:fieldset_form) { described_class.new(arguments) }

      let(:payment_type) { 'childcare' }
      let(:case_reference) { 'I tampered with the form!' }

      it { is_expected.not_to be_valid }
      it { expect(subject.errors.of_kind?(:case_reference, :invalid)).to be(true) }
    end

    context 'when unsupported payment type selected and `case_reference` not provided' do
      subject(:fieldset_form) { described_class.new(arguments) }

      let(:payment_type) { 'maintenance' }
      let(:case_reference) { '' }

      it { is_expected.to be_valid }
    end
  end
end
