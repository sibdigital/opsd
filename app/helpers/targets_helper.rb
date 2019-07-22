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

  def get_tree(tree, pid)
    html = ''
    tree.each do |row|
      if row.parent_id == pid
        html = html + '<li>'
        html = html + '  ' +  row.name
        html = html + '  ' + get_tree(tree, row.id)
        html = html + '</li>'
      end
    end
    html ? '<ul>' + html + '</ul>' : ''
  end

end
