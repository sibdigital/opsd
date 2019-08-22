class TargetType < Enumeration
  has_many :targets, foreign_key: 'type_id'

  OptionName = :enumeration_target_types

  def option_name
    OptionName
  end

  def objects_count
    targets.count
  end

  def transfer_relations(to)
    targets.update_all(type_id: to.id)
  end

  def type_name
    name
  end
end
