require 'rails_helper'

describe Summary::Sections::PassportingBenefitCheckPartner do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      applicant: applicant,
      partner: partner
    )
  end

  let(:applicant) do
    double(
      Applicant,
      has_partner:
    )
  end

  let(:partner) do
    double(
      Partner,
      benefit_type:,
      last_jsa_appointment_date:,
      confirm_details:,
      has_benefit_evidence:
    )
  end

  let(:benefit_type) { nil }
  let(:last_jsa_appointment_date) { nil }
  let(:benefit_check_status) { nil }
  let(:confirm_details) { nil }
  let(:has_benefit_evidence) { nil }
  let(:has_partner) { 'yes' }

  before do
    allow(partner).to receive(:benefit_check_status).and_return(benefit_check_status)
    allow(applicant).to receive(:has_partner).and_return(has_partner)
  end

  describe '#name' do
    it { expect(subject.name).to eq(:passporting_benefit_check_partner) }
  end

  describe '#show?' do
    context 'when the applicant has a partner' do
      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end

    context 'when the applicant has no partner' do
      let(:has_partner) { 'no' }

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
      let(:confirm_details) { YesNoAnswer::YES.to_s }

      context 'and has benefit evidence is yes' do
        let(:has_benefit_evidence) { YesNoAnswer::YES.to_s }
        let(:benefit_check_status) { 'undetermined' }

        it 'has the correct rows' do
          expect(answers.count).to eq(5)

          expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[0].question).to eq(:passporting_benefit)
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

      context 'and has benefit evidence is no' do
        let(:has_benefit_evidence) { YesNoAnswer::NO.to_s }
        let(:benefit_check_status) { 'no_record_found' }

        it 'has the correct rows' do
          expect(answers.count).to eq(5)

          expect(answers[2]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[2].question).to eq(:passporting_benefit_check_outcome)
          expect(answers[2].value).to eq('no_record_found')

          expect(answers[4]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[4].question).to eq(:has_benefit_evidence)
          expect(answers[4].value).to eq('no')
        end
      end
    end

    context 'when applicant benefit has been confirmed by benefit checker' do
      let(:benefit_type) { BenefitType::JSA.to_s }
      let(:last_jsa_appointment_date) { Date.new(2024, 2, 21) }
      let(:benefit_check_status) { 'confirmed' }

      it 'has the correct rows' do
        expect(answers.count).to eq(3)

        expect(answers[2]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[2].question).to eq(:passporting_benefit_check_outcome)
        expect(answers[2].value).to eq('confirmed')
      end
    end

    context 'when benefit check not required' do
      let(:benefit_type) { 'none' }
      let(:benefit_check_status) { 'no_check_required' }

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
      let(:benefit_check_status) { 'checker_unavailable' }

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
      let(:benefit_check_status) { 'no_check_no_nino' }

      it 'has the correct rows' do
        expect(answers.count).to eq(3)

        expect(answers[2]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[2].question).to eq(:passporting_benefit_check_outcome)
        expect(answers[2].value).to eq('no_check_no_nino')
      end
    end

    context 'for a historical application' do
      let(:benefit_type) { BenefitType::JSA.to_s }
      let(:last_jsa_appointment_date) { Date.new(2024, 2, 21) }

      it 'has the correct rows' do
        expect(answers.count).to eq(2)
      end
    end
  end
end
