class Stakeholder < ActiveRecord::Base

  belongs_to :target # целевой показатель, для которого приводится методика
  belongs_to :project

  #zbd(
  validates_format_of :mail_add, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, allow_blank: true
  validates_length_of :mail_add, maximum: 60, allow_nil: true
  # validates_format_of :phone_wrk, with: /\A((8|\+7)[\- ]?)?(\(?\d{3}\)?[\- ]?)?[\d\- ]{6,10}\z/i, allow_blank: true
  # validates_format_of :phone_wrk_add, with: /\A[0-9]{1,4}\z/i, allow_blank: true
  #validates_format_of :phone_mobile, with: /\A^((8|\+7)[\- ]?)?(\(?\d{3}\)?[\- ]?)?[\d\- ]{7,10}\z/i, allow_blank: true
  validates_length_of :address, maximum: 255
  validates_length_of :cabinet, maximum: 6
  #)

end
