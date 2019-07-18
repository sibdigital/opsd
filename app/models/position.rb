#-- encoding: UTF-8
#+-tan 2019.04.25
class Position < ActiveRecord::Base

  acts_as_customizable

  def to_s;
    name
  end
end
