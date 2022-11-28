require 'rails_helper'

RSpec.describe Adapters::Structs::Applicant do
  subject { described_class.new(applicant) }

  let(:application_struct) do
    Adapters::Structs::CrimeApplication.new(
      JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
    )
  end

  let(:applicant) { application_struct.applicant }

  describe '#first_name' do
    it 'returns the applicant first name' do
      expect(subject.first_name).to eq('Kit')
    end
  end

  describe '#last_name' do
    it 'returns the applicant first name' do
      expect(subject.last_name).to eq('Pound')
    end
  end

  describe '#full_name' do
    it 'returns the applicant full name' do
      expect(subject.full_name).to eq('Kit Pound')
    end
  end

  describe '#passporting_benefit' do
    it 'returns always true for MVP' do
      expect(subject.passporting_benefit).to be(true)
    end
  end
end
