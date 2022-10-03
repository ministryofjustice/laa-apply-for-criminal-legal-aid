require 'rails_helper'

RSpec.describe TaskStatus do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(
        described_class.values.map(&:to_s)
      ).to eq(%w[completed in_progress not_started unreachable not_applicable])
    end
  end

  describe '#enabled?' do
    context 'for a `completed` status' do
      let(:value) { :completed }

      it { expect(subject.enabled?).to be(true) }
    end

    context 'for an `in_progress` status' do
      let(:value) { :in_progress }

      it { expect(subject.enabled?).to be(true) }
    end

    context 'for a `not_started` status' do
      let(:value) { :not_started }

      it { expect(subject.enabled?).to be(true) }
    end

    context 'for an `unreachable` status' do
      let(:value) { :unreachable }

      it { expect(subject.enabled?).to be(false) }
    end

    context 'for a `not_applicable` status' do
      let(:value) { :not_applicable }

      it { expect(subject.enabled?).to be(false) }
    end
  end
end
