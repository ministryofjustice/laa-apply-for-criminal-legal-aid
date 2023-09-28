require 'rails_helper'

describe Summary::Sections::SupportingEvidence do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      documents: documents,
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

  describe '#name' do
    it { expect(subject.name).to eq(:supporting_evidence) }
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'when there is supporting evidence present' do
      it 'has the correct rows' do
        expect(answers.count).to eq(1)
        expect(answers[0]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[0].question).to eq(:supporting_evidence)
        expect(answers[0].change_path).to match('applications/12345/steps/evidence/upload')
        expect(answers[0].value).to eq('test.pdf')
      end
    end

    context 'when there is no supporting evidence' do
      let(:documents) { [] }

      it 'has the correct rows' do
        expect(answers.count).to eq(0)
      end
    end
  end
end
