require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
describe Summary::Sections::IncomePaymentsDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      income: income,
    )
  end

  let(:income) do
    instance_double(
      Income,
      income_payments: income_payments,
      income_above_threshold: 'yes',
      has_no_income_payments: has_no_income_payments
    )
  end

  let(:income_payments) { [] }
  let(:has_no_income_payments) { nil }

  let(:maintenance_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'maintenance',
      amount: 300,
      frequency: 'month',
      ownership_type: 'applicant',
    )
  end

  let(:private_pension_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'private_pension',
      amount: 300,
      frequency: 'month',
      ownership_type: 'applicant',
    )
  end

  let(:state_pension_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'state_pension',
      amount: 300,
      frequency: 'month',
      ownership_type: 'applicant',
    )
  end

  let(:interest_investment_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'interest_investment',
      amount: 300,
      frequency: 'month',
      ownership_type: 'applicant',
    )
  end

  let(:student_loan_grant_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'student_loan_grant',
      amount: 300,
      frequency: 'month',
      ownership_type: 'applicant',
    )
  end

  let(:board_from_family_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'board_from_family',
      amount: 300,
      frequency: 'month',
      ownership_type: 'applicant',
    )
  end

  let(:rent_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'rent',
      amount: 300,
      frequency: 'month',
      ownership_type: 'applicant',
    )
  end

  let(:financial_support_with_access_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'financial_support_with_access',
      amount: 300,
      frequency: 'month',
      ownership_type: 'applicant',
    )
  end

  let(:from_friends_relatives_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'from_friends_relatives',
      amount: 300,
      frequency: 'month',
      ownership_type: 'applicant',
    )
  end

  let(:other_payment) do
    double(
      IncomePayment,
      payment_type: 'other',
      amount: 300,
      frequency: 'month',
      ownership_type: 'applicant',
      metadata: { details: 'Some details' },
    )
  end

  let(:partner_payment) do
    double(
      IncomePayment,
      payment_type: 'from_friends_relatives',
      amount: 19_001,
      frequency: 'month',
      ownership_type: 'partner',
    )
  end

  describe '#name' do
    it { expect(subject.name).to eq(:income_payments_details) }
  end

  describe '#show?' do
    context 'when there is no income data' do
      let(:income) { nil }

      it 'shows this section' do
        expect(subject.show?).to be false
      end
    end

    context 'when there are income payments' do
      let(:income_payments) { [maintenance_payment] }

      it 'shows this section' do
        expect(subject.show?).to be true
      end
    end

    context 'when there are no income payments' do
      context 'when the question was shown' do
        let(:has_no_income_payments) { 'yes' }

        it 'shows this section' do
          expect(subject.show?).to be true
        end
      end

      context 'when the question was not shown' do
        it 'does not show this section' do
          expect(subject.show?).to be false
        end
      end
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
            other_payment,
            partner_payment,
          ]
        end

        let(:rows) {
          [
            [
              Summary::Components::PaymentAnswer,
              'maintenance_payment', 300,
              '#steps-income-income-payments-form-types-maintenance-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'private_pension_payment', 300,
              '#steps-income-income-payments-form-types-private-pension-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'state_pension_payment', 300,
              '#steps-income-income-payments-form-types-state-pension-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'interest_investment_payment', 300,
              '#steps-income-income-payments-form-types-interest-investment-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'student_loan_grant_payment', 300,
              '#steps-income-income-payments-form-types-student-loan-grant-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'board_from_family_payment', 300,
              '#steps-income-income-payments-form-types-board-from-family-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'rent_payment', 300,
              '#steps-income-income-payments-form-types-rent-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'financial_support_with_access_payment', 300,
              '#steps-income-income-payments-form-types-financial-support-with-access-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'from_friends_relatives_payment', 300,
              '#steps-income-income-payments-form-types-from-friends-relatives-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'other_payment', 300,
              '#steps-income-income-payments-form-types-other-field'
            ],
            [
              Summary::Components::FreeTextAnswer,
              :other_payment_details, 'Some details',
              '#steps-income-income-payments-form-types-other-field'
            ]
          ]
        }

        it 'has the correct rows' do
          path = 'applications/12345/steps/income/which-payments-client'

          expect(answers.count).to eq(rows.size)

          expect(answers[0]).to be_an_instance_of(rows[0][0])
          expect(answers[0].question).to eq(rows[0][1])
          expect(answers[0].value.amount).to eq(rows[0][2])
          expect(answers[0].value.frequency).to eq('month')
          expect(answers[0].change_path)
            .to match(path + rows[0][3])

          expect(answers[1]).to be_an_instance_of(rows[1][0])
          expect(answers[1].question).to eq(rows[1][1])
          expect(answers[1].value.amount).to eq(rows[1][2])
          expect(answers[1].value.frequency).to eq('month')
          expect(answers[1].change_path)
            .to match(path + rows[1][3])

          expect(answers[2]).to be_an_instance_of(rows[2][0])
          expect(answers[2].question).to eq(rows[2][1])
          expect(answers[2].value.amount).to eq(rows[2][2])
          expect(answers[2].value.frequency).to eq('month')
          expect(answers[2].change_path)
            .to match(path + rows[2][3])

          expect(answers[3]).to be_an_instance_of(rows[3][0])
          expect(answers[3].question).to eq(rows[3][1])
          expect(answers[3].value.amount).to eq(rows[3][2])
          expect(answers[3].value.frequency).to eq('month')
          expect(answers[3].change_path)
            .to match(path + rows[3][3])

          expect(answers[4]).to be_an_instance_of(rows[4][0])
          expect(answers[4].question).to eq(rows[4][1])
          expect(answers[4].value.amount).to eq(rows[4][2])
          expect(answers[4].value.frequency).to eq('month')
          expect(answers[4].change_path)
            .to match(path + rows[4][3])

          expect(answers[5]).to be_an_instance_of(rows[5][0])
          expect(answers[5].question).to eq(rows[5][1])
          expect(answers[5].value.amount).to eq(rows[5][2])
          expect(answers[5].value.frequency).to eq('month')
          expect(answers[5].change_path)
            .to match(path + rows[5][3])

          expect(answers[6]).to be_an_instance_of(rows[6][0])
          expect(answers[6].question).to eq(rows[6][1])
          expect(answers[6].value.amount).to eq(rows[6][2])
          expect(answers[6].value.frequency).to eq('month')
          expect(answers[6].change_path)
            .to match(path + rows[6][3])

          expect(answers[7]).to be_an_instance_of(rows[7][0])
          expect(answers[7].question).to eq(rows[7][1])
          expect(answers[7].value.amount).to eq(rows[7][2])
          expect(answers[7].value.frequency).to eq('month')
          expect(answers[7].change_path)
            .to match(path + rows[7][3])

          expect(answers[8]).to be_an_instance_of(rows[8][0])
          expect(answers[8].question).to eq(rows[8][1])
          expect(answers[8].value.amount).to eq(rows[8][2])
          expect(answers[8].value.frequency).to eq('month')
          expect(answers[8].change_path)
            .to match(path + rows[8][3])

          expect(answers[9]).to be_an_instance_of(rows[9][0])
          expect(answers[9].question).to eq(rows[9][1])
          expect(answers[9].value.amount).to eq(rows[9][2])
          expect(answers[9].value.frequency).to eq('month')
          expect(answers[9].change_path)
            .to match(path + rows[9][3])

          expect(answers[10]).to be_an_instance_of(rows[10][0])
          expect(answers[10].question).to eq(rows[10][1])
          expect(answers[9].value.metadata[:details]).to eq(rows[10][2])
          expect(answers[10].change_path)
            .to match(path + rows[10][3])
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
              Summary::Components::FreeTextAnswer,
              'maintenance_payment', 'No',
              '#steps-income-income-payments-form-types-maintenance-field'
            ],
            [
              Summary::Components::FreeTextAnswer,
              'private_pension_payment', 'No',
              '#steps-income-income-payments-form-types-private-pension-field'
            ],
            [
              Summary::Components::FreeTextAnswer,
              'state_pension_payment', 'No',
              '#steps-income-income-payments-form-types-state-pension-field'
            ],
            [
              Summary::Components::FreeTextAnswer,
              'interest_investment_payment', 'No',
              '#steps-income-income-payments-form-types-interest-investment-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'student_loan_grant_payment', 300,
              '#steps-income-income-payments-form-types-student-loan-grant-field'
            ],
            [
              Summary::Components::FreeTextAnswer,
              'board_from_family_payment', 'No',
              '#steps-income-income-payments-form-types-board-from-family-field'
            ],
            [
              Summary::Components::FreeTextAnswer,
              'rent_payment', 'No',
              '#steps-income-income-payments-form-types-rent-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'financial_support_with_access_payment', 300,
              '#steps-income-income-payments-form-types-financial-support-with-access-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'from_friends_relatives_payment', 300,
              '#steps-income-income-payments-form-types-from-friends-relatives-field'
            ],
            [
              Summary::Components::FreeTextAnswer,
              'other_payment', 'No',
              '#steps-income-income-payments-form-types-other-field'
            ]
          ]
        }

        it 'has the correct rows' do
          path = 'applications/12345/steps/income/which-payments-client'

          expect(answers.count).to eq(rows.size)

          expect(answers[0]).to be_an_instance_of(rows[0][0])
          expect(answers[0].question).to eq(rows[0][1])
          expect(answers[0].value).to eq(rows[0][2])
          expect(answers[0].change_path)
            .to match(path + rows[0][3])

          expect(answers[1]).to be_an_instance_of(rows[1][0])
          expect(answers[1].question).to eq(rows[1][1])
          expect(answers[1].value).to eq(rows[1][2])
          expect(answers[1].change_path)
            .to match(path + rows[1][3])

          expect(answers[2]).to be_an_instance_of(rows[2][0])
          expect(answers[2].question).to eq(rows[2][1])
          expect(answers[2].value).to eq(rows[2][2])
          expect(answers[2].change_path)
            .to match(path + rows[2][3])

          expect(answers[3]).to be_an_instance_of(rows[3][0])
          expect(answers[3].question).to eq(rows[3][1])
          expect(answers[3].value).to eq(rows[3][2])
          expect(answers[3].change_path)
            .to match(path + rows[3][3])

          expect(answers[4]).to be_an_instance_of(rows[4][0])
          expect(answers[4].question).to eq(rows[4][1])
          expect(answers[4].value.amount).to eq(rows[4][2])
          expect(answers[4].value.frequency).to eq('month')
          expect(answers[4].change_path)
            .to match(path + rows[4][3])

          expect(answers[5]).to be_an_instance_of(rows[5][0])
          expect(answers[5].question).to eq(rows[5][1])
          expect(answers[5].value).to eq(rows[5][2])
          expect(answers[5].change_path)
            .to match(path + rows[5][3])

          expect(answers[6]).to be_an_instance_of(rows[6][0])
          expect(answers[6].question).to eq(rows[6][1])
          expect(answers[6].value).to eq(rows[6][2])
          expect(answers[6].change_path)
            .to match(path + rows[6][3])

          expect(answers[7]).to be_an_instance_of(rows[7][0])
          expect(answers[7].question).to eq(rows[7][1])
          expect(answers[7].value.amount).to eq(rows[7][2])
          expect(answers[7].value.frequency).to eq('month')
          expect(answers[7].change_path)
            .to match(path + rows[7][3])

          expect(answers[8]).to be_an_instance_of(rows[8][0])
          expect(answers[8].question).to eq(rows[8][1])
          expect(answers[8].value.amount).to eq(rows[8][2])
          expect(answers[8].value.frequency).to eq('month')
          expect(answers[8].change_path)
            .to match(path + rows[8][3])

          expect(answers[9]).to be_an_instance_of(rows[9][0])
          expect(answers[9].question).to eq(rows[9][1])
          expect(answers[9].value).to eq(rows[9][2])
          expect(answers[9].change_path)
            .to match(path + rows[9][3])
        end
      end

      context 'when no payments are reported' do
        let(:income_payments) { [] }
        let(:has_no_income_payments) { 'yes' }

        it 'has the correct rows' do
          expect(answers.count).to eq(1)

          expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[0].question).to eq(:which_payments)
          expect(answers[0].change_path).to match('applications/12345/steps/income/which-payments')
          expect(answers[0].value).to eq('none')
        end
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
