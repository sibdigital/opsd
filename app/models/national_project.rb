class NationalProject < ActiveRecord::Base
  self.inheritance_column = nil # иначе колонка type используется для
  # single table inheritance т.е наследования сущностей, хранящихся в одной таблице


  has_many :agreements, foreign_key: 'national_project_id'
  has_many :agreements, foreign_key: 'federal_project_id'

  def option_name
    nil
  end

  def to_s
    name
  end
end

