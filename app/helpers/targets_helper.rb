#xcc
#
module TargetsHelper

  def targets_tabs
    tabs = [
      {
        name: 'target',
        action: :edit_project,
        partial: 'targets/target',
        label: :label_target
      },
      {
        name: 'target_execution_values',
        action: :edit_project,
        partial: 'targets/target_execution_values',
        label: :label_target_execution_values
      }
    ]
    tabs.select { |tab| User.current.allowed_to?(tab[:action], @project) }
  end

end
