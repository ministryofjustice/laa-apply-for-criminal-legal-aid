require 'rails_helper'

RSpec.describe Steps::DWP::CannotMatchDetailsForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    { crime_application: }
  end

  let(:crime_application) do
    instance_double(CrimeApplication)
  end

  describe '#save' do
    it 'does not perform any operation, it only returns true' do
      expect(subject.save).to be(true)
    end
  end
end
