##xcc
#
module TargetsHelper

  def targets_tabs
    [
      { name: 'StageInitCustomField', partial: 'targets/tab', label: :label_stage_init },
      { name: 'StageCompletionCustomField', partial: 'targets/tab', label: :label_stage_completion }
    ]
  end

end
