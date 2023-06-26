class HomeController < UnauthenticatedController
  def index
    redirect_to crime_applications_path if signed_in?
  end
end
