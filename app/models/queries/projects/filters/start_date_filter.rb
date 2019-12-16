#tmd
class Queries::Projects::Filters::StartDateFilter < Queries::Projects::Filters::ProjectFilter
  def type
    :datetime_past
  end

  def available?
    User.current.admin?
  end

  def order
    9
  end
end
