require 'rails_helper'

RSpec.describe Decisions::EvidenceDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 'uuid',
    )
  end

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `upload`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :upload_finished }

    it { is_expected.to have_destination('/steps/submission/more_information', :edit, id: crime_application) }
  end

  context 'when the step is `delete_document`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :delete_document }

    context 'redirects to the upload page' do
      it { is_expected.to have_destination(:upload, :edit, id: crime_application) }
    end
  end
end
