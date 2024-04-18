require 'rails_helper'

describe Summary::Sections::IncomeDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      income: income,
    )
  end

  let(:income) do
    instance_double(
      Income,
      income_above_threshold: 'no',
      has_frozen_income_or_assets: 'no',
      client_owns_property: 'no',
      has_savings: 'no'
    )
  end

  describe '#name' do
    it { expect(subject.name).to eq(:income_details) }
  end

  describe '#show?' do
    context 'when there is an income_details' do
      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end

    context 'when there is no income_details' do
      let(:income) { nil }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }
    let(:rows) {
      [
        [
          :income_above_threshold,
          'current_income_before_tax'
        ],
        [
          :has_frozen_income_or_assets,
          'income_savings_assets_under_restraint_freezing_order'
        ],
        [
          :client_owns_property,
          'own_home_land_property'
        ],
        [
          :has_savings,
          'any_savings_investments'
        ]
      ]
    }

    context 'when there are income details' do
      it 'has the correct rows' do
        expect(answers.count).to eq(rows.size)

        rows.each_with_index do |row, i|
          income_details_yes_no_row_check(*row, i)
        end
      end
    end
  end

  def income_details_yes_no_row_check(step, path, index) # rubocop:disable Metrics/AbcSize
    full_path = "applications/12345/steps/income/#{path}"
    expect(answers[index]).to be_an_instance_of(Summary::Components::ValueAnswer)
    expect(answers[index].question).to eq(step)
    expect(answers[index].change_path).to match(full_path)
    expect(answers[index].value).to eq('no')
  end
end
