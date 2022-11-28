require 'rails_helper'

RSpec.describe Adapters::Structs::CrimeApplication do
  subject { described_class.new(datastore_application) }

  let(:datastore_application) do
    JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
  end

  describe '#applicant' do
    it 'returns the applicant struct' do
      expect(subject.applicant).to be_a(Adapters::Structs::Applicant)
    end
  end

  describe '#case' do
    it 'returns the case details struct' do
      expect(subject.case).to be_a(Adapters::Structs::CaseDetails)
    end
  end

  describe '#ioj' do
    it 'returns the interests of justice struct' do
      expect(subject.ioj).to be_a(Adapters::Structs::InterestsOfJustice)
    end
  end
end
