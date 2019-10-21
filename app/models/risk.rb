#-- encoding: UTF-8
# This file written by BBM
# 25/04/2019

class Risk < ActiveRecord::Base
  belongs_to :color
  belongs_to :possibility
  belongs_to :importance
  belongs_to :project_section

  has_many :risk_characts, dependent: :destroy
  acts_as_journalized

  # удаление должно быть каскадное, пока нечего каскадить

  validates_presence_of :name
  #validates_length_of :name, maximum: 30 #не знаю зачем, но пусть будет

  # отфильтровывает элементы на TypedRisks и не TypedRisks
  #scope :shared, -> { where(project_id: nil) }
  # Фильтр по project_id
  #scope :on_project,  -> (project){ where(project_id: project) }

  # Пока еще не известно, нужны ли цвета в значениях рисков, но пока пусть будут нужны
  def self.colored?
    true
  end

  # Overloaded on concrete classes
  # OptionName нужна для локализации, см локаль.yml , конкретно этот - еще не факт
  def option_name
    nil
  end

  # ХЗ зачем и где используется, но пусть будет, это же всего лишь простое сравнение
  def <=>(risk)
    position <=> risk.position
  end

  def to_s; name end
end
