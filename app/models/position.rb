#-- encoding: UTF-8
#+-tan 2019.04.25
class Position < ActiveRecord::Base

  acts_as_customizable
  acts_as_journalized

  def to_s;
    name
  end
end
