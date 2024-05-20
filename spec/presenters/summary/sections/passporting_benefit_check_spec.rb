require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
describe Summary::Sections::PassportingBenefitCheck do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      client_has_partner: 'no',
      confirm_dwp_result: confirm_dwp_result,
      applicant: applicant,
      application_type: ApplicationType::INITIAL,
    )
  end

  let(:applicant) do
    instance_double(
      Applicant,
      benefit_type:,
      last_jsa_appointment_date:,
      passporting_benefit:,
      has_nino:,
      nino:,
      will_enter_nino:,
      confirm_details:,
      has_benefit_evidence:,
    )
  end

  let(:benefit_type) { nil }
  let(:last_jsa_appointment_date) { nil }
  let(:has_nino) { nil }
  let(:nino) { nil }
  let(:will_enter_nino) { nil }
  let(:passporting_benefit) { nil }
  let(:confirm_details) { nil }
  let(:has_benefit_evidence) { nil }
  let(:confirm_dwp_result) { nil }

  describe '#name' do
    it { expect(subject.name).to eq(:passporting_benefit_check) }
  end

  describe '#show?' do
    context 'when there is a benefit type' do
      let(:benefit_type) { BenefitType::JSA.to_s }

      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end

    context 'when there is no benefit type' do
      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'when benefit check outcome undetermined' do
      let(:benefit_type) { BenefitType::JSA.to_s }
      let(:last_jsa_appointment_date) { Date.new(2024, 2, 21) }
      let(:has_nino) { YesNoAnswer::YES.to_s }
      let(:nino) { '123456' }
      let(:passporting_benefit) { false }
      let(:confirm_details) { YesNoAnswer::YES.to_s }
      let(:has_benefit_evidence) { YesNoAnswer::YES.to_s }
      let(:confirm_dwp_result) { YesNoAnswer::NO.to_s }

      it 'has the correct rows' do
        expect(answers.count).to eq(5)

        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:passporting_benefit)
        expect(answers[0].change_path).to match('applications/12345/steps/dwp/benefit_type')
        expect(answers[0].value).to eq('jsa')

        expect(answers[1]).to be_an_instance_of(Summary::Components::DateAnswer)
        expect(answers[1].question).to eq(:last_jsa_appointment_date)
        expect(answers[1].value).to eq(Date.new(2024, 2, 21))

        expect(answers[2]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[2].question).to eq(:passporting_benefit_check_outcome)
        expect(answers[2].value).to eq('undetermined')

        expect(answers[3]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[3].question).to eq(:confirmed_client_details)
        expect(answers[3].value).to eq('yes')

        expect(answers[4]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[4].question).to eq(:has_benefit_evidence)
        expect(answers[4].value).to eq('yes')
      end
    end

    context 'when applicant benefit has been confirmed by benefit checker' do
      let(:benefit_type) { BenefitType::JSA.to_s }
      let(:last_jsa_appointment_date) { Date.new(2024, 2, 21) }
      let(:passporting_benefit) { true }

      it 'has the correct rows' do
        expect(answers.count).to eq(3)

        expect(answers[2]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[2].question).to eq(:passporting_benefit_check_outcome)
        expect(answers[2].value).to be(true)
      end
    end

    context 'when benefit check not required' do
      let(:benefit_type) { 'none' }

      it 'has the correct rows' do
        expect(answers.count).to eq(2)

        expect(answers[1]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[1].question).to eq(:passporting_benefit_check_outcome)
        expect(answers[1].value).to eq('no_check_required')
      end
    end

    context 'when benefit checker unavailable' do
      let(:benefit_type) { BenefitType::JSA.to_s }
      let(:last_jsa_appointment_date) { Date.new(2024, 2, 21) }
      let(:has_benefit_evidence) { YesNoAnswer::YES.to_s }

      it 'has the correct rows' do
        expect(answers.count).to eq(4)

        expect(answers[2]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[2].question).to eq(:passporting_benefit_check_outcome)
        expect(answers[2].value).to eq('checker_unavailable')
      end
    end

    context 'when nino forthcoming' do
      let(:benefit_type) { BenefitType::JSA.to_s }
      let(:last_jsa_appointment_date) { Date.new(2024, 2, 21) }
      let(:has_nino) { YesNoAnswer::NO.to_s }
      let(:will_enter_nino) { YesNoAnswer::NO.to_s }

      it 'has the correct rows' do
        expect(answers.count).to eq(3)

        expect(answers[2]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[2].question).to eq(:passporting_benefit_check_outcome)
        expect(answers[2].value).to eq('no_check_no_nino')
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
