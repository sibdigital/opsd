#-- encoding: UTF-8
#+-xcc 2019.06.23
class Organization < ActiveRecord::Base
    has_many :work_packages, foreign_key: 'organization_id', dependent: :nullify


    validates :name, uniqueness: true
    # validates_uniqueness_of :inn, conditions: -> { where.not(is_legal_entity: 0) } # позволяет создавать сколько угодно подразделений с одинаковым инн, пока нет юридического лица с таким инн
    validates :inn, :uniqueness => { :scope => :is_legal_entity }, :if => :is_legal_entity # позволяет создавать сколько угодно подразделений с одинаковым инн, но одно юридическое лицо на один инн

    def option_name
      nil
    end

    def to_s
      name
    end
end
