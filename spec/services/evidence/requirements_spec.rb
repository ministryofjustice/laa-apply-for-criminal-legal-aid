require 'rails_helper'

RSpec.describe Evidence::Requirements do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication, applicant:) }

  let(:applicant) do
    instance_double(
      Applicant,
      has_benefit_evidence:
    )
  end

  let(:has_benefit_evidence) { nil }

  describe '#any?' do
    before do
      # `benefits?` method is tested separated
      allow(subject).to receive(:benefits?).and_return(benefits)
    end

    context 'there are some evidence requirements' do
      let(:benefits) { true }

      it { expect(subject.any?).to be(true) }
    end

    context 'there are no evidence requirements' do
      let(:benefits) { false }

      it { expect(subject.any?).to be(false) }
    end
  end

  describe '#none?' do
    it 'returns false if `#any?` is true' do
      expect(subject).to receive(:any?).and_return(true)
      expect(subject.none?).to be(false)
    end

    it 'returns true if `#any?` is false' do
      expect(subject).to receive(:any?).and_return(false)
      expect(subject.none?).to be(true)
    end
  end

  describe '#benefits?' do
    subject { described_class.new(crime_application).benefits? }

    context 'when `applicant` ni `nil`' do
      let(:applicant) { nil }

      it { is_expected.to be(false) }
    end

    context 'when `has_benefit_evidence` is `nil`' do
      let(:has_benefit_evidence) { nil }

      it { is_expected.to be(false) }
    end

    context 'when `has_benefit_evidence` is `no`' do
      let(:has_benefit_evidence) { YesNoAnswer::NO.to_s }

      it { is_expected.to be(false) }
    end

    context 'when `has_benefit_evidence` is `yes`' do
      let(:has_benefit_evidence) { YesNoAnswer::YES.to_s }

      it { is_expected.to be(true) }
    end
  end
end
