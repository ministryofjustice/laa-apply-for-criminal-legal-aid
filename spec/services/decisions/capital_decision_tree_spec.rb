require 'rails_helper'

RSpec.describe Decisions::CapitalDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 'uuid',
      capital: capital
    )
  end

  let(:capital) { instance_double(Capital) }

  before do
    allow(form_object).to receive_messages(crime_application:)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `savings_summary`' do
    let(:step_name) { :savings_summary }
    let(:saving) { 'new_saving' }

    before do
      allow(form_object).to receive_messages(crime_application:, add_saving:)
    end

    context 'the client has selected yes to adding a savings account' do
      let(:add_saving) { YesNoAnswer::YES }

      it 'redirects the edit `saving type` page' do
        expect(subject).to have_destination(:saving_type, :edit, id: crime_application)
      end
    end
  end

  context 'when the step is `property_type`' do
    let(:form_object) { double('FormObject', property:) }
    let(:step_name) { :property_type }

    context 'the client has no properties' do
      let(:property) { nil }

      it 'redirects to select saving type' do
        expect(subject).to have_destination(:saving_type, :edit, id: crime_application)
      end
    end

    context 'the client has selected a property type' do
      let(:property) { instance_double(Property) }

      it 'redirects the edit `properties` page' do
        expect(subject).to have_destination(:properties, :edit, id: crime_application, property_id: property)
      end
    end
  end

  context 'when the step is `properties`' do
    let(:form_object) { double('FormObject', property:) }
    let(:step_name) { :properties }
    let(:property) { instance_double(Property) }

    context 'the client has selected a property type' do
      let(:property) { instance_double(Property) }

      it 'redirects the edit `saving_type` page' do
        expect(subject).to have_destination(:saving_type, :edit, id: crime_application)
      end
    end
  end

  context 'when the step is `saving_type`' do
    let(:form_object) { double('FormObject', saving:) }
    let(:step_name) { :saving_type }

    context 'the client has no savings' do
      let(:saving) { nil }

      it 'redirects premium bonds' do
        expect(subject).to have_destination(:premium_bonds, :edit, id: crime_application)
      end
    end

    context 'the client has selected a saving type' do
      let(:saving) { 'new_saving' }

      it 'redirects the edit `savings` page' do
        expect(subject).to have_destination(:savings, :edit, id: crime_application, saving_id: saving)
      end
    end
  end

  context 'when the step is `savings`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :savings }

    context 'has correct next step' do
      it { is_expected.to have_destination(:premium_bonds, :edit, id: crime_application) }
    end
  end

  context 'when the step is `premium_bonds`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :premium_bonds }

    context 'has correct next step' do
      it { is_expected.to have_destination('/steps/case/urn', :edit, id: crime_application) }
    end
  end
end
