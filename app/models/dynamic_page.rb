class DynamicPage < ActiveRecord::Base
  acts_as_attachable #view_permission: true,
  # delete_permission: true,
  # add_on_new_permission: true,
  # add_on_persisted_permission: true

  # has_many :attachments, as: :container
  # ->() {where(attachments: {container_type: 'UserGuide'})},
  # foreign_key: :container_id,
  # :dependent => :destroy

  def attachments_addable?(current_user)
    true
  end

  def allowed_to_on_attachment?(current_user, permissions)
    true
  end

  # def attachments
  #   Attachment.where(container_id: 127, container_type: 'UserGuide')
  # end
end
