#-- encoding: UTF-8
#+-xcc 2019.06.23
class Organization < ActiveRecord::Base
    has_many :work_packages, foreign_key: 'organization_id', dependent: :nullify

    acts_as_customizable

    has_and_belongs_to_many :custom_fields, -> {
      order("#{CustomField.table_name}.position")
    },
                            class_name: 'OrganizationCustomField',
                            join_table: "#{table_name_prefix}organizations#{table_name_suffix}",
                            association_foreign_key: 'id'


    # has_and_belongs_to_many :work_package_custom_fields, -> {
    #   order("#{CustomField.table_name}.position")
    # }, class_name: 'WorkPackageCustomField',
    #                         join_table: "#{table_name_prefix}custom_fields_projects#{table_name_suffix}",
    #                         association_foreign_key: 'custom_field_id'

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
end
