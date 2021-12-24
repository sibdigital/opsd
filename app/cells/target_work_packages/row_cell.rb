module TargetWorkPackages
  class RowCell < ::RowCell
    include ::IconsHelper
    include ReorderLinksHelper

    def target_work_package
      model
    end

    def project
      Target.find(model.target_id).project
    end

    def target?
      !Target.where(id: model.target_id).empty?
    end

    def subject
      link_to(target_work_package.subject, project_work_package_path(target_work_package.project_id, target_work_package.id, :targets))
    end

    def start_date
      target_work_package.start_date
    end

    def due_date
      target_work_package.due_date
    end

    def row_css_id
      'row_' + target_work_package.id.to_s
    end

    def row_css_class
      if !due_date.nil?
        now = Date.today
        target_date = due_date
        year = due_date.year
        quarter = due_date.month.div(4)
        target = Target.find(table.target_id)
                     .target_execution_values
                     .where(year: year, quarter: quarter)
        if target_date <= now
          wp_target = model.work_package_targets
                          .where(target_id: table.target_id, year: year, quarter: quarter)
          if wp_target.empty?
            'target_failed'
          elsif target.empty?
            'target_succeed'
          elsif wp_target.first.value < target.first.value
            'target_failed'
          else
            'target_succeed'
          end
        end
      end

    end
  end
end
