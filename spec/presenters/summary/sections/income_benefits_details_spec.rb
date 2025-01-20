require 'rails_helper'

describe Summary::Sections::IncomeBenefitsDetails do # rubocop:disable RSpec/MultipleMemoizedHelpers
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      income: income
    )
  end

  let(:income) do
    instance_double(
      Income,
      income_above_threshold: 'yes',
      has_no_income_benefits: has_no_income_benefits,
      income_benefits: income_benefits,
    )
  end

  let(:income_benefits) { [] }
  let(:has_no_income_benefits) { nil }

  let(:child_benefit_payment) do
    instance_double(
      IncomeBenefit,
      payment_type: 'child',
      amount: 100,
      frequency: 'week',
      ownership_type: 'applicant',
    )
  end

  let(:working_or_child_tax_credit_benefit_payment) do
    instance_double(
      IncomeBenefit,
      payment_type: 'working_or_child_tax_credit',
      amount: 100,
      frequency: 'week',
      ownership_type: 'applicant',
    )
  end

  let(:incapacity_benefit_payment) do
    instance_double(
      IncomeBenefit,
      payment_type: 'incapacity',
      amount: 100,
      frequency: 'week',
      ownership_type: 'applicant',
    )
  end

  let(:industrial_injuries_disablement_benefit_payment) do
    instance_double(
      IncomeBenefit,
      payment_type: 'industrial_injuries_disablement',
      amount: 100,
      frequency: 'week',
      ownership_type: 'applicant',
    )
  end

  let(:jsa_benefit_payment) do
    instance_double(
      IncomeBenefit,
      payment_type: 'jsa',
      amount: 100,
      frequency: 'week',
      ownership_type: 'applicant',
    )
  end

  let(:other_benefit_payment) do
    instance_double(
      IncomeBenefit,
      payment_type: 'other',
      amount: 100,
      frequency: 'week',
      ownership_type: 'applicant',
      metadata: { details: 'Some details' }
    )
  end

  let(:partner_benefit_payment) do
    double(
      IncomeBenefit,
      payment_type: 'from_friends_relatives',
      amount: 19_001,
      frequency: 'month',
      ownership_type: 'partner',
    )
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe '#name' do
    it { expect(subject.name).to eq(:income_benefits_details) }
  end

  describe '#show?' do
    context 'when there is no income data' do
      let(:income) { nil }

      it 'shows this section' do
        expect(subject.show?).to be false
      end
    end

    context 'when there are income benefits' do
      let(:income_benefits) { [child_benefit_payment] }

      it 'shows this section' do
        expect(subject.show?).to be true
      end
    end

    context 'when there are no income benefits' do
      context 'when the question was shown' do
        let(:has_no_income_benefits) { 'yes' }

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
        let(:income_benefits) do
          [
            child_benefit_payment,
            working_or_child_tax_credit_benefit_payment,
            incapacity_benefit_payment,
            industrial_injuries_disablement_benefit_payment,
            jsa_benefit_payment,
            other_benefit_payment,
            partner_benefit_payment,
          ]
        end

        let(:rows) {
          [
            [
              Summary::Components::PaymentAnswer,
              'child_benefit', 100,
              '#steps-income-income-benefits-form-types-child-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'working_or_child_tax_credit_benefit', 100,
              '#steps-income-income-benefits-form-types-working-or-child-tax-credit-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'incapacity_benefit', 100,
              '#steps-income-income-benefits-form-types-incapacity-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'industrial_injuries_disablement_benefit', 100,
              '#steps-income-income-benefits-form-types-industrial-injuries-disablement-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'jsa_benefit', 100,
              '#steps-income-income-benefits-form-types-jsa-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'other_benefit', 100,
              '#steps-income-income-benefits-form-types-other-field'
            ],
            [
              Summary::Components::FreeTextAnswer,
              :other_benefit_details, 'Some details',
              '#steps-income-income-benefits-form-types-other-field'
            ]
          ]
        }

        it 'has the correct rows' do
          path = 'applications/12345/steps/income/which-benefits-client'

          expect(answers.count).to eq(rows.size)

          expect(answers[0]).to be_an_instance_of(rows[0][0])
          expect(answers[0].question).to eq(rows[0][1])
          expect(answers[0].value.amount).to eq(rows[0][2])
          expect(answers[0].value.frequency).to eq('week')
          expect(answers[0].change_path)
            .to match(path + rows[0][3])

          expect(answers[1]).to be_an_instance_of(rows[1][0])
          expect(answers[1].question).to eq(rows[1][1])
          expect(answers[1].value.amount).to eq(rows[1][2])
          expect(answers[1].value.frequency).to eq('week')
          expect(answers[1].change_path)
            .to match(path + rows[1][3])

          expect(answers[2]).to be_an_instance_of(rows[2][0])
          expect(answers[2].question).to eq(rows[2][1])
          expect(answers[2].value.amount).to eq(rows[2][2])
          expect(answers[2].value.frequency).to eq('week')
          expect(answers[2].change_path)
            .to match(path + rows[2][3])

          expect(answers[3]).to be_an_instance_of(rows[3][0])
          expect(answers[3].question).to eq(rows[3][1])
          expect(answers[3].value.amount).to eq(rows[3][2])
          expect(answers[2].value.frequency).to eq('week')
          expect(answers[3].change_path)
            .to match(path + rows[3][3])

          expect(answers[4]).to be_an_instance_of(rows[4][0])
          expect(answers[4].question).to eq(rows[4][1])
          expect(answers[4].value.amount).to eq(rows[4][2])
          expect(answers[4].value.frequency).to eq('week')
          expect(answers[4].change_path)
            .to match(path + rows[4][3])

          expect(answers[5]).to be_an_instance_of(rows[5][0])
          expect(answers[5].question).to eq(rows[5][1])
          expect(answers[5].value.amount).to eq(rows[5][2])
          expect(answers[5].value.frequency).to eq('week')
          expect(answers[5].change_path)
            .to match(path + rows[5][3])

          expect(answers[6]).to be_an_instance_of(rows[6][0])
          expect(answers[6].question).to eq(rows[6][1])
          expect(answers[5].value.metadata[:details]).to eq(rows[6][2])
          expect(answers[6].change_path)
            .to match(path + rows[6][3])
        end
      end

      context 'when some payments are reported' do
        let(:income_benefits) do
          [
            incapacity_benefit_payment,
            jsa_benefit_payment,
          ]
        end

        let(:rows) {
          [
            [
              Summary::Components::FreeTextAnswer,
              'child_benefit',
              'No',
              '#steps-income-income-benefits-form-types-child-field'
            ],
            [
              Summary::Components::FreeTextAnswer,
              'working_or_child_tax_credit_benefit',
              'No',
              '#steps-income-income-benefits-form-types-working-or-child-tax-credit-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'incapacity_benefit', 100,
              '#steps-income-income-benefits-form-types-incapacity-field'
            ],
            [
              Summary::Components::FreeTextAnswer,
              'industrial_injuries_disablement_benefit',
              'No',
              '#steps-income-income-benefits-form-types-industrial-injuries-disablement-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'jsa_benefit', 100,
              '#steps-income-income-benefits-form-types-jsa-field'
            ],
            [
              Summary::Components::FreeTextAnswer,
              'other_benefit',
              'No',
              '#steps-income-income-benefits-form-types-other-field'
            ]
          ]
        }

        it 'has the correct rows' do
          path = 'applications/12345/steps/income/which-benefits-client'

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
          expect(answers[2].value.amount).to eq(rows[2][2])
          expect(answers[2].value.frequency).to eq('week')
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
          expect(answers[4].value.frequency).to eq('week')
          expect(answers[4].change_path)
            .to match(path + rows[4][3])

          expect(answers[5]).to be_an_instance_of(rows[5][0])
          expect(answers[5].question).to eq(rows[5][1])
          expect(answers[5].value).to eq(rows[5][2])
          expect(answers[5].change_path)
            .to match(path + rows[5][3])
        end
      end

      context 'when no payments are reported' do
        let(:income_benefits) { [] }
        let(:has_no_income_benefits) { 'yes' }

        it 'has the correct rows' do
          expect(answers.count).to eq(1)

          expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[0].question).to eq(:which_benefits)
          expect(answers[0].change_path).to match('applications/12345/steps/income/which-benefits')
          expect(answers[0].value).to eq('none')
        end
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
