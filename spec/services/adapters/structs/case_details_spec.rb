require 'rails_helper'

RSpec.describe Adapters::Structs::CaseDetails do
  subject { described_class.new(case_details) }

  let(:application_struct) do
    Adapters::Structs::CrimeApplication.new(
      JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
    )
  end

  let(:case_details) { application_struct.case }

  describe '#charges' do
    it 'returns a charges collection' do
      expect(subject.charges).to all(be_an(Charge))
    end
  end

  describe '#codefendants' do
    it 'returns a codefendants collection' do
      expect(subject.codefendants).to all(be_an(Codefendant))
    end
  end

  describe '#has_codefendants' do
    context 'when there are codefendants' do
      it 'returns `yes`' do
        expect(subject.has_codefendants).to eq(YesNoAnswer::YES)
      end
    end

    context 'when there are not codefendants' do
      before do
        allow(case_details).to receive(:codefendants).and_return([])
      end

      it 'returns `no`' do
        expect(subject.has_codefendants).to eq(YesNoAnswer::NO)
      end
    end
  end
end
