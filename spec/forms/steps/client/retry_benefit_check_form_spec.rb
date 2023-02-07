require 'rails_helper'

RSpec.describe Steps::Client::RetryBenefitCheckForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, applicant:) }
  let(:applicant) { instance_double(Applicant) }

  it { expect(subject.save).to be(true) }
end
