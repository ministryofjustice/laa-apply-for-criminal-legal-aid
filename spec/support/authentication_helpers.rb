module AuthenticationHelpers
  def sign_in(provider = double('provider'))
    allow(warden).to receive(:authenticate!).and_return(provider)
  end
end
