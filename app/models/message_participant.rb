class MessageParticipant < ActiveRecord::Base
  belongs_to :user
  attr_accessor :invited

  User.before_destroy do |user|
    MessageParticipant.where(['user_id = ?', user.id]).update_all ['user_id = ?', DeletedUser.first]
  end


  def name
    user.present? ? user.name : name
  end

  def mail
    user.present? ? user.mail : mail
  end

  def <=>(participant)
    to_s.downcase <=> participant.to_s.downcase
  end

  alias :to_s :name

 # def copy_attributes
 #   # create a clean attribute set allowing to attach participants to different meetings
 #   attributes.reject { |k, _v| ['id', 'meeting_id', 'attended', 'created_at', 'updated_at'].include?(k) }
  #end

end
