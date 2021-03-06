class TargetStatus < Enumeration
  has_many :targets, foreign_key: 'status_id'

  OptionName = :enumeration_target_statuses

  def option_name
    OptionName
  end

  def objects_count
    targets.count
  end

  def transfer_relations(to)
    targets.update_all(status_id: to.id)
  end
end
