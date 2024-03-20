require 'rails_helper'

RSpec.describe Steps::Outgoings::OutgoingsPaymentsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      types: allowed_types,
    }
  end

  let(:crime_application) { CrimeApplication.new(case: case_record) }
  let(:case_record) { Case.new }

  let(:allowed_types) do
    %w[childcare maintenance legal_aid_contribution]
  end

  let(:other_type) { 'legal_aid_contribution' }
  let(:other_type_attribute_data) { { 'amount' => 23.30, 'frequency' => 'week', 'case_reference' => 'CASE123' } }

  let(:fieldset_form_class) { Steps::Outgoings::OutgoingPaymentFieldsetForm }

  let(:payments) do
    subject.crime_application.outgoings_payments
  end

  it_behaves_like 'a payment form', described_class

  describe '#save' do
    context 'with form submission' do
      subject do
        described_class.new(
          crime_application: crime_application,
          types: form_data.dig('steps_outgoings_outgoings_payments_form', 'types'),
          outgoings_payments: form_data.dig('steps_outgoings_outgoings_payments_form', 'outgoings_payments'),
        )
      end

      before do
        allowed_types.each do |type|
          subject.public_send(:"#{type}=", form_data.dig('steps_outgoings_outgoings_payments_form', type))
        end

        subject.valid?
      end

      context 'with valid data' do
        let(:form_data) do
          {
            'steps_outgoings_outgoings_payments_form' => {
              'outgoings_payments' => [''], # Rails nested attributes field
              'types' => %w[childcare legal_aid_contribution], # Selected payment checkboxes

              'childcare' =>  { 'amount' => '56.12', 'frequency' => 'week' }, # Data for selected payment
              'maintenance' => { 'amount' => '', 'frequency' => '' },
              'legal_aid_contribution' => { 'amount' => '44', 'frequency' => 'week', 'case_reference' => 'CASE1234' },
            }
          }
        end

        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'with invalid data' do
        let(:form_data) do
          {
            'steps_outgoings_outgoings_payments_form' => {
              'outgoings_payments' => [''],
              'types' => %w[childcare maintenance legal_aid_contribution],

              'childcare' =>  { 'amount' => '', 'frequency' => 'every week' },
              'maintenance' => { 'amount' => '3.00', 'frequency' => 'annual' },
              'legal_aid_contribution' => { 'amount' => '44', 'frequency' => 'week', 'case_reference' => 'CASE1234' },
            }
          }
        end

        it 'is invalid' do
          expect(subject).not_to be_valid
        end

        it 'has error messages' do
          expect(subject.errors.of_kind?('childcare-amount', :not_a_number)).to be(true)
          expect(subject.errors.of_kind?('childcare-frequency', :inclusion)).to be(true)

          # Error attributes should respond
          expect(subject.send(:'childcare-amount')).to eq ''
        end
      end
    end
  end
end
