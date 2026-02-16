require 'rails_helper'

RSpec.describe Summary::Components::BaseRecord do
  subject(:component) { described_class.new(record:, **args) }

  let(:record) do
    instance_double(
      Saving,
      complete?: true,
      model_name: double(human: 'Record human name')
    )
  end

  let(:args) { {} }

  describe '#show_actions' do
    it 'defaults to true' do
      expect(described_class.new(record:).show_actions).to be true
    end

    it 'can be set on initialisation' do
      expect(described_class.new(record: record, show_actions: false).show_actions).to be false
    end
  end

  describe '#record_iteration' do
    it 'defaults to nil' do
      expect(described_class.new(record:).record_iteration).to be_nil
    end

    it 'can be set on initialisation via record_iteration' do
      expect(described_class.new(record: record, record_iteration: false).record_iteration).to be false
    end
  end

  describe '#show_record_actions' do
    it 'defaults to false' do
      expect(described_class.new(record:).show_record_actions).to be false
    end

    it 'can be set on initialisation' do
      expect(described_class.new(record: record, show_actions: true).show_actions).to be true
    end
  end

  describe '#name' do
    it 'returns human model name of the record' do
      expect(component.name).to eq('Record human name')
    end
  end

  describe '#title' do
    subject(:title) { component.title }

    let(:args) { {} }

    it { is_expected.to match 'Record human name' }

    context 'when record is incomplete' do
      before do
        allow(record).to receive(:complete?).and_return(false)
      end

      it 'includes the incomplete status in the title' do
        expect(title).to match(
          '<strong class=\"govuk-tag govuk-tag--red\">Incomplete</strong> Record human name'
        )
      end
    end

    context 'when record is one of one' do
      let(:args) { { record_iteration: double(size: 1) } }

      it { is_expected.to match 'Record human name' }
    end

    context 'when record is first of several' do
      let(:args) { { record_iteration: double(size: 5, index: 0) } }

      it { is_expected.to match 'Record human name 1' }
    end

    context 'when record is last of several' do
      let(:args) { { record_iteration: double(size: 5, index: 4) } }

      it { is_expected.to match 'Record human name 5' }
    end
  end

  describe '#change_link' do
    subject(:change_link) { component.change_link }

    before do
      allow(component).to receive(:change_path).and_return('/change/this')
    end

    it 'returns a link to change_path' do
      expect(component.change_link).to eq(
        '<a class="govuk-link govuk-link--no-visited-state" href="/change/this">' \
        'Change<span class="govuk-visually-hidden"> Record human name</span></a>'
      )
    end
  end

  describe '#remove_link' do
    subject(:remove_link) { component.change_link }

    before do
      allow(component).to receive(:remove_path).and_return('/remove/this')
    end

    it 'returns a link to remove_path' do
      expect(component.remove_link).to eq(
        '<a class="govuk-link govuk-link--no-visited-state" href="/remove/this">' \
        'Remove<span class="govuk-visually-hidden"> Record human name</span></a>'
      )
    end
  end
end
