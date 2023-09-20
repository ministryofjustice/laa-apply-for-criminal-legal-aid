require 'rails_helper'

RSpec.describe Adapters::Structs::CrimeApplication do
  subject { build_struct_application }

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

  describe '#supporting_evidence' do
    it 'returns the supporting evidence struct' do
      expect(subject.supporting_evidence).to be_a(Adapters::Structs::SupportingEvidence)
    end
  end
end
