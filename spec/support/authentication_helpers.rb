module AuthenticationHelpers
  def sign_in(provider = double('provider'))
    allow(request.env['warden']).to receive(:authenticate!).and_return(provider)
    allow(controller).to receive(:current_provider).and_return(provider)
  end
end
