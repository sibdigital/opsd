#tmd
class UserGuidesController < ApplicationController

  def download_pdf
    send_file(
      "#{Rails.root}/public/Инструкция пользователя.pdf",
      type: "application/pdf",
      x_sendfile: true
    )
  end
end
