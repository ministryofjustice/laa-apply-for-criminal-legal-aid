require 'rails_helper'

RSpec.describe Decisions::ClientDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  it_behaves_like 'a decision tree'

  context 'when the step is `has_partner`' do
    let(:form_object) { double('FormObject', client_has_partner: client_has_partner) }
    let(:step_name) { :has_partner }

    context 'and answer is `no`' do
      let(:client_has_partner) { YesNoAnswer::NO }
      it { is_expected.to have_destination(:details, :edit) }
    end

    context 'and answer is `yes`' do
      let(:client_has_partner) { YesNoAnswer::YES }
      it { is_expected.to have_destination('/home', :selected_yes) }
    end
  end

  context 'when the step is `details`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :details }

    it { is_expected.to have_destination('/home', :index) }
  end
end
