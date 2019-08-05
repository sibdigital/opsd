class NationalProject < ActiveRecord::Base
  def option_name
    nil
  end
  self.inheritance_column = nil # иначе колонка type используется для
  # single table inheritance т.е наследования сущностей, хранящихся в одной таблице
end
