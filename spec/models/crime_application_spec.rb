require 'rails_helper'

RSpec.describe CrimeApplication, type: :model do
  subject { described_class.new(attributes) }
  let(:attributes) { {} }

  it 'has an initial status value of "initialised"' do
    expect(subject.status).to match('newly_initialised')
  end
end
