require 'rails_helper'

RSpec.describe 'Locale switching', type: :controller do
  controller(ApplicationController) do
    def show_locale
      render plain: I18n.locale
    end
  end

  before do
    routes.draw { get 'show_locale' => 'anonymous#show_locale' }
  end

  describe 'switching locales' do
    context 'when locale param is :cy' do
      it 'sets the locale to Welsh' do
        get :show_locale, params: { locale: 'cy' }
        expect(response.body).to eq('cy')
      end
    end

    context 'when locale param is :en' do
      it 'sets the locale to English' do
        get :show_locale, params: { locale: 'en' }
        expect(response.body).to eq('en')
      end
    end

    context 'when no locale is given' do
      it 'defaults to I18n.default_locale' do
        get :show_locale
        expect(response.body).to eq(I18n.default_locale.to_s)
      end
    end
  end
end
