##zbd
#
module StagesHelper

  def stages_tabs
    [
      { name: 'StageInitCustomField', partial: 'stages/tab', label: :label_stage_init },
      { name: 'StageAnalysisCustomField', partial: 'stages/tab', label: :label_stage_analysis },
      { name: 'StagePlanningCustomField', partial: 'stages/tab', label: :label_stage_planning },
      { name: 'StageExecutionCustomField', partial: 'stages/tab', label: :label_stage_execution },
      { name: 'StageControlCustomField', partial: 'stages/tab', label: :label_stage_control },
      { name: 'StageCompletionCustomField', partial: 'stages/tab', label: :label_stage_completion }
    ]
  end

end
