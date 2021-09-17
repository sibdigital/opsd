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

  def edit
    object = DynamicPage.find(params[:id].to_i)
    object.content = params[:dynamic_page][:content]
    object.save!
    if !params[:attachments].nil?
      params[:attachments].values.each do |a|
        attachment = Attachment.find(a[:id])
        attachment.container_id = params[:id]
        attachment.container_type = 'DynamicPage'
        attachment.save
      end
    end
    redirect_to controller: 'settings', action: 'edit', tab: 'user_guide'
  end
end
