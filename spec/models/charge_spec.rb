require 'rails_helper'

RSpec.describe Charge, type: :model do
  subject { described_class.new(attributes) }

  let(:attributes) do
    { offence_name: }
  end

  let(:offence_name) { nil }

  describe '#offence' do
    context 'for a known offence' do
      let(:offence_name) { 'Common assault' }

      it { expect(subject.offence).not_to be_nil }
      it { expect(subject.offence.name).to eq(offence_name) }
    end

    context 'for an unknown offence' do
      let(:offence_name) { 'Foobar offence' }

      it { expect(subject.offence).to be_nil }
    end

    context 'for a blank offence' do
      let(:offence_name) { '' }

      it { expect(subject.offence).to be_nil }
    end
  end
end
