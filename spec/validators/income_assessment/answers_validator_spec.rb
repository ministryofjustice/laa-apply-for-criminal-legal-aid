require 'rails_helper'

RSpec.describe IncomeAssessment::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record:, crime_application:) }

  let(:record) { Income.new(crime_application:) }

  let(:crime_application) do
    CrimeApplication.new(
      case: Case.new(case_type: 'summary_only'),
      partner: partner,
      partner_detail: PartnerDetail.new(involvement_in_case: 'none'),
      applicant: Applicant.new
    )
  end

  let(:partner) { Partner.new(date_of_birth: '2000-01-01') }

  let(:requires_means_assessment?) { true }

  let(:employment_validator) do
    instance_double(EmploymentDetails::AnswersValidator, validate: nil)
  end

  let(:partner_employment_validator) do
    instance_double(PartnerEmploymentDetails::AnswersValidator, validate: nil)
  end

  before do
    allow(validator).to receive_messages(
      evidence_of_passporting_means_forthcoming?: false,
      requires_means_assessment?: requires_means_assessment?
    )

    allow(EmploymentDetails::AnswersValidator).to receive(:new).and_return(
      employment_validator
    )

    allow(PartnerEmploymentDetails::AnswersValidator).to receive(:new).and_return(
      employment_validator
    )
  end

  describe '#applicable?' do
    subject(:applicable?) { validator.applicable? }

    context 'when means assessment not required' do
      let(:requires_means_assessment?) { false }

      it { is_expected.to be(false) }
    end

    context 'when means assessment required' do
      let(:requires_means_assessment?) { true }

      it { is_expected.to be(true) }
    end
  end

  describe '#complete?' do
    subject(:complete?) { validator.complete? }

    context 'when validate does not add errors' do
      before { allow(validator).to receive(:validate).and_return(nil) }

      it { is_expected.to be(true) }
    end

    context 'when validate adds errors' do
      before do
        record.has_no_income_payments = nil
        crime_application.save!
      end

      it { is_expected.to be(false) }
    end
  end

  describe '#validate' do
    before do
      allow(validator).to receive_messages(
        applicable?: true
      )

      crime_application.income_payments = income_payments
      crime_application.income_benefits = income_benefits
      record.attributes = record_attributes

      record.save!
    end

    context 'when all validations pass' do
      before do
        allow(MeansStatus).to receive_messages(full_means_required?: true, include_partner?: true)
      end

      let(:income_payments) do
        [
          IncomePayment.new(ownership_type: 'applicant', payment_type: 'maintenance', amount: 1, frequency: 'week'),
          IncomePayment.new(ownership_type: 'partner', payment_type: 'maintenance', amount: 1, frequency: 'week')
        ]
      end

      let(:income_benefits) do
        [
          IncomeBenefit.new(ownership_type: 'applicant', payment_type: 'incapcity', amount: 1, frequency: 'week'),
          IncomeBenefit.new(ownership_type: 'partner', payment_type: 'incapcity', amount: 1, frequency: 'week')
        ]
      end

      let(:record_attributes) do
        {
          employment_status: ['not_working'],
          income_above_threshold: 'no',
          has_frozen_income_or_assets: 'no',
          has_no_income_payments: 'no',
          has_no_income_benefits: 'no',
          partner_has_no_income_payments: nil,
          partner_has_no_income_benefits: nil,
          client_has_dependants: 'yes',
          manage_without_income: 'Use savings',
        }
      end

      it 'does not add any errors' do
        subject.validate
        expect(subject.errors).to be_empty
      end
    end

    context 'when validation fails' do
      let(:income_payments) { [] }
      let(:income_benefits) { [] }

      context 'when extent of means is not known' do
        let(:record_attributes) do
          {
            income_above_threshold: nil,
            has_frozen_income_or_assets: nil,
            has_no_income_payments: 'no',
            has_no_income_benefits: 'no',
            partner_has_no_income_payments: 'no',
            partner_has_no_income_benefits: 'no',
            client_has_dependants: nil,
            manage_without_income: nil
          }
        end

        before { allow(validator).to receive(:include_partner_in_means_assessment?).and_return(true) }

        it 'adds errors for all failed validations' do
          subject.validate

          expect(subject.errors.of_kind?('income_before_tax', :incomplete)).to be(true)
          expect(subject.errors.of_kind?('base', :incomplete_records)).to be(true)
        end
      end

      context 'when extent of means is known' do
        before do
          allow(MeansStatus).to receive_messages(full_means_required?: true, include_partner?: true)
          allow(validator).to receive(:include_partner_in_means_assessment?).and_return(true)
        end

        let(:record_attributes) do
          {
            income_above_threshold: 'yes',
            has_frozen_income_or_assets: nil,
            has_no_income_payments: 'no',
            has_no_income_benefits: 'no',
            partner_has_no_income_payments: 'no',
            partner_has_no_income_benefits: 'no',
            client_has_dependants: nil,
            manage_without_income: nil
          }
        end

        it 'adds errors for all failed validations' do
          subject.validate

          expect(subject.errors.of_kind?('income_payments', :incomplete)).to be(true)
          expect(subject.errors.of_kind?('income_benefits', :incomplete)).to be(true)
          expect(subject.errors.of_kind?('partner_income_payments', :incomplete)).to be(true)
          expect(subject.errors.of_kind?('partner_income_benefits', :incomplete)).to be(true)
          expect(subject.errors.of_kind?('dependants', :incomplete)).to be(true)
          expect(subject.errors.of_kind?('manage_without_income', :incomplete)).to be(true)
          expect(subject.errors.of_kind?('base', :incomplete_records)).to be(true)
        end
      end
    end
  end

  describe '#income_before_tax_complete?' do
    context 'when income_above_threshold is "yes"' do
      before { allow(record).to receive(:income_above_threshold).and_return('yes') }

      it 'returns true' do
        expect(subject.income_before_tax_complete?).to be(true)
      end
    end

    context 'when income_above_threshold is "no"' do
      before { allow(record).to receive(:income_above_threshold).and_return('no') }

      it 'returns true' do
        expect(subject.income_before_tax_complete?).to be(true)
      end
    end

    context 'when income_above_threshold is nil' do
      before { allow(record).to receive(:income_above_threshold).and_return(nil) }

      it 'returns false' do
        expect(subject.income_before_tax_complete?).to be(false)
      end
    end
  end

  describe '#frozen_income_savings_assets_complete?' do
    context 'when income_below_threshold? is true and has_frozen_income_or_assets is present' do
      before do
        allow(subject).to receive(:income_below_threshold?).and_return(true)
        allow(record).to receive(:has_frozen_income_or_assets).and_return('yes')
      end

      it 'returns true' do
        expect(subject.frozen_income_savings_assets_complete?).to be(true)
      end
    end

    context 'when income_below_threshold? is true but has_frozen_income_or_assets is nil' do
      before do
        allow(subject).to receive(:income_below_threshold?).and_return(true)
        allow(record).to receive(:has_frozen_income_or_assets).and_return(nil)
      end

      it 'returns false' do
        expect(subject.frozen_income_savings_assets_complete?).to be(false)
      end
    end

    context 'when income_below_threshold? is false' do
      before { allow(subject).to receive(:income_below_threshold?).and_return(false) }

      it 'returns true' do
        expect(subject.frozen_income_savings_assets_complete?).to be(true)
      end
    end
  end

  describe '#income_payments_complete?' do
    context 'when has_no_income_payments is yes' do
      before { record.has_no_income_payments = 'yes' }

      it 'returns true' do
        expect(subject.income_payments_complete?).to be(true)
      end
    end

    context 'when has_no_income_payments is nil and income_payments are present and complete' do
      before do
        record.has_no_income_payments = nil
        crime_application.income_payments << IncomePayment.new(
          ownership_type: 'applicant',
          payment_type: 'maintenance',
          amount: 100,
          frequency: 'week',
        )

        crime_application.save!
      end

      it 'returns true' do
        expect(subject.income_payments_complete?).to be(true)
      end
    end

    context 'when has_no_income_payments is nil and income_payments are present but not complete' do
      before do
        record.has_no_income_payments = nil
        crime_application.income_payments << IncomePayment.new(
          ownership_type: 'partner',
          payment_type: 'maintenance',
          amount: 100,
          frequency: 'week',
        )

        crime_application.save!
      end

      it 'returns false' do
        expect(subject.income_payments.all.size).to be 1
        expect(subject.income_payments.for_client.size).to be 0
        expect(subject.income_payments_complete?).to be(false)
      end
    end

    context 'when has_no_income_payments is nil and income_payments are empty' do
      before do
        record.has_no_income_payments = nil

        crime_application.save!
      end

      it 'returns false' do
        expect(subject.income_payments.for_client.size).to be 0
        expect(subject.income_payments_complete?).to be(false)
      end
    end
  end

  describe '#income_benefits_complete?' do
    context 'when has_no_income_benefits is yes' do
      before { record.has_no_income_benefits = 'yes' }

      it 'returns true' do
        expect(subject.income_benefits_complete?).to be(true)
      end
    end

    context 'when has_no_income_benefits is nil and income_benefits are present and complete' do
      before do
        record.has_no_income_benefits = nil
        crime_application.income_benefits << IncomeBenefit.new(
          ownership_type: 'applicant',
          payment_type: 'incapacity',
          amount: 100,
          frequency: 'week',
        )

        crime_application.save!
      end

      it 'returns true' do
        expect(subject.income_benefits_complete?).to be(true)
      end
    end

    context 'when has_no_income_benefits is nil and income_benefits are present but not complete' do
      before do
        record.has_no_income_benefits = nil
        crime_application.income_benefits << IncomeBenefit.new(
          ownership_type: 'partner',
          payment_type: 'incapacity',
          amount: 100,
          frequency: 'week',
        )

        crime_application.save!
      end

      it 'returns false' do
        expect(subject.income_benefits.all.size).to be 1
        expect(subject.income_benefits.for_client.size).to be 0
        expect(subject.income_benefits_complete?).to be(false)
      end
    end

    context 'when has_no_income_benefits is nil and income_benefits are empty' do
      before do
        record.has_no_income_benefits = nil

        crime_application.save!
      end

      it 'returns false' do
        expect(subject.income_benefits.for_client.size).to be 0
        expect(subject.income_benefits_complete?).to be(false)
      end
    end
  end

  describe '#partner_income_payments_complete?' do
    before { allow(validator).to receive(:include_partner_in_means_assessment?).and_return(true) }

    context 'when partner_has_no_income_payments is yes' do
      before { record.partner_has_no_income_payments = 'yes' }

      it 'returns true' do
        expect(subject.partner_income_payments_complete?).to be(true)
      end
    end

    context 'when partner_has_no_income_payments is nil and income_payments are present and complete' do
      before do
        record.partner_has_no_income_payments = nil
        crime_application.income_payments << IncomePayment.new(
          ownership_type: 'partner',
          payment_type: 'maintenance',
          amount: 100,
          frequency: 'week',
        )

        crime_application.save!
      end

      it 'returns true' do
        expect(subject.partner_income_payments_complete?).to be(true)
      end
    end

    context 'when partner_has_no_income_payments is nil and income_payments are present but not complete' do
      before do
        record.partner_has_no_income_payments = nil
        crime_application.income_payments << IncomePayment.new(
          ownership_type: 'applicant',
          payment_type: 'maintenance',
          amount: 100,
          frequency: 'week',
        )

        crime_application.save!
      end

      it 'returns false' do
        expect(subject.income_payments.all.size).to be 1
        expect(partner.income_payments.size).to be 0
        expect(subject.partner_income_payments_complete?).to be(false)
      end
    end

    context 'when partner_has_no_income_payments is nil and income_payments are empty' do
      before do
        record.partner_has_no_income_payments = nil

        crime_application.save!
      end

      it 'returns false' do
        expect(partner.income_payments.size).to be 0
        expect(subject.partner_income_payments_complete?).to be(false)
      end
    end

    context 'when partner is not included in means assessment' do
      before do
        allow(validator).to receive(:include_partner_in_means_assessment?).and_return(false)

        # Generate invalid partner payments state
        record.partner_has_no_income_payments = nil
        crime_application.income_payments << IncomePayment.new(
          ownership_type: 'applicant',
          payment_type: 'maintenance',
          amount: 100,
          frequency: 'week',
        )

        crime_application.save!
      end

      it 'returns true' do
        expect(partner.income_payments.size).to be 0
        expect(subject.partner_income_payments_complete?).to be(true)
      end
    end
  end

  describe '#partner_income_benefits_complete?' do
    before { allow(validator).to receive(:include_partner_in_means_assessment?).and_return(true) }

    context 'when partner_has_no_income_benefits is yes' do
      before { record.partner_has_no_income_benefits = 'yes' }

      it 'returns true' do
        expect(subject.partner_income_benefits_complete?).to be(true)
      end
    end

    context 'when partner_has_no_income_benefits is nil and income_benefits are present and complete' do
      before do
        record.partner_has_no_income_benefits = nil
        crime_application.income_benefits << IncomeBenefit.new(
          ownership_type: 'partner',
          payment_type: 'incapacity',
          amount: 100,
          frequency: 'week',
        )

        crime_application.save!
      end

      it 'returns true' do
        expect(subject.partner_income_benefits_complete?).to be(true)
      end
    end

    context 'when partner_has_no_income_benefits is nil and income_benefits are present but not complete' do
      before do
        record.partner_has_no_income_benefits = nil
        crime_application.income_benefits << IncomeBenefit.new(
          ownership_type: 'applicant',
          payment_type: 'incapacity',
          amount: 100,
          frequency: 'week',
        )

        crime_application.save!
      end

      it 'returns false' do
        expect(subject.income_benefits.all.size).to be 1
        expect(partner.income_benefits.size).to be 0
        expect(subject.partner_income_benefits_complete?).to be(false)
      end
    end

    context 'when partner_has_no_income_benefits is nil and income_benefits are empty' do
      before do
        record.partner_has_no_income_benefits = nil

        crime_application.save!
      end

      it 'returns false' do
        expect(partner.income_benefits.size).to be 0
        expect(subject.partner_income_benefits_complete?).to be(false)
      end
    end

    context 'when partner is not included in means assessment' do
      before do
        allow(validator).to receive(:include_partner_in_means_assessment?).and_return(false)

        # Generate invalid partner benefits state
        record.partner_has_no_income_benefits = nil
        crime_application.income_benefits << IncomeBenefit.new(
          ownership_type: 'applicant',
          payment_type: 'incapacity',
          amount: 100,
          frequency: 'week',
        )

        crime_application.save!
      end

      it 'returns true' do
        expect(partner.income_benefits.size).to be 0
        expect(subject.partner_income_payments_complete?).to be(true)
      end
    end
  end

  describe '#dependants_complete?' do
    context 'when requires_full_means_assessment? is false' do
      before { allow(subject).to receive(:requires_full_means_assessment?).and_return(false) }

      it 'returns true' do
        expect(subject.dependants_complete?).to be(true)
      end
    end

    context 'when requires_full_means_assessment? is true and client_has_dependants is NO' do
      before do
        allow(subject).to receive(:requires_full_means_assessment?).and_return(true)
        allow(record).to receive(:client_has_dependants).and_return(YesNoAnswer::NO.to_s)
      end

      it 'returns true' do
        expect(subject.dependants_complete?).to be(true)
      end
    end

    context 'when requires_full_means_assessment and client_has_dependants but dependants are not present' do
      before do
        allow(subject).to receive(:requires_full_means_assessment?).and_return(true)
        allow(record).to receive_messages(client_has_dependants: YesNoAnswer::YES.to_s, dependants: [])
      end

      it 'returns false' do
        expect(subject.dependants_complete?).to be(false)
      end
    end

    context 'when requires_full_means_assessment and client_has_dependants but dependants are present' do
      before do
        allow(subject).to receive(:requires_full_means_assessment?).and_return(true)
        allow(record).to receive_messages(client_has_dependants: YesNoAnswer::YES.to_s,
                                          dependants: [double('Dependant')])
      end

      it 'returns true' do
        expect(subject.dependants_complete?).to be(true)
      end
    end
  end

  describe '#manage_without_income_complete?' do
    context 'when both income_payments and income_benefits are empty' do
      before do
        allow(MeansStatus).to receive(:full_means_required?).and_return(false)
        allow(record).to receive_messages(income_payments: [], income_benefits: [])
      end

      it 'returns true if manage_without_income is present' do
        allow(record).to receive(:manage_without_income).and_return(true)
        expect(subject.manage_without_income_complete?).to be(true)
      end

      it 'returns false if manage_without_income is not present' do
        allow(record).to receive(:manage_without_income).and_return(nil)
        expect(subject.manage_without_income_complete?).to be(false)
      end

      it 'returns true if client is self-employed' do
        allow(record).to receive_messages(client_self_employed?: true)
        allow(record).to receive(:manage_without_income).and_return(nil)
        expect(subject.manage_without_income_complete?).to be(true)
      end

      it 'returns false if client is not self-employed' do
        allow(record).to receive_messages(client_self_employed?: false)
        allow(record).to receive(:manage_without_income).and_return(nil)
        expect(subject.manage_without_income_complete?).to be(false)
      end

      it 'returns true if partner is self-employed' do
        allow(record).to receive_messages(client_self_employed?: false)
        allow(record).to receive(:manage_without_income).and_return(nil)
        allow(record).to receive_messages(partner_self_employed?: true)
        expect(subject.manage_without_income_complete?).to be(true)
      end

      it 'returns false if partner is not self-employed' do
        allow(record).to receive_messages(client_self_employed?: false)
        allow(record).to receive(:manage_without_income).and_return(nil)
        allow(record).to receive_messages(partner_self_employed?: false)
        expect(subject.manage_without_income_complete?).to be(false)
      end
    end
  end
end
