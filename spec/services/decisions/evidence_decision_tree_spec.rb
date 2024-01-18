require 'rails_helper'

RSpec.describe Decisions::EvidenceDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 'uuid',
    )
  end

  let(:form_object) { double('FormObject') }

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `upload`' do
    let(:step_name) { :upload_finished }

    it 'directs to additional information' do
      expect(subject).to have_destination(:additional_information, :edit, id: crime_application)
    end

    context 'when additional information feature flag is disabled' do
      before do
        allow(FeatureFlags).to receive(:additional_information) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: false)
        }
      end

      it 'directs to submission review' do
        expect(subject).to have_destination(
          '/steps/submission/review', :edit, id: crime_application
        )
      end
    end
  end

  context 'when the step is `additional_information`' do
    let(:step_name) { :additional_information }

    it 'directs to `submission/review`' do
      expect(subject).to have_destination(
        '/steps/submission/review', :edit, id: crime_application
      )
    end
  end

  context 'when the step is `delete_document`' do
    let(:step_name) { :delete_document }

    context 'directs to the upload page' do
      it { is_expected.to have_destination(:upload, :edit, id: crime_application) }
    end
  end
end
