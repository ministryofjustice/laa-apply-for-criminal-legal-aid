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

  it 'has an initial status value of "in_progress"' do
    expect(subject.status).to eq('in_progress')
  end
end
