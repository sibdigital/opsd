#-- encoding: UTF-8
#+-tan 2019.04.25
class ErrorsController < ApplicationController

  def internal_server_error
    render(action: 'internal_server_error')
  end

end
