require 'rails_helper'

RSpec.describe Business, type: :model do
  subject(:business) { described_class.new(attributes) }

  let(:attributes) { {} }

  describe '#turnover' do
    subject(:turnover) { business.turnover }

    it 'is has a default amount of nil' do
      expect(turnover.amount).to be_nil
      expect(turnover.frequency).to be_nil
    end

    it 'sets the amount as a money object' do
      business.turnover.amount = '12.00'
    end
  end

  describe '#valid?' do
    let(:valid_attributes) do
      {
        crime_application: CrimeApplication.new,
        business_type: BusinessType::SELF_EMPLOYED.to_s
      }
    end

    context 'when business_type' do
      subject(:business_is_valid) { business.valid? }

      let(:attributes) { valid_attributes.merge(business_type:) }

      context 'is null' do
        let(:business_type) { '' }

        it { is_expected.to be false }
      end

      context 'is empty string' do
        let(:business_type) { nil }

        it { is_expected.to be false }
      end

      context 'is something else' do
        let(:business_type) { 'NotBusinessType' }

        it { is_expected.to be false }
      end

      context 'is a BusinessType' do
        let(:business_type) { BusinessType.values.sample.to_s }

        it { is_expected.to be true }
      end
    end
  end

  describe '#owner' do
    subject(:owner) { business.owner }

    let(:crime_application) do
      CrimeApplication.new(applicant: Applicant.new, partner: Partner.new)
    end

    let(:attributes) { { crime_application:, ownership_type: } }

    context 'when ownership type is not set' do
      let(:ownership_type) { nil }

      it { is_expected.to be_nil }
    end

    context 'when owned by applicant' do
      let(:ownership_type) { 'applicant' }

      it { is_expected.to be crime_application.applicant }
    end

    context 'when owned by partner' do
      let(:ownership_type) { 'partner' }

      it { is_expected.to be crime_application.partner }
    end
  end

  describe '#complete?' do
    subject { business.complete? }

    let(:required_attributes) do
      {
        id: SecureRandom.uuid,
        business_type: BusinessType::SELF_EMPLOYED.to_s,
        trading_name: 'Test Trading Name',
        description: 'A Test Business',
        trading_start_date: Date.new(2001, 10, 12),
        has_additional_owners: YesNoAnswer::NO.to_s,
        additional_owners: nil,
        has_employees: YesNoAnswer::NO.to_s,
        number_of_employees: nil,
        turnover: AmountAndFrequency.new(amount: 100, frequency: PaymentFrequencyType::MONTHLY),
        drawings: AmountAndFrequency.new(amount: 100, frequency: PaymentFrequencyType::MONTHLY),
        profit: AmountAndFrequency.new(amount: 100, frequency: PaymentFrequencyType::MONTHLY),
        percentage_profit_share: nil,
        salary: nil,
        total_income_share_sales: nil,
        address: address_attributes
      }
    end

    let(:address_attributes) do
      {
        'address_line_one' => 'address_line_one',
        'address_line_two' => 'address_line_two',
        'city' => 'city',
        'country' => 'country',
        'postcode' => 'postcode'
      }
    end

    context 'when any required attributes are missing' do
      it { is_expected.to be false }
    end

    context 'when all required attributes are present' do
      let(:attributes) { required_attributes }

      it { is_expected.to be true }
    end

    context 'additional owners validation' do
      context 'when the business has additional owners' do
        context 'and the additional owners have not been provided' do
          let(:attributes) do
            required_attributes.merge(has_additional_owners: YesNoAnswer::YES.to_s, additional_owners: nil)
          end

          it { expect(subject).to be false }
        end

        context 'and the additional owners have been provided' do
          let(:attributes) do
            required_attributes.merge(has_additional_owners: YesNoAnswer::YES.to_s, additional_owners: 'Owner 1')
          end

          it { expect(subject).to be true }
        end
      end
    end

    context 'employees validation' do
      context 'when the business has employees' do
        context 'and the number of employees has not been provided' do
          let(:attributes) do
            required_attributes.merge(has_employees: YesNoAnswer::YES.to_s, number_of_employees: nil)
          end

          it { expect(subject).to be false }
        end

        context 'and the number of employees has been provided' do
          let(:attributes) do
            required_attributes.merge(has_employees: YesNoAnswer::YES.to_s, number_of_employees: 5)
          end

          it { expect(subject).to be true }
        end
      end
    end

    context 'director/stakeholder business validation' do
      context 'when the businesses type is `director_or_shareholder`' do
        context 'and the salary and total_income_share_sales has not been provided' do
          let(:attributes) do
            required_attributes.merge(business_type: BusinessType::DIRECTOR_OR_SHAREHOLDER.to_s)
          end

          it { expect(subject).to be false }
        end

        context 'and the salary and total_income_share_sales figures have been provided' do
          let(:attributes) do
            required_attributes.merge(business_type: BusinessType::DIRECTOR_OR_SHAREHOLDER.to_s,
                                      percentage_profit_share: 50,
                                      salary: AmountAndFrequency.new(amount: 100,
                                                                     frequency: PaymentFrequencyType::ANNUALLY),
                                      total_income_share_sales: AmountAndFrequency.new(amount: 100,
                                                                                       frequency: PaymentFrequencyType::ANNUALLY))
          end

          it { expect(subject).to be true }
        end
      end
    end

    context 'partnership business validation' do
      context 'when the businesses type is `partnership`' do
        context 'and the percentage_profit_share has not been provided' do
          let(:attributes) do
            required_attributes.merge(business_type: BusinessType::PARTNERSHIP.to_s)
          end

          it { expect(subject).to be false }
        end

        context 'and the percentage_profit_share figure has been provided' do
          let(:attributes) do
            required_attributes.merge(business_type: BusinessType::PARTNERSHIP.to_s, percentage_profit_share: 50)
          end

          it { expect(subject).to be true }
        end
      end
    end

    context 'address validation' do
      context 'with invalid address attributes' do
        let(:attributes) do
          required_attributes.merge(address: address_attributes.merge('address_line_one' => ''))
        end

        it { expect(subject).to be false }
      end
    end
  end
end
