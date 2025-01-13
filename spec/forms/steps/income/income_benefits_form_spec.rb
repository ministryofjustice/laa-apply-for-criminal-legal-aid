require 'rails_helper'
# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Steps::Income::IncomeBenefitsForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) { CrimeApplication.new(case: case_record, applicant: Applicant.new) }
  let(:case_record) { Case.new }

  let(:allowed_types) do
    %w[child working_or_child_tax_credit incapacity industrial_injuries_disablement jsa other]
  end

  let(:other_type) { 'other' }
  let(:other_type_attribute_data) { { 'amount' => 23.30, 'frequency' => 'week', 'details' => 'XYZ' } }

  let(:fieldset_form_class) { Steps::Income::IncomeBenefitFieldsetForm }

  let(:existing_payment) do
    IncomeBenefit.create!(
      payment_type: 'jsa',
      crime_application: crime_application,
      amount: '123',
      frequency: 'four_weeks',
      ownership_type: 'applicant'
    )
  end

  let(:payment_with_incorrect_ownership) do
    IncomeBenefit.create!(
      payment_type: 'child',
      crime_application: crime_application,
      amount: '200',
      frequency: 'month',
      ownership_type: 'partner'
    )
  end

  let(:payments) do
    subject.crime_application.income_benefits
  end

  it_behaves_like 'a payment form', described_class, :has_no_income_benefits

  context 'when record with incorrect ownership exists' do
    it 'does not include the payment type' do
      payment_with_incorrect_ownership
      expect(subject.types).not_to include(payment_with_incorrect_ownership.payment_type)
    end
  end

  describe '#save' do
    context 'with form submission' do
      subject do
        described_class.new(
          crime_application: crime_application,
          types: form_data.dig('steps_income_income_benefits_form', 'types'),
          income_benefits: form_data.dig('steps_income_income_benefits_form', 'income_benefits'),
        )
      end

      before do
        allowed_types.each do |type|
          subject.public_send(:"#{type}=", form_data.dig('steps_income_income_benefits_form', type))
          subject.public_send(type.to_s)
        end

        subject.valid?
      end

      context 'with valid data' do
        let(:form_data) do
          {
            'steps_income_income_benefits_form' => {
              'income_benefits' => [''], # Rails nested attributes field
              'types' => %w[child jsa other], # Selected payment checkboxes

              'child' =>  { 'amount' => '56.12', 'frequency' => 'week' }, # Data for selected payment
              'working_or_child_tax_credit' => { 'amount' => '', 'frequency' => '' },
              'incapacity' => { 'amount' => '', 'frequency' => '' },
              'industrial_injuries_disablement' => { 'amount' => '', 'frequency' => '' },
              'jsa' => { 'amount' => '3.00', 'frequency' => 'annual' },
              'other' => { 'amount' => '44', 'frequency' => 'week', 'details' => 'Side hustle' },
            }
          }
        end

        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'with invalid data' do
        let(:form_data) do
          {
            'steps_income_income_benefits_form' => {
              'income_benefits' => [''],
              'types' => types,

              'child' =>  { 'amount' => '', 'frequency' => 'every week' },
              'working_or_child_tax_credit' => { 'amount' => '', 'frequency' => '' },
              'incapacity' => { 'amount' => '', 'frequency' => '' },
              'industrial_injuries_disablement' => { 'amount' => '', 'frequency' => '' },
              'jsa' => { 'amount' => '3.00', 'frequency' => 'annual', 'details' => 'How?' },
              'other' => { 'amount' => '44', 'frequency' => 'week', 'details' => 'Side hustle' },
            }
          }
        end

        context 'when benefit types types are selected' do
          let(:types) { %w[child jsa other] }

          it 'is invalid' do
            expect(subject).not_to be_valid
          end

          it 'has error messages' do
            expect(subject.errors.count).to be(5)
            expect(subject.errors.of_kind?('child-amount', :blank)).to be(true)
            expect(subject.errors.of_kind?('child-amount', :not_a_number)).to be(true)
            expect(subject.errors.of_kind?('child-amount', :greater_than)).to be(true)
            expect(subject.errors.of_kind?('child-frequency', :inclusion)).to be(true)
            expect(subject.errors.of_kind?('jsa-details', :invalid)).to be(true)

            # Error attributes should respond
            expect(subject.send(:'child-amount')).to be_nil
          end
        end

        context 'when benefit types are not selected' do
          let(:types) { [] }

          it 'is invalid' do
            expect(subject).not_to be_valid
          end

          it 'has error messages' do
            expect(subject.errors.count).to be(1)
            expect(subject.errors.of_kind?('base', :none_selected)).to be(true)
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
