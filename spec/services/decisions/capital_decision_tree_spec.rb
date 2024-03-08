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
    let(:form_object) { double('FormObject', saving:) }
    let(:step_name) { :savings_summary }
    let(:saving) { 'new_saving' }

    before do
      allow(form_object).to receive_messages(crime_application:, add_saving:)
    end

    context 'the client has selected yes to adding a savings account' do
      let(:add_saving) { YesNoAnswer::YES }

      it 'redirects to the edit `saving type` page' do
        expect(subject).to have_destination(:other_saving_type, :edit, id: crime_application)
      end
    end

    context 'the client has selected no to adding a savings account' do
      let(:add_saving) { YesNoAnswer::NO }

      it 'redirects to the premium bonds page' do
        expect(subject).to have_destination(:premium_bonds, :edit, id: crime_application)
      end
    end
  end

  context 'when the step is `investments_summary`' do
    let(:form_object) { double('FormObject', investment:) }
    let(:step_name) { :investments_summary }
    let(:investment) { 'new_investment' }

    before do
      allow(form_object).to receive_messages(crime_application:, add_investment:)
    end

    context 'the client has selected yes to adding a investments account' do
      let(:add_investment) { YesNoAnswer::YES }

      it 'redirects to the edit `investment type` page' do
        expect(subject).to have_destination(:other_investment_type, :edit, id: crime_application)
      end
    end

    context 'the client has selected no to adding a investments account' do
      let(:add_investment) { YesNoAnswer::NO }

      it 'redirects to the case page' do
        expect(subject).to have_destination('/steps/case/urn', :edit, id: crime_application)
      end
    end
  end

  context 'when the step is `national_savings_certificates_summary`' do
    let(:form_object) { double('FormObject', national_savings_certificate: certificate) }
    let(:step_name) { :national_savings_certificates_summary }
    let(:certificate) { 'new_national_savings_certificate' }

    before do
      allow(form_object).to receive_messages(crime_application:, add_national_savings_certificate:)
    end

    context 'the client has selected yes to adding a certificate' do
      let(:add_national_savings_certificate) { YesNoAnswer::YES }

      it 'redirects to the edit `national_savings_certificates` page' do
        expect(subject).to have_destination(
          :national_savings_certificates, :edit, id: crime_application, national_savings_certificate_id: certificate
        )
      end
    end

    context 'the client has selected no to adding a certificates' do
      let(:add_national_savings_certificate) { YesNoAnswer::NO }

      it 'redirects to the investment_type page' do
        expect(subject).to have_destination(:investment_type, :edit, id: crime_application)
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
      let(:property) { instance_double(Property, property_type: 'residential') }

      it 'redirects the edit `residential_property` page' do
        expect(subject).to have_destination(:residential_property, :edit, id: crime_application, property_id: property)
      end
    end
  end

  context 'when the step is `residential_property`' do
    let(:form_object) do
      double('FormObject', record:, is_home_address:, has_other_owners:)
    end
    let(:step_name) { :residential_property }
    let(:record) { instance_double(Property, property_owners: [property_owner]) }
    let(:property_owner) { instance_double(PropertyOwner, complete?: false) }

    context 'is_home_address and has_other_owners' do
      context 'when property address is same as home address and have no other owners' do
        let(:is_home_address) { YesNoAnswer::YES }
        let(:has_other_owners) { YesNoAnswer::NO }

        it 'redirects to `clients_assets` page' do
          expect(subject).to have_destination(:properties_summary, :edit, id: crime_application)
        end
      end

      context 'when property address is same as home address and have other owners' do
        let(:is_home_address) { YesNoAnswer::YES }
        let(:has_other_owners) { YesNoAnswer::YES }

        it 'redirects the edit `property_owners` page' do
          expect(subject).to have_destination(:property_owners, :edit, id: crime_application)
        end
      end

      context 'when property address is different from home address and have no other owners' do
        let(:is_home_address) { YesNoAnswer::NO }
        let(:has_other_owners) { YesNoAnswer::YES }

        it 'redirects the edit `property_address` page' do
          expect(subject).to have_destination(:property_address, :edit, id: crime_application)
        end
      end

      context 'when property address is different from home address and have other owners' do
        let(:is_home_address) { YesNoAnswer::NO }
        let(:has_other_owners) { YesNoAnswer::NO }

        it 'redirects the edit `property_address` page' do
          expect(subject).to have_destination(:property_address, :edit, id: crime_application)
        end
      end
    end
  end

  context 'when the step is `property_address`' do
    let(:form_object) do
      double('FormObject', record:, has_other_owners:)
    end
    let(:step_name) { :property_address }
    let(:record) { instance_double(Property, is_home_address: 'no', property_owners: [property_owner]) }
    let(:property_owner) { instance_double(PropertyOwner, complete?: false) }

    context 'when property has no other owners' do
      let(:has_other_owners) { YesNoAnswer::NO }

      it 'redirects to `clients_assets` page' do
        expect(subject).to have_destination(:properties_summary, :edit, id: crime_application)
      end
    end

    context 'when property has other owners' do
      let(:has_other_owners) { YesNoAnswer::YES }

      it 'redirects the edit `property_owners` page' do
        expect(subject).to have_destination(:property_owners, :edit, id: crime_application)
      end
    end
  end

  context 'when the step is `property_owners`' do
    let(:form_object) do
      double('FormObject', record:)
    end
    let(:step_name) { :property_owners }
    let(:record) { instance_double(Property) }

    it 'redirects to `clients_assets` page' do
      expect(subject).to have_destination(:properties_summary, :edit, id: crime_application)
    end
  end

  context 'when the step is `add_property_owner`' do
    let(:form_object) { double('FormObject', record:) }
    let(:step_name) { :add_property_owner }
    let(:record) { instance_double(Property, property_owners: [property_owner]) }
    let(:property_owner) { instance_double(PropertyOwner, name: 'abc', complete?: false) }

    it 'redirects the edit `property_owners` page' do
      expect(subject).to have_destination(:property_owners, :edit, id: crime_application)
    end
  end

  context 'when the step is `delete_property_owner`' do
    let(:form_object) { double('FormObject', record:) }
    let(:step_name) { :delete_property_owner }
    let(:record) { instance_double(Property) }

    it 'redirects the edit `property_owners` page' do
      expect(subject).to have_destination(:property_owners, :edit, id: crime_application)
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

  context 'when the step is `investment_type`' do
    let(:form_object) { double('FormObject', investment:) }
    let(:step_name) { :investment_type }

    context 'the client has no investments' do
      let(:investment) { nil }

      it 'redirects premium bonds' do
        expect(subject).to have_destination(:premium_bonds, :edit, id: crime_application)
      end
    end

    context 'the client has selected a investment type' do
      let(:investment) { 'new_investment' }

      it 'redirects the edit `investments` page' do
        expect(subject).to have_destination(:investments, :edit, id: crime_application, investment_id: investment)
      end
    end
  end

  context 'when the step is `has_national_savings_certificates`' do
    let(:form_object) { double('FormObject', national_savings_certificate: certificate) }
    let(:step_name) { :has_national_savings_certificates }
    let(:certificate) { 'new_national_savings_certificate' }

    before do
      allow(form_object).to receive_messages(crime_application:, has_national_savings_certificates:)
    end

    context 'the client has no certificates' do
      let(:has_national_savings_certificates) { YesNoAnswer::NO }

      it 'redirects investment_type' do
        expect(subject).to have_destination(:investment_type, :edit, id: crime_application)
      end
    end

    context 'the client has selected a yes' do
      let(:has_national_savings_certificates) { YesNoAnswer::YES }

      it 'redirects to the edit `national_savings_certificates` page' do
        expect(subject).to have_destination(
          :national_savings_certificates, :edit, id: crime_application, national_savings_certificate_id: certificate
        )
      end
    end
  end

  context 'when the step is `savings`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :savings }

    context 'has correct next step' do
      it { is_expected.to have_destination(:savings_summary, :edit, id: crime_application) }
    end
  end

  context 'when the step is `investments`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :investments }

    context 'has correct next step' do
      it { is_expected.to have_destination(:investments_summary, :edit, id: crime_application) }
    end
  end

  context 'when the step is `national_savings_certificates`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :national_savings_certificates }

    context 'has correct next step' do
      it { is_expected.to have_destination(:national_savings_certificates_summary, :edit, id: crime_application) }
    end
  end

  context 'when the step is `premium_bonds`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :premium_bonds }

    context 'has correct next step' do
      it { is_expected.to have_destination(:has_national_savings_certificates, :edit, id: crime_application) }
    end
  end

  context 'when the step is `other_saving_type`' do
    let(:form_object) { double('FormObject', saving:) }
    let(:step_name) { :other_saving_type }

    context 'the client has selected a saving type' do
      let(:saving) { 'new_saving' }

      it 'redirects the edit `savings` page' do
        expect(subject).to have_destination(:savings, :edit, id: crime_application, saving_id: saving)
      end
    end
  end

  context 'when the step is `other_investment_type`' do
    let(:form_object) { double('FormObject', investment:) }
    let(:step_name) { :other_investment_type }

    context 'the client has selected a investment type' do
      let(:investment) { 'new_investment' }

      it 'redirects the edit `investments` page' do
        expect(subject).to have_destination(:investments, :edit, id: crime_application, investment_id: investment)
      end
    end
  end
end
