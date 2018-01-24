class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include GoogleVisualr::Rails::ViewHelper
end
