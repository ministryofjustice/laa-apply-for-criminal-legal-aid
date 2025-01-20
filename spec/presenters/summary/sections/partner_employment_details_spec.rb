require 'rails_helper'

describe Summary::Sections::PartnerEmploymentDetails do
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
      partner_employment_status:,
      partner_in_armed_forces:,
    )
  end

  let(:partner_employment_status) { ['not_working'] }
  let(:partner_in_armed_forces) { nil }

  describe '#name' do
    it { expect(subject.name).to eq(:partner_employment_details) }
  end

  describe '#show?' do
    context 'when there is an income_details' do
      context 'and the partner is included in the means assessment' do
        before { allow(MeansStatus).to receive(:include_partner?).with(crime_application).and_return(true) }

        context 'and a partner employment status is selected' do
          it 'shows this section' do
            expect(subject.show?).to be(true)
          end
        end
      end
    end

    context 'when there is no income_details' do
      let(:income) { nil }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end

    context 'when the partner is not included in the means assessment' do
      before { allow(MeansStatus).to receive(:include_partner?).with(crime_application).and_return(false) }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end

    context 'when the partner employment status is not selected' do
      let(:partner_employment_status) { nil }

      before { allow(MeansStatus).to receive(:include_partner?).with(crime_application).and_return(true) }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'when there are income details' do
      context 'and the partner is not working' do
        let(:partner_employment_status) { ['not_working'] }

        it 'has the correct rows' do
          expect(answers.count).to eq(1)
          expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[0].question).to eq(:partner_employment_status)
          expect(answers[0].change_path)
            .to match('applications/12345/steps/income/what-is-the-partners-employment-status')
          expect(answers[0].value).to eq('not_working')
        end
      end

      context 'and the partner is employed' do
        let(:partner_employment_status) { ['employed'] }
        let(:partner_in_armed_forces) { 'yes' }

        it 'has the correct rows' do
          expect(answers.count).to eq(2)
          expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[0].question).to eq(:partner_employment_status)
          expect(answers[0].change_path)
            .to match('applications/12345/steps/income/what-is-the-partners-employment-status')
          expect(answers[0].value).to eq('employed')
          expect(answers[1]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[1].question).to eq(:partner_in_armed_forces)
          expect(answers[1].change_path).to match('applications/12345/steps/income/partner/armed-forces')
          expect(answers[1].value).to eq('yes')
        end
      end
    end
  end
end
