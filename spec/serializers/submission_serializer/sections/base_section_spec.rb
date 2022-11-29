require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::BaseSection do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double CrimeApplication }

  describe '#generate?' do
    before do
      allow(subject).to receive(:current_version).and_return(current_version)
    end

    context 'with a current version higher than the minimum version' do
      let(:current_version) { 1.1 }

      it 'returns true' do
        expect(subject.generate?).to be true
      end
    end

    context 'with a current version lower than the minimum version' do
      let(:current_version) { 0.9 }

      it 'returns true' do
        expect(subject.generate?).to be false
      end
    end
  end
end
