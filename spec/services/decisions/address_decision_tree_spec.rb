require 'rails_helper'

RSpec.describe Decisions::AddressDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) { instance_double(CrimeApplication) }

  it_behaves_like 'a decision tree'

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)
  end

  context 'when the step is `lookup`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :lookup }

    it { is_expected.to have_destination(:results, :edit, id: crime_application) }
  end

  context 'when the step is `results`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :results }

    it { is_expected.to have_destination(:details, :edit, id: crime_application) }
  end

  context 'when the step is `details`' do
    let(:form_object) { double('FormObject', record: address_record) }
    let(:step_name) { :details }

    context 'if we come from a home address sub-journey' do
      let(:address_record) { HomeAddress.new }
      it { is_expected.to have_destination('/steps/client/contact_details', :edit, id: crime_application) }
    end

    context 'if we come from a correspondence address sub-journey' do
      let(:address_record) { CorrespondenceAddress.new }
      it { is_expected.to have_destination('/home', :index, id: crime_application) }
    end
  end
end
