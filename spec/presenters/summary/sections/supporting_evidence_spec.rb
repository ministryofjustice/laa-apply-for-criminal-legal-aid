require 'rails_helper'

describe Summary::Sections::SupportingEvidence do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      documents: documents
    )
  end

  let(:documents) do
    [instance_double(
      Document,
      filename: 'test.pdf',
      s3_object_key: '123/abcdef1234',
      content_type: 'application/pdf',
      file_size: 12,
    )]
  end

  before do
    allow(crime_application).to receive(:additional_information).and_return('Information about uploaded evidence.')
  end

  describe '#name' do
    it { expect(subject.name).to eq(:supporting_evidence) }
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    it 'has the correct rows' do
      expect(answers.count).to eq(2)
      expect(answers[0]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[0].question).to eq(:supporting_evidence)
      expect(answers[0].change_path).to match('applications/12345/steps/evidence/upload')
      expect(answers[0].value).to eq('test.pdf')
    end

    it 'includes the aditional information answer' do
      expect(answers.count).to eq(2)
      expect(answers.first.question).to eq(:supporting_evidence)

      info_answer = answers.last
      expect(info_answer.change_path).to match('applications/12345/steps/evidence/additional_information')
      expect(info_answer.value).to eq('Information about uploaded evidence.')
    end

    context 'when there is no supporting evidence' do
      let(:documents) { [] }

      it 'has the correct rows' do
        expect(answers.count).to eq(1)
      end
    end

    context 'when the `additional_information` flag is disabled' do
      before do
        allow(FeatureFlags).to receive(:additional_information) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: false)
        }
      end

      it 'has the correct rows' do
        expect(answers.count).to eq(1)
        expect(answers[0].change_path).to match('applications/12345/steps/evidence/upload')
      end
    end
  end
end
