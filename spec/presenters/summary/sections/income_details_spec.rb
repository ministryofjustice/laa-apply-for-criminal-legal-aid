require 'rails_helper'

describe Summary::Sections::IncomeDetails do
  subject(:section) { described_class.new(crime_application) }

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

  let(:include_partner?) { false }

  before do
    allow(section).to receive(:include_partner_in_means_assessment?).and_return(include_partner?)
  end

  describe '#name' do
    it { expect(section.name).to eq(:income_details) }
  end

  describe '#show?' do
    context 'when there is an income_details' do
      it 'shows this section' do
        expect(section.show?).to be(true)
      end
    end

    context 'when there is no income_details' do
      let(:income) { nil }

      it 'does not show this section' do
        expect(section.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }
    let(:rows) {
      [
        [
          :income_above_threshold,
          'current-income-before-tax'
        ],
        [
          :has_frozen_income_or_assets,
          'income-savings-assets-under-restraint-freezing-order'
        ],
        [
          :client_owns_property,
          'own-home-land-property'
        ],
        [
          :has_savings,
          'any-savings-investments'
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

  describe 'answer labels' do
    subject(:labels) { section.answers.map(&:question_text) }

    context 'when partner is included in means assessment' do
      let(:include_partner?) { true }

      let(:expected_labels) do
        [
          'Client or partner owns home, land or property?',
          'Joint annual income more than £12,475 a year before tax?',
          'Income, savings or assets under a restraint or freezing order',
          'Savings or investments?'
        ]
      end

      it { is_expected.to match_array expected_labels }
    end

    context 'when partner is not included means assessment' do
      let(:include_partner?) { false }
      let(:expected_labels) do
        [
          'Client owns home, land or property?',
          'Income more than £12,475 a year before tax?',
          'Income, savings or assets under a restraint or freezing order',
          'Savings or investments?'
        ]
      end

      it { is_expected.to match_array expected_labels }
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
