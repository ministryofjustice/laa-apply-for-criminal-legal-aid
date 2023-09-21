require 'rails_helper'

describe Summary::Sections::LegalRepresentativeDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      client_has_partner: 'no',
      status: status,
      provider_details: provider_details
    )
  end

  let(:provider_details) { double }
  let(:status) { :submitted }

  before do
    allow(crime_application).to receive(:in_progress?).and_return(false)
    allow(provider_details).to receive_messages(legal_rep_first_name: 'first name', legal_rep_last_name: 'last name',
                                                legal_rep_telephone: '01987654321')
  end

  describe '#name' do
    it { expect(subject.name).to eq(:legal_representative_details) }
  end

  describe '#show?' do
    context 'when the application has been submitted' do
      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end

    context 'when the application is in_progress' do
      let(:status) { :in_progress }

      before do
        allow(crime_application).to receive(:in_progress?).and_return(true)
      end

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    it 'has the correct rows' do
      expect(answers.count).to eq(3)

      expect(answers[0]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[0].question).to eq(:legal_rep_first_name)
      expect(answers[0].value).to eq('first name')

      expect(answers[1]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[1].question).to eq(:legal_rep_last_name)
      expect(answers[1].value).to eq('last name')

      expect(answers[2]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[2].question).to eq(:legal_rep_telephone)
      expect(answers[2].value).to eq('01987654321')
    end
  end
end
