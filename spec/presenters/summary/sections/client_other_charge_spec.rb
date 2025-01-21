require 'rails_helper'

describe Summary::Sections::ClientOtherCharge do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      kase: kase,
    )
  end

  let(:kase) do
    instance_double(
      Case,
      client_other_charge_in_progress:,
      partner_other_charge_in_progress:,
      client_other_charge:
    )
  end

  let(:client_other_charge_in_progress) { nil }
  let(:partner_other_charge_in_progress) { nil }
  let(:client_other_charge) { nil }

  describe '#show?' do
    context 'when there is a case' do
      context 'and `client_other_charge_in_progress` is available' do
        let(:client_other_charge_in_progress) { 'yes' }

        it 'shows this section' do
          expect(subject.show?).to be(true)
        end
      end

      context 'and `client_other_charge_in_progress` is not available' do
        let(:client_other_charge_in_progress) { nil }

        it 'shows this section' do
          expect(subject.show?).to be(false)
        end
      end
    end

    context 'when there is no case' do
      let(:kase) { nil }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'when `client_other_charge_in_progress` is available' do
      let(:client_other_charge_in_progress) { 'yes' }

      it 'has the correct rows' do
        expect(answers.count).to eq(1)

        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:client_other_charge_in_progress)
        expect(answers[0].change_path).to match('applications/12345/steps/case/client/other-charge-in-progress')
        expect(answers[0].value).to eq('yes')
      end
    end

    context 'when `client_other_charge` is available' do
      let(:client_other_charge) do
        instance_double(
          OtherCharge,
          charge: 'Theft',
          hearing_court_name: "Cardiff Magistrates' Court",
          next_hearing_date: Date.new(2025, 1, 15)
        )
      end

      it 'has the correct rows' do
        expect(answers.count).to eq(3)

        expect(answers[0]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[0].question).to eq(:client_other_charge_charge)
        expect(answers[0].change_path).to match('applications/12345/steps/case/client/other-charge')
        expect(answers[0].value).to eq('Theft')

        expect(answers[1]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[1].question).to eq(:client_other_charge_hearing_court_name)
        expect(answers[1].change_path).to match('applications/12345/steps/case/client/other-charge')
        expect(answers[1].value).to eq("Cardiff Magistrates' Court")

        expect(answers[2]).to be_an_instance_of(Summary::Components::DateAnswer)
        expect(answers[2].question).to eq(:client_other_charge_next_hearing_date)
        expect(answers[2].change_path).to match('applications/12345/steps/case/client/other-charge')
        expect(answers[2].value).to eq(Date.new(2025, 1, 15))
      end
    end
  end

  describe '#title' do
    context 'when `partner_other_charge_in_progress` is available' do
      let(:partner_other_charge_in_progress) { 'no' }

      it { expect(subject.title).to eq('Other charges: client') }
    end

    context 'when `partner_other_charge_in_progress` is not available' do
      let(:partner_other_charge_in_progress) { nil }

      it { expect(subject.title).to eq('Other charges') }
    end
  end
end
