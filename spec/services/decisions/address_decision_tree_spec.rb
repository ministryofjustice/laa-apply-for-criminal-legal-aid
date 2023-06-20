require 'rails_helper'

RSpec.describe Decisions::AddressDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) { instance_double(CrimeApplication) }

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `lookup`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :lookup }

    it { is_expected.to have_destination(:results, :edit, id: crime_application) }
  end

  context 'when the step is `results`' do
    let(:form_object) { double('FormObject', record: address_record) }
    let(:step_name) { :results }

    context 'if we come from a home address sub-journey' do
      let(:address_record) { HomeAddress.new }

      it { is_expected.to have_destination('/steps/client/contact_details', :edit, id: crime_application) }
    end

    context 'if we come from a correspondence address sub-journey' do
      let(:address_record) { CorrespondenceAddress.new }

      it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
    end
  end

  context 'when the step is `details`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :details }

    it 'runs the same logic as the `results` step' do
      expect(subject).to receive(:after_address_entered)
      subject.destination
    end
  end

  context 'when the step is `clear_address`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :clear_address }

    it 'runs the same logic as the `results` step' do
      expect(subject).to receive(:after_address_entered)
      subject.destination
    end
  end
end
