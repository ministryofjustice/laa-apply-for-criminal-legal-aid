require 'rails_helper'

RSpec.describe Tasks::Declaration do
  subject { described_class.new(crime_application:) }

  let(:crime_application) do
    CrimeApplication.new(
      legal_rep_first_name:,
    )
  end

  let(:legal_rep_first_name) { nil }

  before do
    allow(crime_application).to receive(:id).and_return('12345')
  end

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/submission/declaration') }
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to be(false) }
  end

  describe '#can_start?' do
    before do
      allow(subject).to receive(:fulfilled?).with(Tasks::Review)
                                            .and_return(fulfilled)
    end

    context 'when Review has been not been fulfilled' do
      let(:fulfilled) { false }

      it { expect(subject.can_start?).to be(false) }
    end
  end

  describe '#in_progress?' do
    context 'when the `legal_rep_first_name` is nil' do
      it { expect(subject.in_progress?).to be(false) }
    end

    context 'when the `legal_rep_first_name` is blank' do
      let(:legal_rep_first_name) { '' }

      it { expect(subject.in_progress?).to be(true) }
    end

    context 'when the `legal_rep_first_name` has some value' do
      let(:legal_rep_first_name) { 'John' }

      it { expect(subject.in_progress?).to be(true) }
    end
  end

  describe '#completed?' do
    it { expect(subject.completed?).to be(false) }
  end
end
