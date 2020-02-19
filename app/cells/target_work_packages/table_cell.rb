require_dependency 'target_work_packages/row_cell'
module TargetWorkPackages
  class TableCell < ::TableCell
    def target_id
      options[:target_id]
    end

    def project_id
      options[:project_id]
    end

    def target?
      !Target.where(id: target_id).empty?
    end

    def columns
      ['subject', 'start_date', 'due_date']
    end

    def row_class
      ::TargetWorkPackages::RowCell
    end

    def headers
      [
        ['subject', caption: WorkPackage.human_attribute_name(:subject)],
        ['start_date', caption: WorkPackage.human_attribute_name(:start_date)],
        ['due_date', caption: WorkPackage.human_attribute_name(:due_date)]
      ]
    end
  end
end
