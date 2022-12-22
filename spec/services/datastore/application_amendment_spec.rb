require 'rails_helper'

RSpec.describe Datastore::ApplicationAmendment do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
    )
  end

  before do
    allow(crime_application).to receive(:update!).and_return(true)
  end

  describe '#call' do
    it 'marks the application as `in_progress`' do
      expect(
        crime_application
      ).to receive(:update!).with(
        status: :in_progress,
        navigation_stack: [],
        submitted_at: nil,
      )

      expect(subject.call).to be(true)
    end
  end
end
