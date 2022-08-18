require 'rails_helper'

RSpec.describe Tasks::Ioj do
  subject { described_class.new(crime_application: crime_application) }

  let(:crime_application) { instance_double(CrimeApplication) }

  describe '#path' do
    it { expect(subject.path).to eq('') }
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to eq(false) }
  end

  describe '#can_start?' do
    it { expect(subject.can_start?).to eq(false) }
  end
end
