require 'rails_helper'

RSpec.describe Adapters::Structs::PrunedApplication do
  subject { build_struct_application(fixture_name: 'pruned_application') }

  describe '#applicant' do
    it 'returns the applicant struct' do
      expect(subject.applicant).to be_a(Adapters::Structs::Applicant)
    end
  end

  # Just a sanity check to ensure we are using the correct fixture
  describe '#case_details' do
    it 'has no case details' do
      expect { subject.case_details }.to raise_error(NoMethodError)
    end
  end
end
