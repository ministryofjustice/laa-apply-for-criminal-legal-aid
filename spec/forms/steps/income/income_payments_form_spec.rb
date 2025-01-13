require 'rails_helper'
# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Steps::Income::IncomePaymentsForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) do
    CrimeApplication.new(
      case: Case.new,
      income: Income.new,
      partner: partner,
      partner_detail: PartnerDetail.new(involvement_in_case: 'none'),
      applicant: Applicant.new
    )
  end

  let(:partner) { Partner.new }

  let(:allowed_types) do
    %w[maintenance private_pension state_pension interest_investment student_loan_grant
       board_from_family rent financial_support_with_access from_friends_relatives other]
  end

  let(:other_type) { 'other' }
  let(:other_type_attribute_data) { { 'amount' => 23.30, 'frequency' => 'week', 'details' => 'XYZ' } }

  let(:fieldset_form_class) { Steps::Income::IncomePaymentFieldsetForm }

  let(:existing_payment) do
    IncomePayment.create!(
      payment_type: 'rent',
      crime_application: crime_application,
      amount: '123',
      frequency: 'four_weeks',
      ownership_type: 'applicant'
    )
  end

  let(:payment_with_incorrect_ownership) do
    IncomePayment.create!(
      payment_type: 'maintenance',
      crime_application: crime_application,
      amount: '500',
      frequency: 'monthly',
      ownership_type: 'partner'
    )
  end

  let(:payments) do
    subject.crime_application.income_payments
  end

  before do
    allow(MeansStatus).to receive(:full_means_required?).and_return(true)
  end

  it_behaves_like 'a payment form', described_class, :has_no_income_payments

  context 'when record with incorrect ownership exists' do
    it 'does not include the payment type' do
      payment_with_incorrect_ownership
      expect(subject.types).not_to include(payment_with_incorrect_ownership.payment_type)
    end
  end

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
          subject.public_send(:"#{type}=", form_data.dig('steps_income_income_payments_form', type))
          subject.public_send(type.to_s)
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
              'types' => types,
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

        context 'when payment types are selected' do
          let(:types) { %w[maintenance student_loan_grant rent other] }

          it 'is invalid' do
            expect(subject).not_to be_valid
          end

          it 'has error messages' do
            expect(subject.errors.count).to be(5)
            expect(subject.errors.of_kind?('maintenance-amount', :blank)).to be(true)
            expect(subject.errors.of_kind?('maintenance-amount', :not_a_number)).to be(true)
            expect(subject.errors.of_kind?('maintenance-amount', :greater_than)).to be(true)
            expect(subject.errors.of_kind?('maintenance-frequency', :inclusion)).to be(true)
            expect(subject.errors.of_kind?('student-loan-grant-details', :invalid)).to be(true)

            # Error attributes should respond
            expect(subject.send(:'maintenance-amount')).to be_nil
          end
        end

        context 'when payment types are not selected' do
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
# rubocop:enable RSpec/MultipleMemoizedHelpers
