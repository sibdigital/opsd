#-- encoding: UTF-8
#+-xcc 2019.06.23
class Organization < ActiveRecord::Base

    has_many :work_packages, foreign_key: 'organization_id', dependent: :nullify
    #tan(
    has_many :work_package_problems, foreign_key: 'organization_source_id', dependent: :nullify
    has_many :users, foreign_key: 'organization_id', dependent: :nullify
    # )

    acts_as_customizable
    acts_as_journalized

    validates :name, uniqueness: true
    # validates_uniqueness_of :inn, conditions: -> { where.not(is_legal_entity: 0) } # позволяет создавать сколько угодно подразделений с одинаковым инн, пока нет юридического лица с таким инн
    validates :inn, :uniqueness => { :scope => :is_legal_entity }, :if => :is_legal_entity # позволяет создавать сколько угодно подразделений с одинаковым инн, но одно юридическое лицо на один инн

    def option_name
      nil
    end

    def to_s
      name
    end

    def all_fields
      true
    end

    def childs(with_self = true)
      arr = traverse(self.id)
      if with_self
        arr.push self
      end
      arr
    end

    def self.childs(organization, with_self = true)
      traverse(organization.id, with_self)
    end

    private

    def traverse(id)
      elements = []
      ch = Organization.where(parent_id: id)
      elements += ch
      ch.each do |child|
        elements += traverse(child)
      end
      elements
    end
end
