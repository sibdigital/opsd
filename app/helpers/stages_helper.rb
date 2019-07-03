##zbd
#
module StagesHelper

  def stages_tabs
    [
      {
        name: 'init',
        action: :edit_project,
        partial: 'stages/init',
        label: :label_stage_init
      },
      {
        name: 'analysis',
        partial: 'stages/analysis',
        label: :label_stage_analysis
      },
      {
        name: 'planning',
        partial: 'stages/planning',
        label: :label_stage_planning
      },
      {
        name: 'execution',
        partial: 'stages/execution',
        label: :label_stage_execution
      },
      {
        name: 'control',
        partial: 'stages/control',
        label: :label_stage_control
      },
      {
        name: 'completion',
        partial: 'stages/completion',
        label: :label_stage_completion
      }
    ]
  end

end
