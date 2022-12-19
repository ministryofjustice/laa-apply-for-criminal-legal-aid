require 'rails_helper'

RSpec.describe Decisions::ProviderDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(nil)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `confirm_office`' do
    let(:form_object) { double('FormObject', is_current_office:) }
    let(:step_name) { :confirm_office }

    context 'and answer is `yes`' do
      let(:is_current_office) { YesNoAnswer::YES }

      it { is_expected.to have_destination('/crime_applications', :index, id: nil) }
    end

    context 'and answer is `no`' do
      let(:is_current_office) { YesNoAnswer::NO }

      it { is_expected.to have_destination(:select_office, :edit, id: nil) }
    end
  end

  context 'when the step is `select_office`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :select_office }

    context 'has correct next step' do
      it { is_expected.to have_destination('/crime_applications', :index, id: nil) }
    end
  end
end
