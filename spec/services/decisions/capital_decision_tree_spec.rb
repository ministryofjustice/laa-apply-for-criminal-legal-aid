require 'rails_helper'

RSpec.describe Decisions::CapitalDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  # let(:crime_application) do
  #   instance_double(
  #     CrimeApplication
  #   )
  # end
  #
  # before do
  #   allow(
  #     form_object
  #   ).to receive(:crime_application).and_return(crime_application)
  # end

  it_behaves_like 'a decision tree'
end
