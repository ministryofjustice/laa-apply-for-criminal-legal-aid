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

  describe '#show' do
    let(:documents) { [] }

    it { expect(subject.show?).to be true }
  end

  describe '#change_path' do
    context 'when there are documents' do
      it { expect(subject.change_path).to be_nil }
    end

    context 'when there are no documents' do
      let(:documents) { [] }

      it { expect(subject.change_path).to eq '/applications/12345/steps/evidence/upload' }
    end
  end

  describe '#name' do
    it { expect(subject.name).to eq(:files) }
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
        expect(answers.count).to eq(1)
        expect(answers[0]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[0].question).to eq(:no_supporting_evidence)
      end
    end
  end
end
