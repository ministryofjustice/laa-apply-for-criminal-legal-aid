require 'rails_helper'

module Test
  PropertyFormValidatable = Struct.new(:has_other_owners, :crime_application, :record, :percentage_applicant_owned,
                                       :percentage_partner_owned, keyword_init: true) do
    include ActiveModel::Validations
    validates_with CapitalAssessment::PropertyOwnershipValidator

    def to_param
      '12345'
    end
  end
end

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe CapitalAssessment::PropertyOwnershipValidator, type: :model do
  subject { Test::PropertyFormValidatable.new(arguments) }

  let(:arguments) do
    {
      has_other_owners:,
      record:,
      crime_application:,
      percentage_applicant_owned:,
      percentage_partner_owned:,
    }
  end

  let(:has_other_owners) { YesNoAnswer::NO }
  let(:record) { instance_double(Property, property_owners:) }
  let(:property_owner) {
    instance_double(PropertyOwner, complete?: property_owner_complete?,
   percentage_owned: property_owner_percentage_owned)
  }
  let(:property_owners) { [] }
  let(:property_owner_complete?) { true }
  let(:property_owner_percentage_owned) { nil }
  let(:crime_application) {
    instance_double(CrimeApplication,
                    id: '12345', client_has_partner: client_has_partner)
  }
  let(:client_has_partner) { false }
  let(:percentage_applicant_owned) { 100 }
  let(:percentage_partner_owned) { nil }

  describe 'Property ownership validation' do
    context 'when the client solely owns the property' do
      it 'is valid if ownership totals 100' do
        expect(subject).to be_valid
      end

      context 'when the percentage applicant owned ≠ 100' do
        let(:percentage_applicant_owned) { 90 }

        it 'is invalid' do
          expect(subject).not_to be_valid
        end
      end
    end

    context "when the client's partner also owns the property" do
      let(:client_has_partner) { true }
      let(:percentage_applicant_owned) { 90 }
      let(:percentage_partner_owned) { 10 }

      it 'is valid if ownership totals 100' do
        expect(subject).to be_valid
      end

      context 'when the percentage ownership ≠ 100' do
        let(:percentage_applicant_owned) { 5 }

        it 'is invalid' do
          expect(subject).not_to be_valid
        end
      end
    end

    context 'when there are other owners' do
      let(:client_has_partner) { true }
      let(:percentage_applicant_owned) { 80 }
      let(:percentage_partner_owned) { 10 }
      let(:has_other_owners) { YesNoAnswer::YES }
      let(:property_owner_percentage_owned) { 10 }

      context 'when the other owners have not been added yet' do
        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'when there is an incomplete other property owner' do
        let(:property_owner_complete?) { false }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'when the other owners have been added' do
        let(:property_owners) { [property_owner] }

        context 'when total ownership = 100' do
          it 'is valid' do
            expect(subject).to be_valid
          end
        end

        context 'when total ownership ≠ 100' do
          let(:property_owner_percentage_owned) { 5 }

          it 'is invalid' do
            expect(subject).not_to be_valid
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
