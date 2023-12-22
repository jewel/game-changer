class ApplicationController < ActionController::Base
  # Disable session if there is a CSRF failure; helps with API requests and
  # should do the right thing elsewhere
  protect_from_forgery with: :null_session
end
