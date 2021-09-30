class PagesController < ApplicationController
  layout 'admin'
  menu_item :pages
  before_action :require_admin
end
