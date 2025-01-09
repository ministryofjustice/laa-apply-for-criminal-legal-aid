require 'rails_helper'

RSpec.describe Steps::Outgoings::OutgoingsPaymentsForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) { CrimeApplication.new(case: Case.new, income: Income.new) }

  let(:allowed_types) do
    %w[childcare maintenance legal_aid_contribution]
  end

  let(:other_type) { 'legal_aid_contribution' }
  let(:other_type_attribute_data) { { 'amount' => 23.30, 'frequency' => 'week', 'case_reference' => 'CASE123' } }

  let(:fieldset_form_class) { Steps::Outgoings::OutgoingPaymentFieldsetForm }

  let(:payments) do
    subject.crime_application.outgoings_payments
  end

  let(:existing_payment) do
    OutgoingsPayment.create!(
      payment_type: 'legal_aid_contribution',
      crime_application: crime_application,
      amount: '123',
      frequency: 'four_weeks'
    )
  end

  it_behaves_like 'a payment form', described_class, :has_no_other_outgoings

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
          subject.public_send(type.to_s)
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
              'maintenance' => { 'amount' => nil, 'frequency' => nil },
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
              'types' => types,
              'childcare' =>  { 'amount' => '', 'frequency' => 'every week' },
              'maintenance' => { 'amount' => '3.00', 'frequency' => 'annual' },
              'legal_aid_contribution' => { 'amount' => '44', 'frequency' => 'week', 'case_reference' => 'CASE1234' },
            }
          }
        end

        context 'when outgoings payment types are selected' do
          let(:types) { %w[childcare maintenance legal_aid_contribution] }

          it 'is invalid' do
            expect(subject).not_to be_valid
          end

          it 'has error messages' do
            expect(subject.errors.count).to be(2)
            expect(subject.errors.of_kind?('childcare-amount', :blank)).to be(true)
            expect(subject.errors.of_kind?('childcare-frequency', :inclusion)).to be(true)

            # Error attributes should respond
            expect(subject.send(:'childcare-amount')).to be_nil
          end
        end

        context 'when outgoings payment types are not selected' do
          let(:types) { [] }

          it 'is invalid' do
            expect(subject).not_to be_valid
          end

          it 'has error messages' do
            expect(subject.errors.count).to be(1)
            expect(subject.errors.of_kind?('base', :none_selected)).to be(true)
          end
        end
      end
    end
  end
end
