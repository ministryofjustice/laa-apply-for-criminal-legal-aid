require 'rails_helper'

module Test
  PropertyFormValidatable = Struct.new(:has_other_owners, :crime_application, :record, :percentage_applicant_owned,
                                       :percentage_partner_owned, :include_partner_in_means_assessment?,
                                       keyword_init: true) do
    include ActiveModel::Validations

    validates_with CapitalAssessment::PropertyOwnershipValidator

    def to_param
      '12345'
    end
  end
end

RSpec.describe CapitalAssessment::PropertyOwnershipValidator, type: :model do
  subject { Test::PropertyFormValidatable.new(arguments) }

  let(:arguments) do
    {
      has_other_owners: has_other_owners,
      record: record,
      crime_application: crime_application,
      percentage_applicant_owned: percentage_applicant_owned,
      include_partner_in_means_assessment?: include_partner?,
      percentage_partner_owned: percentage_partner_owned,
    }
  end

  let(:has_other_owners) { YesNoAnswer::NO }
  let(:record) { instance_double(Property) }
  let(:crime_application) { instance_double(CrimeApplication, id: '12345') }
  let(:include_partner?) { false }
  let(:percentage_applicant_owned) { 100 }
  let(:percentage_partner_owned) { nil }

  before do
    allow(subject).to receive(:include_partner_in_means_assessment?)
      .and_return(include_partner?)
  end

  describe 'Property ownership validation' do
    context 'when the client solely owns the property' do
      it 'is valid if ownership totals 100' do
        expect(subject).to be_valid
      end

      context 'when the percentage applicant owned ≠ 100' do
        let(:percentage_applicant_owned) { 90 }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:percentage_applicant_owned, :invalid_with_no_partner)).to be(true)
        end
      end
    end

    context "when the client's partner also owns the property" do
      let(:include_partner?) { true }
      let(:percentage_applicant_owned) { 90 }
      let(:percentage_partner_owned) { 10 }

      it 'is valid if ownership totals 100' do
        expect(subject).to be_valid
      end

      context 'when the percentage ownership ≠ 100' do
        let(:percentage_applicant_owned) { 5 }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:percentage_applicant_owned, :invalid)).to be(true)
          expect(subject.errors.of_kind?(:percentage_partner_owned, :invalid)).to be(true)
        end
      end
    end

    context 'when there are other owners' do
      let(:has_other_owners) { YesNoAnswer::YES }
      let(:include_partner?) { true }

      context 'when percentage ownership totals 100' do
        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:has_other_owners, :invalid_when_other_owners)).to be(true)
        end
      end

      context 'when percentage ownership is greater than 100' do
        let(:percentage_partner_owned) { 10 }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:has_other_owners, :invalid_when_other_owners)).to be(true)
        end
      end

      context 'when percentage ownership is less than 100' do
        let(:percentage_applicant_owned) { 90 }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end
end
