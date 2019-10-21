#tmd
class UserGuidesController < ApplicationController

  def download_pdf
    send_file(
      "#{Rails.root}/public/Инструкция пользователя.pdf",
      type: "application/pdf",
      x_sendfile: true
    )
  end

  #tmd
  def download_file
    send_file(
      "#{Rails.root}/public/uploads/custom_fields/" + params[:filename],
      x_sendfile: true
    )
  end

end
