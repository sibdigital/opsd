#-- encoding: UTF-8
# This file written by BBM
# 24/06/2019

class AttachType < Enumeration
  has_many :attachments, foreign_key: 'attach_type_id'
  OptionName = :enumeration_attach_type

  def self.colored?
    false
  end

  def option_name
    OptionName
  end

  def objects_count
    attachments.count
  end

  def transfer_relations(to)
    attachments.update_all(attach_type_id: to.id)
  end
end
