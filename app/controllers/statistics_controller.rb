class StatisticsController < ApplicationController
  menu_item :statistics
  before_action :find_optional_project
  accept_key_auth :index
  helper :sort
  include SortHelper
  include CustomFieldsHelper
  include PaginationHelper
  def index
    if params[:commit] == "Применить"
      @tab = "main"
      params[:tab] = "main"
      params[:filter_start_date].blank? ? @filter_start_date = "" : @filter_start_date = params[:filter_start_date]
      params[:filter_end_date].blank? ? @filter_end_date = "" : @filter_end_date = params[:filter_end_date]
      params[:filter_action].blank? ? @filter_action = "" : @filter_action = params[:filter_action]
      params[:filter_type].blank? ? @filter_type = "" : @filter_type = params[:filter_type]
      params[:filter_user].blank? ? @filter_user = "" : @filter_user = params[:filter_user]
    elsif params[:tab].blank?
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
    @existing_types = @statistics.select(:journable_type).distinct.map{|t| [I18n.t("label_filter_type."+t.journable_type.downcase), t.journable_type]}
    @existing_users = @statistics.select(:user_id).distinct.map{|u| [u.user.fio, u.user_id]}
    unless @filter_type.blank?
      @statistics = @statistics.where('journable_type = ?', @filter_type)
    end
    unless @filter_action.blank?
      if @filter_action == "Создание"
        @statistics = @statistics.where('version = ?', 1)
      elsif@filter_action == "Обновление"
        @statistics = @statistics.where('version > ?', 1)
      elsif @filter_action == "Удаление"
        @statistics = @statistics.where('is_deleted = ? AND next is null', true)
      end
    end
    unless @filter_end_date.blank?
      end_of_day = (@filter_end_date.to_date + 1.days).to_s
      @statistics = @statistics.where('created_at between ? and ?', "1000-01-01", end_of_day)
    end
    unless @filter_start_date.blank?
      @statistics = @statistics.where('created_at between ? and ?', @filter_start_date, "3000-01-01")
    end
    unless @filter_user.blank?
      @statistics = @statistics.where('user_id = ?',@filter_user)
    end
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
