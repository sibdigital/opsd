class StatisticsController < ApplicationController
  menu_item :statistics
  before_action :find_optional_project
  accept_key_auth :index
  helper :sort
  include SortHelper
  include CustomFieldsHelper
  include PaginationHelper
  def index
    if params[:tab].blank?
      @tab = "main"
    else
      @tab = params[:tab]
    end
    sort_columns = {'journable_type' => "#{Journal.table_name}.journable_type", 'journable_id' => "#{Journal.table_name}.journable_id"}
    sort_init 'id', 'asc'
    sort_update sort_columns
    if @tab == "main"
    @statistics =  Journal.where("(journable_type = ? OR
                                                     journable_type = ? OR
                                                     journable_type = ? OR
                                                     journable_type = ? OR
                                                     journable_type = ? OR
                                                     journable_type = ? OR
                                                     journable_type = ? OR
                                                     journable_type = ? OR
                                                     journable_type = ? OR
                                                     journable_type = ?) AND project_id = ?",
                                                    "WorkPackage", "Document", "Message", "Project","Member","News","Meeting" ,"MeetingContent","CostObject", "Board", @project.id).order(sort_clause)
                     .page(page_param)
                     .per_page(per_page_param)
    elsif @tab == "additional"
      project_roles = Journal.where("journable_type = ? AND project_id = ?","MemberRole",@project.id)
      roles_entries = Journal::MemberRoleJournal.where(journal_id: project_roles.map(&:id)).where("role_id =? OR role_id = ?",Role.find_by(name: I18n.t(:default_role_project_head)).id, Role.find_by(name: I18n.t(:default_role_ispolnitel)).id)
      @changeroles = roles_entries.order(sort_clause)
                       .page(page_param)
                       .per_page(per_page_param)
      project_versions = Journal.where("journable_id = ? AND journable_type = ?", @project.id, "Project")
      project_entries = Journal::ProjectJournal.where(journal_id: project_versions.map(&:id))
      project_statuses = Array.new
      project_versions.each do |version|
        if version.version == 1
          entry = project_entries.where(journal_id: version.id).order(id: :asc).first
          project_statuses.push(entry)
        else
          previous_version = project_versions.where(version: version.version-1).order(id: :asc).first
          previous_entry = project_entries.where(journal_id: previous_version.id).order(id: :asc).first
          entry = project_entries.where(journal_id: version.id).order(id: :asc).first
          if previous_entry.project_status_id != entry.project_status_id
            project_statuses.push(entry)
          end
        end
      end
      @changestatuses =ProjectJournal.where(id: project_statuses.map(&:id)).order(sort_clause)
                          .page(page_param)
                          .per_page(per_page_param)

      @wpstats = WorkPackageIspolnStat.where(project_id: @project.id).order(sort_clause)
                   .page(page_param)
                   .per_page(per_page_param)
    end
  end

  private

  def find_optional_project
    return true unless params[:project_id]
    @project = Project.find(params[:project_id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
