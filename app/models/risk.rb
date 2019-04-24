#-- encoding: UTF-8
# This file written by BBM
# 23/04/2019

class Risk < ActiveRecord::Base
  #сортирует по порядку в таблицах и т.д.
  default_scope { order("#{Risk.table_name}.position ASC") }

  belongs_to :project

  #учитывает сортировку при создании элементов, т.е. заполняет поле position
  acts_as_list scope: 'type = \'#{type}\''

  #удаление должно быть каскадное, пока нечего каскадить

  validates_presence_of :name
  validates_length_of :name, maximum: 30 #не знаю зачем, но пусть будет

  #отфильтровывает часть элементов при работе с TypedRisks
  scope :shared, -> { where(project_id: nil) }

  # let all child classes have Risk as it's model name
  # used to not having to create another route for every subclass of Risk
  def self.inherited(child)
    child.instance_eval do
      def model_name
        Risk.model_name
      end
    end
    super
  end

  #Я знаю точно, что все наследные классы должны быть colored?==true
  def self.colored?
    true
  end

  # Overloaded on concrete classes
  def option_name
    nil
  end

  #ХЗ зачем и где используется, но пусть будет, это же всего лишь простое сравнение
  def <=>(risk)
    position <=> risk.position
  end

  def to_s; name end
end
