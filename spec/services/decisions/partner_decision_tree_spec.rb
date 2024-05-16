require 'rails_helper'

RSpec.describe Decisions::PartnerDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) { instance_double(CrimeApplication, applicant: applicant, case: kase) }
  let(:applicant) { instance_double(Applicant) }
  let(:kase) { instance_double(Case, case_type:) }
end
