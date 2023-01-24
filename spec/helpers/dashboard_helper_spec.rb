require 'rails_helper'

RSpec.describe DashboardHelper, type: :helper do
  describe '#aria_sort' do
    before do
      allow(helper).to receive(:sort_by).and_return('my_column')
    end

    context 'when sorting by this column' do
      subject { helper.aria_sort('my_column') }

      before do
        allow(helper).to receive(:sort_direction).and_return(sort_direction)
      end

      context 'when direction is ascending' do
        let(:sort_direction) { 'asc' }

        it { is_expected.to eq('ascending') }
      end

      context 'when direction is descending' do
        let(:sort_direction) { 'desc' }

        it { is_expected.to eq('descending') }
      end
    end

    context 'when sorting by other column' do
      subject { helper.aria_sort('foobar_column') }

      it { is_expected.to eq('none') }
    end
  end
end
