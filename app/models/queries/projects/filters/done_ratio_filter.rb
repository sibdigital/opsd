#tmd
class Queries::Projects::Filters::DoneRatioFilter < Queries::Projects::Filters::ProjectFilter
  self.model = Project

  def human_name
    'Процент исполнения'
  end

  def type
    :integer
  end

  def name
    :done_ratio
  end

  def where
    case operator
    when "!"
      "floor(" + model.done_ratio_template + ") != " + values[0]
    when "!*"
      "floor(" + model.done_ratio_template + ") == 0"
    when "*"
      "floor(" + model.done_ratio_template + ") >= 0"
    else
      "floor(" + model.done_ratio_template + ") " + operator + " " + values[0]
    end
  end
end

