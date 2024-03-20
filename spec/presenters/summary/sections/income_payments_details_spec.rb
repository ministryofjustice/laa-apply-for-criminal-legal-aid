require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
describe Summary::Sections::IncomePaymentsDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      income: income,
      income_payments: income_payments,
    )
  end

  let(:income) do
    instance_double(
      Income,
      income_above_threshold: 'yes',
    )
  end

  let(:income_payments) { [] }

  let(:maintenance_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'maintenance',
      amount: 300,
      frequency: 'month'
    )
  end

  let(:private_pension_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'private_pension',
      amount: 300,
      frequency: 'month'
    )
  end

  let(:state_pension_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'state_pension',
      amount: 300,
      frequency: 'month'
    )
  end

  let(:interest_investment_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'interest_investment',
      amount: 300,
      frequency: 'month'
    )
  end

  let(:student_loan_grant_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'student_loan_grant',
      amount: 300,
      frequency: 'month'
    )
  end

  let(:board_from_family_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'board_from_family',
      amount: 300,
      frequency: 'month'
    )
  end

  let(:rent_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'rent',
      amount: 300,
      frequency: 'month'
    )
  end

  let(:financial_support_with_access_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'financial_support_with_access',
      amount: 300,
      frequency: 'month'
    )
  end

  let(:from_friends_relatives_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'from_friends_relatives',
      amount: 300,
      frequency: 'month'
    )
  end

  let(:other_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'other',
      amount: 300,
      frequency: 'month'
    )
  end

  describe '#name' do
    it { expect(subject.name).to eq(:income_payments_details) }
  end

  describe '#show?' do
    it 'shows this section' do
      expect(subject.show?).to be(true)
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'when there are income details' do
      context 'when all payments are reported' do
        let(:income_payments) do
          [
            maintenance_payment,
            private_pension_payment,
            state_pension_payment,
            interest_investment_payment,
            student_loan_grant_payment,
            board_from_family_payment,
            rent_payment,
            financial_support_with_access_payment,
            from_friends_relatives_payment,
            other_payment
          ]
        end

        let(:rows) {
          [
            [
              'maintenance',
              '£300 every month',
              '#steps-income-income-payments-form-types-maintenance-field'
            ],
            [
              'private_pension',
              '£300 every month',
              '#steps-income-income-payments-form-types-private-pension-field'
            ],
            [
              'state_pension',
              '£300 every month',
              '#steps-income-income-payments-form-types-state-pension-field'
            ],
            [
              'interest_investment',
              '£300 every month',
              '#steps-income-income-payments-form-types-interest-investment-field'
            ],
            [
              'student_loan_grant',
              '£300 every month',
              '#steps-income-income-payments-form-types-student-loan-grant-field'
            ],
            [
              'board_from_family',
              '£300 every month',
              '#steps-income-income-payments-form-types-board-from-family-field'
            ],
            [
              'rent',
              '£300 every month',
              '#steps-income-income-payments-form-types-rent-field'
            ],
            [
              'financial_support_with_access',
              '£300 every month',
              '#steps-income-income-payments-form-types-financial-support-with-access-field'
            ],
            [
              'from_friends_relatives',
              '£300 every month',
              '#steps-income-income-payments-form-types-from-friends-relatives-field'
            ],
            [
              'other',
              '£300 every month',
              '#steps-income-income-payments-form-types-other-field'
            ]
          ]
        }

        it 'has the correct rows' do
          expect(answers.count).to eq(rows.size)

          rows.each_with_index do |row, i|
            build_income_payment_row_spec(*row, i)
          end
        end
      end

      context 'when some payments are reported' do
        let(:income_payments) do
          [
            student_loan_grant_payment,
            financial_support_with_access_payment,
            from_friends_relatives_payment,
          ]
        end

        let(:rows) {
          [
            [
              'student_loan_grant',
              '£300 every month',
              '#steps-income-income-payments-form-types-student-loan-grant-field'
            ],
            [
              'financial_support_with_access',
              '£300 every month',
              '#steps-income-income-payments-form-types-financial-support-with-access-field'
            ],
            [
              'from_friends_relatives',
              '£300 every month',
              '#steps-income-income-payments-form-types-from-friends-relatives-field'
            ],
            [
              'maintenance',
              'Does not get',
              '#steps-income-income-payments-form-types-maintenance-field'
            ],
            [
              'private_pension',
              'Does not get',
              '#steps-income-income-payments-form-types-private-pension-field'
            ],
            [
              'state_pension',
              'Does not get',
              '#steps-income-income-payments-form-types-state-pension-field'
            ],
            [
              'interest_investment',
              'Does not get',
              '#steps-income-income-payments-form-types-interest-investment-field'
            ],
            [
              'board_from_family',
              'Does not get',
              '#steps-income-income-payments-form-types-board-from-family-field'
            ],
            [
              'rent',
              'Does not get',
              '#steps-income-income-payments-form-types-rent-field'
            ],
            [
              'other',
              'Does not get',
              '#steps-income-income-payments-form-types-other-field'
            ]
          ]
        }

        it 'has the correct rows' do
          expect(answers.count).to eq(rows.size)

          rows.each_with_index do |row, i|
            build_income_payment_row_spec(*row, i)
          end
        end
      end

      context 'when no payments are reported' do
        let(:income_payments) { [] }

        it 'has the correct rows' do
          expect(answers.count).to eq(1)

          expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[0].question).to eq(:which_payments)
          expect(answers[0].change_path).to match('applications/12345/steps/income/which_payments_does_client_get')
          expect(answers[0].value).to eq('none')
        end
      end
    end
  end

  def build_income_payment_row_spec(payment, text, anchor, index) # rubocop:disable Metrics/AbcSize
    full_path = "applications/12345/steps/income/which_payments_does_client_get#{anchor}"
    expect(answers[index]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
    expect(answers[index].question).to eq(payment)
    expect(answers[index].change_path).to match(full_path)
    expect(answers[index].value).to eq(text)
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
