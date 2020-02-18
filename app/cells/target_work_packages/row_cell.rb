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
  end
end
