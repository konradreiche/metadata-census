class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :is_active?
end
