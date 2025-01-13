require 'rails_helper'

RSpec.describe Decisions::CapitalDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 'uuid',
      income: income,
      capital: capital,
      partner_detail: partner_detail,
      partner: nil,
      non_means_tested?: false,
      properties: properties
    )
  end

  let(:capital) { instance_double(Capital) }
  let(:income) { instance_double(Income, has_frozen_income_or_assets:) }
  let(:has_frozen_income_or_assets) { nil }
  let(:partner_detail) { instance_double(PartnerDetail, involvement_in_case:, conflict_of_interest:) }
  let(:involvement_in_case) { nil }
  let(:conflict_of_interest) { nil }
  let(:properties) { Property.none }

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

      it 'redirects to the trust fund page' do
        expect(subject).to have_destination(:trust_fund, :edit, id: crime_application)
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

      context 'when usual property details are required' do
        before do
          allow(capital).to receive(:usual_property_details_required?).and_return(true)
        end

        it 'redirects to usual property details' do
          expect(subject).to have_destination(:usual_property_details, :edit, id: crime_application)
        end
      end

      context 'when usual property details are not required' do
        before do
          allow(capital).to receive(:usual_property_details_required?).and_return(false)
        end

        it 'redirects to select saving type' do
          expect(subject).to have_destination(:saving_type, :edit, id: crime_application)
        end
      end
    end

    context 'the client has selected a residential property type' do
      let(:property) { instance_double(Property, property_type: 'residential') }

      it 'redirects the edit `residential_property` page' do
        expect(subject).to have_destination(:residential_property, :edit, id: crime_application, property_id: property)
      end
    end

    context 'the client has selected a commercial property type' do
      let(:property) { instance_double(Property, property_type: 'commercial') }

      it 'redirects the edit `residential_property` page' do
        expect(subject).to have_destination(:commercial_property, :edit, id: crime_application, property_id: property)
      end
    end

    context 'the client has selected land' do
      let(:property) { instance_double(Property, property_type: 'land') }

      it 'redirects the edit `land` page' do
        expect(subject).to have_destination(:land, :edit, id: crime_application, property_id: property)
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

    context 'is_home_address, has_other_owners' do
      context 'when property address is same as home address and have no other owners' do
        let(:is_home_address) { YesNoAnswer::YES }
        let(:has_other_owners) { YesNoAnswer::NO }

        it 'redirects to `properties_summary` page' do
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

  context 'when the step is `commercial_property`' do
    let(:form_object) do
      double('FormObject', record:, is_home_address:, has_other_owners:)
    end
    let(:step_name) { :commercial_property }
    let(:record) { instance_double(Property, property_owners: [property_owner]) }
    let(:property_owner) { instance_double(PropertyOwner, complete?: false) }

    context 'is_home_address, has_other_owners' do
      context 'when property address is same as home address and have no other owners' do
        let(:is_home_address) { YesNoAnswer::YES }
        let(:has_other_owners) { YesNoAnswer::NO }

        it 'redirects to `properties_summary` page' do
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

  context 'when the step is `land`' do
    let(:form_object) do
      double('FormObject', record:, is_home_address:, has_other_owners:)
    end
    let(:step_name) { :land }
    let(:record) { instance_double(Property, property_owners: [property_owner]) }
    let(:property_owner) { instance_double(PropertyOwner, complete?: false) }

    context 'is_home_address, has_other_owners' do
      context 'when property address is same as home address and have no other owners' do
        let(:is_home_address) { YesNoAnswer::YES }
        let(:has_other_owners) { YesNoAnswer::NO }

        it 'redirects to `properties_summary` page' do
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

      it 'redirects to `properties_summary` page' do
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

    it 'redirects to `properties_summary` page' do
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

  context 'when the step is `properties_summary`' do
    let(:form_object) { double('FormObject', property:) }
    let(:step_name) { :properties_summary }
    let(:property) { 'new_property' }

    before do
      allow(form_object).to receive_messages(crime_application:, add_property:)
    end

    context 'the client has selected yes to adding an asset' do
      let(:add_property) { YesNoAnswer::YES }

      it 'redirects to the edit `property type` page' do
        expect(subject).to have_destination(:other_property_type, :edit, id: crime_application)
      end
    end

    context 'the client has selected no to adding an asset' do
      let(:add_property) { YesNoAnswer::NO }

      context 'when usual property details are required' do
        before do
          allow(capital).to receive(:usual_property_details_required?).and_return(true)
        end

        it 'redirects to usual property details' do
          expect(subject).to have_destination(:usual_property_details, :edit, id: crime_application)
        end
      end

      context 'when usual property details are not required' do
        before do
          allow(capital).to receive(:usual_property_details_required?).and_return(false)
        end

        it 'redirects to select saving type' do
          expect(subject).to have_destination(:saving_type, :edit, id: crime_application)
        end
      end
    end
  end

  context 'when the step is `usual_property_details`' do
    let(:form_object) { double('FormObject', action:) }
    let(:step_name) { :usual_property_details }

    context 'and they want to provide the details of the property' do
      let(:action) { 'provide_details' }
      let(:property) { instance_double(Property, property_type: 'residential') }

      before do
        allow(properties).to receive(:create!).and_return(property)
      end

      it 'redirects to `residential_property`' do
        expect(subject).to have_destination(:residential_property, :edit, id: crime_application, property_id: property)
      end
    end

    context 'and they want to change the answer to where the client usually lives' do
      let(:action) { 'change_answer' }

      it 'redirects to `residence_type`' do
        expect(subject).to have_destination('/steps/client/residence_type', :edit, id: crime_application)
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

  context 'when the step is `investment_type`' do
    let(:form_object) { double('FormObject', investment:) }
    let(:step_name) { :investment_type }

    context 'the client has no investments' do
      let(:investment) { nil }

      it 'redirects premium bonds' do
        expect(subject).to have_destination(:trust_fund, :edit, id: crime_application)
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

    context 'when partner is included' do
      let(:involvement_in_case) { PartnerInvolvementType::NONE.to_s }

      it { is_expected.to have_destination(:partner_premium_bonds, :edit, id: crime_application) }
    end

    context 'when partner is not included' do
      let(:involvement_in_case) { PartnerInvolvementType::VICTIM.to_s }

      it { is_expected.to have_destination(:has_national_savings_certificates, :edit, id: crime_application) }
    end
  end

  context 'when the step is `partner_premium_bonds`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :partner_premium_bonds }

    context 'has correct next step' do
      it { is_expected.to have_destination(:has_national_savings_certificates, :edit, id: crime_application) }
    end
  end

  context 'when the step is `trust_fund`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :trust_fund }

    context 'when there is no partner' do
      let(:partner_detail) { nil }

      context 'when has_frozen_income_or_assets is nil' do
        it { is_expected.to have_destination(:frozen_income_savings_assets_capital, :edit, id: crime_application) }
      end

      context 'when has_frozen_income_or_assets is set' do
        let(:has_frozen_income_or_assets) { YesNoAnswer::YES.to_s }

        it { is_expected.to have_destination(:answers, :edit, id: crime_application) }
      end
    end

    context 'when there is a partner' do
      context 'when partner is not included' do
        let(:involvement_in_case) { PartnerInvolvementType::VICTIM.to_s }

        context 'when has_frozen_income_or_assets is nil' do
          it { is_expected.to have_destination(:frozen_income_savings_assets_capital, :edit, id: crime_application) }
        end

        context 'when has_frozen_income_or_assets is set' do
          let(:has_frozen_income_or_assets) { YesNoAnswer::YES.to_s }

          it { is_expected.to have_destination(:answers, :edit, id: crime_application) }
        end
      end

      context 'when partner is included' do
        let(:involvement_in_case) { PartnerInvolvementType::NONE.to_s }

        it { is_expected.to have_destination(:partner_trust_fund, :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `partner_trust_fund`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :partner_trust_fund }

    context 'when has_frozen_income_or_assets is nil' do
      it { is_expected.to have_destination(:frozen_income_savings_assets_capital, :edit, id: crime_application) }
    end

    context 'when has_frozen_income_or_assets is set' do
      let(:has_frozen_income_or_assets) { YesNoAnswer::YES.to_s }

      it { is_expected.to have_destination(:answers, :edit, id: crime_application) }
    end
  end

  context 'when the step is `frozen_income_savings_assets_capital`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :frozen_income_savings_assets_capital }

    context 'redirects to the answers page' do
      it { is_expected.to have_destination(:answers, :edit, id: crime_application) }
    end
  end

  context 'when the step is `answers`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :answers }

    context 'redirects to the evidence upload page' do
      it { is_expected.to have_destination('/steps/evidence/upload', :edit, id: crime_application) }
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
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
