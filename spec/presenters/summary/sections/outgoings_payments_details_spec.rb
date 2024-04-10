require 'rails_helper'

describe Summary::Sections::OutgoingsPaymentsDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      outgoings: outgoings,
      outgoings_payments: outgoings_payments,
    )
  end

  let(:outgoings) do
    instance_double(
      Outgoings,
      housing_payment_type: 'none',
    )
  end

  let(:outgoings_payments) { [] }

  let(:childcare_outgoing) do
    instance_double(
      OutgoingsPayment,
      payment_type: 'childcare',
      amount: 200,
      frequency: 'month'
    )
  end

  let(:maintenance_outgoing) do
    instance_double(
      OutgoingsPayment,
      payment_type: 'maintenance',
      amount: 200,
      frequency: 'month'
    )
  end

  let(:legal_aid_contribution_outgoing) do
    instance_double(
      OutgoingsPayment,
      payment_type: 'legal_aid_contribution',
      amount: 200,
      frequency: 'month',
      metadata: { case_reference: '123456' }
    )
  end

  describe '#name' do
    it { expect(subject.name).to eq(:outgoings_payments_details) }
  end

  describe '#show?' do
    it 'shows this section' do
      expect(subject.show?).to be(true)
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'when there are outgoings details' do
      context 'when all outgoings are reported' do
        let(:outgoings_payments) do
          [
            childcare_outgoing,
            maintenance_outgoing,
            legal_aid_contribution_outgoing
          ]
        end

        let(:rows) {
          [
            [
              Summary::Components::PaymentAnswer,
              'childcare_outgoing', 200,
              '#steps-outgoings-outgoings-payments-form-types-childcare-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'maintenance_outgoing', 200,
              '#steps-outgoings-outgoings-payments-form-types-maintenance-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'legal_aid_contribution_outgoing', 200,
              '#steps-outgoings-outgoings-payments-form-types-legal-aid-contribution-field'
            ],
            [
              Summary::Components::FreeTextAnswer,
              :legal_aid_contribution_outgoing_details, '123456',
              '#steps-outgoings-outgoings-payments-form-types-legal-aid-contribution-field'
            ]
          ]
        }

        it 'has the correct rows' do
          path = '/applications/12345/steps/outgoings/which_payments_does_client_pay'

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
          expect(answers[2].value.metadata[:case_reference]).to eq(rows[3][2])
          expect(answers[3].change_path)
            .to match(path + rows[3][3])
        end
      end

      context 'when some outgoings are reported' do
        let(:outgoings_payments) do
          [
            maintenance_outgoing
          ]
        end

        let(:rows) {
          [
            [
              Summary::Components::FreeTextAnswer,
              'childcare_outgoing', 'Does not get',
              '#steps-outgoings-outgoings-payments-form-types-childcare-field'
            ],
            [
              Summary::Components::PaymentAnswer,
              'maintenance_outgoing', 200,
              '#steps-outgoings-outgoings-payments-form-types-maintenance-field'
            ],
            [
              Summary::Components::FreeTextAnswer,
              'legal_aid_contribution_outgoing', 'Does not get',
              '#steps-outgoings-outgoings-payments-form-types-legal-aid-contribution-field'
            ]
          ]
        }

        it 'has the correct rows' do
          path = '/applications/12345/steps/outgoings/which_payments_does_client_pay'

          expect(answers.count).to eq(rows.size)

          expect(answers[0]).to be_an_instance_of(rows[0][0])
          expect(answers[0].question).to eq(rows[0][1])
          expect(answers[0].value).to eq(rows[0][2])
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
          expect(answers[2].value).to eq(rows[2][2])
          expect(answers[2].change_path)
            .to match(path + rows[2][3])
        end
      end

      context 'when no outgoings are reported' do
        let(:outgoings_payments) { [] }

        it 'has the correct rows' do
          expect(answers.count).to eq(1)

          expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[0].question).to eq(:which_outgoings)
          expect(answers[0].change_path).to match('applications/12345/steps/outgoings/which_payments_does_client_pay')
          expect(answers[0].value).to eq('none')
        end
      end
    end
  end
end
