##zbd
#
module StagesHelper

  def stages_tabs
    tabs = [
      {
        name: 'init',
        action: :edit_project,
        partial: 'stages/init',
        label: :label_stage_init
      },
      {
        name: 'analysis',
        action: :edit_project,
        partial: 'stages/analysis',
        label: :label_stage_analysis
      },
      {
        name: 'planning',
        action: :edit_project,
        partial: 'stages/planning',
        label: :label_stage_planning
      },
      {
        name: 'execution',
        action: :edit_project,
        partial: 'stages/execution',
        label: :label_stage_execution
      },
      {
        name: 'control',
        action: :edit_project,
        partial: 'stages/control',
        label: :label_stage_control
      },
      {
        name: 'completion',
        action: :edit_project,
        partial: 'stages/completion',
        label: :label_stage_completion
      }
    ]
    tabs.select { |tab| User.current.allowed_to?(tab[:action], @project) }
  end

end
