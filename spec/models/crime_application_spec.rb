require 'rails_helper'

RSpec.describe CrimeApplication, type: :model do
  subject { described_class.new(attributes) }

  let(:attributes) { {} }

  describe 'status enum' do
    it 'has the right values' do
      expect(
        described_class.statuses
      ).to eq(
        'in_progress' => 'in_progress',
      )
    end
  end

  describe '#not_means_tested?' do
    context 'when application is not means tested' do
      let(:attributes) { { is_means_tested: 'no' } }

      it 'has the right value' do
        expect(subject.not_means_tested?).to be(true)
      end
    end

    context 'when application is means tested' do
      let(:attributes) { { is_means_tested: 'yes' } }

      it 'has the right value' do
        expect(subject.not_means_tested?).to be(false)
      end
    end

    context 'when is means tested is nil' do
      let(:attributes) { { is_means_tested: nil } }

      it 'has the right value' do
        expect(subject.not_means_tested?).to be(false)
      end
    end
  end

  it 'has an initial status value of "in_progress"' do
    expect(subject.status).to eq('in_progress')
  end
end
