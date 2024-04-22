require 'rails_helper'

describe Summary::Sections::NationalSavingsCertificates do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      national_savings_certificates: records,
      in_progress?: true,
      capital: double,
      kase: (double case_type:),
      to_param: 12_345
    )
  end

  let(:records) { [NationalSavingsCertificate.new] }
  let(:case_type) { 'either_way' }

  describe '#list?' do
    it { expect(subject.list?).to be true }
  end

  describe '#show?' do
    context 'when there are certificates' do
      it 'shows this section' do
        expect(subject.show?).to be true
      end
    end

    context 'when there are no certificates' do
      let(:records) { [] }

      context 'when the full capital journey was shown' do
        it 'shows this section' do
          expect(subject.show?).to be true
        end
      end

      context 'when the full capital journey was not shown' do
        let(:case_type) { 'summary_only' }

        it 'does not show this section' do
          expect(subject.show?).to be false
        end
      end
    end
  end

  describe '#answers' do
    context 'when there are certificates' do
      let(:component) { instance_double(Summary::Components::NationalSavingsCertificate) }

      before do
        allow(Summary::Components::NationalSavingsCertificate).to receive(:with_collection) { component }
      end

      it 'returns the certificate component with actions' do
        expect(subject.answers).to be component

        expect(Summary::Components::NationalSavingsCertificate).to have_received(:with_collection).with(
          records, show_actions: true, show_record_actions: false
        )
      end

      context 'not in progress' do
        before do
          allow(crime_application).to receive(:in_progress?).and_return(false)
        end

        it 'returns the certificate component without actions' do
          expect(subject.answers).to be component

          expect(Summary::Components::NationalSavingsCertificate).to have_received(:with_collection).with(
            records, show_actions: false, show_record_actions: false
          )
        end
      end
    end

    context 'when there are no certificates' do
      let(:records) { [] }
      let(:answers) { subject.answers }

      context 'when full capital journey was required' do
        it 'has the correct rows' do
          change_path = 'applications/12345/steps/capital/add_national_savings_certificates'
          expect(answers.count).to eq(1)

          expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[0].question).to eq(:has_national_savings_certificate)
          expect(answers[0].change_path).to match(change_path)
          expect(answers[0].value).to eq('no')
        end
      end
    end
  end
end
