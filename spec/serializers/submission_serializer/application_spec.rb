require 'rails_helper'

RSpec.describe SubmissionSerializer::Application do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
    )
  end

  describe '#sections' do
  end
end
