require 'rails_helper'

RSpec.describe Adapters::Structs::CrimeApplication do
  subject { build_struct_application }

  describe '#applicant' do
    it 'returns the applicant struct' do
      expect(subject.applicant).to be_a(Adapters::Structs::Applicant)
    end

    it 'sets the passporting_benefit from them means attribute' do
      expect(subject.applicant.passporting_benefit).to be true
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

  describe '#income' do
    it 'returns the income struct' do
      expect(subject.income).to be_a(Adapters::Structs::IncomeDetails)
    end
  end

  describe '#outgoings' do
    it 'returns the outgoings struct' do
      expect(subject.outgoings).to be_a(Adapters::Structs::OutgoingsDetails)
    end
  end

  describe '#capital' do
    it 'returns the capital struct' do
      expect(subject.capital).to be_a(Adapters::Structs::CapitalDetails)
    end
  end

  describe '#documents' do
    it 'returns documents' do
      expect(subject.documents).to all(be_a(Document))
    end

    it 'documents are marked as submitted' do
      doc = subject.documents.first
      expect(doc.submitted_at).to eq(subject.submitted_at)
    end
  end

  describe '#dependants' do
    it 'returns dependants' do
      expect(subject.dependants).to all(be_a(Dependant))
    end
  end
end
