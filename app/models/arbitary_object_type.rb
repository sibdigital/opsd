class ArbitaryObjectType < Enumeration
  has_many :arbitary_objects, foreign_key: 'type_id'

  OptionName = :enumeration_arbitary_objects_types

  def option_name
    OptionName
  end

  def objects_count
    arbitary_objects.count
  end

  def transfer_relations(to)
    arbitary_objects.update_all(type_id: to.id)
  end

end
