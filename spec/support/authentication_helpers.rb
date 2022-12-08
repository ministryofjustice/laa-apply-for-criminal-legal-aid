module AuthenticationHelpers
  def sign_in(provider = double('provider'))
    login_as(provider)
    allow(controller).to receive(:current_user).and_return(provider)
  end

  def sign_out
    logout
    allow(controller).to receive(:current_user).and_return(nil)
  end
end
