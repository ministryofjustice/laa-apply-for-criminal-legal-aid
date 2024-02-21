require 'rails_helper'

RSpec.describe Steps::Income::IncomePaymentsForm do
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
    %w[maintenance private_pension state_pension interest_investment student_loan_grant
       board_from_family rent financial_support_with_access from_friends_relatives other]
  end

  let(:fieldset_form_class) { Steps::Income::IncomePaymentFieldsetForm }

  let(:payments) do
    subject.crime_application.income_payments
  end

  it_behaves_like 'a payment form', described_class

  describe '#save' do
    context 'with form submission' do
      subject do
        described_class.new(
          crime_application: crime_application,
          types: form_data.dig('steps_income_income_payments_form', 'types'),
          income_payments: form_data.dig('steps_income_income_payments_form', 'income_payments'),
        )
      end

      before do
        allowed_types.each do |type|
          subject.public_send("#{type}=", form_data.dig('steps_income_income_payments_form', type))
        end

        subject.valid?
      end

      context 'with valid data' do
        let(:form_data) do
          {
            'steps_income_income_payments_form' => {
              'income_payments' => [''], # Rails nested attributes field
              'types' => %w[maintenance student_loan_grant rent other], # Selected payment checkboxes

              'maintenance' =>  { 'amount' => '56.12', 'frequency' => 'week' }, # Data for selected payment
              'private_pension' => { 'amount' => '', 'frequency' => '' },
              'state_pension' => { 'amount' => '', 'frequency' => '' },
              'interest_investment' => { 'amount' => '', 'frequency' => '' },
              'student_loan_grant' => { 'amount' => '3.00', 'frequency' => 'annual' },
              'board_from_family' => { 'amount' => '', 'frequency' => '' },
              'rent' => { 'amount' => '2', 'frequency' => 'month' },
              'financial_support_with_access' => { 'amount' => '', 'frequency' => '' },
              'from_friends_relatives' => { 'amount' => '', 'frequency' => '' },
              'other' => { 'amount' => '44', 'frequency' => 'week', 'details' => 'Side hustle' },
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
            'steps_income_income_payments_form' => {
              'income_payments' => [''],
              'types' => %w[maintenance student_loan_grant rent other],

              'maintenance' =>  { 'amount' => '', 'frequency' => 'every week' },
              'private_pension' => { 'amount' => '', 'frequency' => '' },
              'state_pension' => { 'amount' => '', 'frequency' => '' },
              'interest_investment' => { 'amount' => '', 'frequency' => '' },
              'student_loan_grant' => { 'amount' => '3.00', 'frequency' => 'annual', 'details' => 'How?' },
              'board_from_family' => { 'amount' => '', 'frequency' => '' },
              'rent' => { 'amount' => '2', 'frequency' => 'month' },
              'financial_support_with_access' => { 'amount' => '', 'frequency' => '' },
              'from_friends_relatives' => { 'amount' => '', 'frequency' => '' },
              'other' => { 'amount' => '44', 'frequency' => 'week', 'details' => 'Side hustle' },
            }
          }
        end

        it 'is invalid' do
          expect(subject).not_to be_valid
        end

        it 'has error messages' do
          expect(subject.errors.of_kind?('maintenance-amount', :not_a_number)).to be(true)
          expect(subject.errors.of_kind?('maintenance-frequency', :inclusion)).to be(true)
          expect(subject.errors.of_kind?('student-loan-grant-details', :invalid)).to be(true)

          # Error attributes should respond
          expect(subject.send(:'maintenance-amount')).to eq ''
        end
      end
    end
  end
end
