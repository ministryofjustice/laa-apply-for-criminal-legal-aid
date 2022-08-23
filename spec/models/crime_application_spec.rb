require 'rails_helper'

RSpec.describe CrimeApplication, type: :model do
  subject { described_class.new(attributes) }
  let(:attributes) { {} }

  describe 'status enum' do
    it 'has the right values' do
      expect(
        described_class.statuses
      ).to eq(
        'initialised' => 'initialised',
        'in_progress' => 'in_progress',
        'submitted' => 'submitted',
      )
    end
  end

  it 'has an initial status value of "initialised"' do
    expect(subject.status).to eq('initialised')
  end
end
