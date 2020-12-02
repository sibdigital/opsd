#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2018 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See docs/COPYRIGHT.rdoc for more details.
#++

require 'redmine/access_control'

Redmine::AccessControl.map do |map|
  map.permission :view_project,
                 { projects: [:show],
                   activities: [:index],
                   statistics: [:index],
                   #bbm(
                   project_risk_characts: %i[new create edit update destroy],
                   project_risks: %i[index new create edit update choose_typed
                                   destroy],
                   biblioteka_otchetov: [:index],
                   # )
                   #xcc(
                   #zbd targets: %i[index new create edit update destroy],
                   targets: %i[index edit],
                   arbitary_objects: %i[index new create edit update destroy],
                   agreements: %i[index new create edit update destroy],
                   report_progress_project: %i[index new create edit update destroy],
                   report_wp_by_period: %i[index new create edit update destroy],
                   report_passport: %i[index new create edit update destroy],
                   report_change_request: %i[index new create edit update destroy],
                   #)
                   #zbd(
                   stages: [:show,:init,:control,:execution,:completion,:analysis, :planning, :proceed_init, :cancel_init],
                   stakeholders: %i[index edit new create update destroy],
                   stakeholder_outers: %i[edit new create update destroy],
                   communication_meetings: %i[index edit new create update destroy],
                   communication_requirements: %i[edit new create update destroy],
                   communication_meeting_members: %i[edit new create update destroy],
                   #)
                   #zbd(
                   raions: [:show],
                   contracts: %i[index new create edit update destroy],
                   # knm+
                   target_calc_procedures: [:index, :new, :edit, :destroy],
                   periods: [:show, :edit],
                   control_levels: [:show, :edit]
                   # knm-
                   #)
                   },
                 public: true

  @map_permission = map.permission :search_project,
                                   {search: :index},
                                   public: true
  @map_permission

  map.permission :add_project,
                 { projects: %i[new create],
                   members: [:paginate_users] },
                 require: :loggedin,
                 public: true

  map.permission :edit_project,
                 { projects: %i[edit update custom_fields],
                   project_settings: [:show],
                   project_target: [:index],
                   stages: [:show],
                   members: [:paginate_users] },
                 require: :member

  map.permission :select_project_modules,
                 { projects: :modules },
                 require: :member

  map.permission :manage_members,
                 { members: %i[index new create update destroy autocomplete_for_member] },
                 require: :member

  map.permission :view_members,
                 { members: [:index] }

  map.permission :manage_versions,
                 { project_settings: [:show],
                   versions: %i[new create edit update
                              close_completed destroy] },
                 require: :member

  map.permission :manage_types,
                 { projects: :types },
                 require: :member

  map.permission :add_subprojects,
                 { projects: %i[new create] },
                 require: :member

  map.permission :copy_projects,
                 { copy_projects: %i[copy copy_project copy_t copy_template],
                   members: [:paginate_users] },
                 require: :member
  map.permission :approve_instance,
                 {}

  map.project_module :work_package_tracking do |wpt|
    # Issue categories
    wpt.permission :manage_categories,
                   { project_settings: [:show],
                     categories: %i[new create edit update destroy] },
                   require: :member
    #zbd(
    wpt.permission :manage_contracts,
                   { project_settings: [:show],
                     contracts: %i[new create edit update destroy] },
                   require: :member

    wpt.permission :edit_work_package_target_fact_values,
                   { work_package_targets: %i[index edit update] },
                   require: :member

    wpt.permission :manage_work_package_target_plan_values,
                   work_package_targets: %i[index new create edit update destroy],
                   targets: %i[index new create edit update destroy choose_typed],
                   require: :member

    wpt.permission :view_work_package_targets,
                   { work_package_targets: %i[index] },
                   require: :member

    wpt.permission :manage_work_package_problems,
                   { work_package_problems: %i[new create edit update destroy] },
                   require: :member

    wpt.permission :view_work_package_problems,
                   { work_package_problems: %i[index] },
                   require: :member
    #)
    # Issues
    wpt.permission :view_work_packages,
                   issues: %i[index all show],
                   auto_complete: [:issues],
                   versions: %i[index show status_by],
                   journals: %i[index diff],
                   work_packages: %i[show index],
                   work_packages_api: [:get],
                   #zbd(
                   contracts: %i[index],
                   # )
                   :'work_packages/reports' => %i[report report_details]

    wpt.permission :export_work_packages,
                   work_packages: %i[index all]

    wpt.permission :add_work_packages,
                   issues: %i[new create],
                   :'issues/previews' => :create,
                   work_packages: %i[new new_type preview create],
                   planning_elements: [:create]

    wpt.permission :move_work_packages,
                   { :'work_packages/moves' => %i[new create] },
                   require: :loggedin

    wpt.permission :edit_work_packages,
                   { issues: %i[edit update],
                     :'work_packages/bulk' => %i[edit update],
                     work_packages: %i[edit update new_type
                                     preview quoted],
                     journals: :preview },
                   require: :member

    wpt.permission :add_work_package_notes,
                   work_packages: %i[edit update],
                   journals: [:new]

    wpt.permission :edit_work_package_notes,
                   { journals: %i[edit update] },
                   require: :loggedin

    wpt.permission :edit_own_work_package_notes,
                   { journals: %i[edit update] },
                   require: :loggedin

    wpt.permission :delete_work_packages,
                   { issues: :destroy,
                     work_packages: :destroy,
                     :'work_packages/bulk' => :destroy },
                   require: :member

    wpt.permission :manage_work_package_relations,
                   work_package_relations: %i[create destroy]

    wpt.permission :manage_subtasks,
                   {}
    # Queries
    wpt.permission :manage_public_queries,
                   {},
                   require: :member

    wpt.permission :save_queries,
                   {},
                   require: :loggedin
    # Watchers
    wpt.permission :view_work_package_watchers,
                   {}

    wpt.permission :add_work_package_watchers,
                   {}

    wpt.permission :delete_work_package_watchers,
                   {}
    #Properties
    wpt.permission :edit_type,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_subject,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_description,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_assignee,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_responsible,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_estimated_time,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_remaining_time,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_sed_href,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_result_agreed,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_start_date,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_due_date,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_done_ration,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_required_doc_type,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_category,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_contract,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_fixed_version,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_organization,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_arbitary_object,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_raion,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_period,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_control_level,
                   { work_packages: %i[edit update] },
                   require: :member

    wpt.permission :edit_priority,
                   { work_packages: %i[edit update] },
                   require: :member
  end

  map.project_module :time_tracking do |time|
    time.permission :log_time,
                    { timelog: %i[new create edit update] },
                    require: :loggedin

    time.permission :view_time_entries,
                    timelog: %i[index show],
                    time_entry_reports: [:report]

    time.permission :edit_time_entries,
                    { timelog: %i[new create edit update destroy] },
                    require: :member

    time.permission :edit_own_time_entries,
                    { timelog: %i[new create edit update destroy] },
                    require: :loggedin

    time.permission :manage_project_activities,
                    { project_enumerations: %i[update destroy] },
                    require: :member
  end

  map.project_module :news do |news|
    news.permission :manage_news,
                    { news: %i[new create edit update destroy preview],
                      :'news/comments' => [:destroy] },
                    require: :member

    news.permission :view_news,
                    { news: %i[index show] },
                    public: true

    news.permission :comment_news,
                    :'news/comments' => :create
  end

  map.project_module :wiki do |wiki|
    wiki.permission :manage_wiki,
                    { wikis: %i[edit destroy] },
                    require: :member

    wiki.permission :manage_wiki_menu,
                    { wiki_menu_items: %i[edit update select_main_menu_item
                                        replace_main_menu_item] },
                    require: :member

    wiki.permission :rename_wiki_pages,
                    { wiki: :rename },
                    require: :member

    wiki.permission :change_wiki_parent_page,
                    { wiki: %i[edit_parent_page update_parent_page] },
                    require: :member

    wiki.permission :delete_wiki_pages,
                    { wiki: :destroy },
                    require: :member

    wiki.permission :view_wiki_pages,
                    wiki: %i[index show special date_index]

    wiki.permission :export_wiki_pages,
                    wiki: [:export]

    wiki.permission :view_wiki_edits,
                    wiki: %i[history diff annotate]

    wiki.permission :edit_wiki_pages,
                    wiki: %i[edit update preview add_attachment
                           new new_child create]

    wiki.permission :delete_wiki_pages_attachments,
                    {}

    wiki.permission :protect_wiki_pages,
                    { wiki: :protect },
                    require: :member

    wiki.permission :list_attachments,
                    { wiki: :list_attachments },
                    require: :member
  end

  # +tan
  # map.project_module :repository do |repo|
  #   repo.permission :browse_repository,
  #                   repositories: %i[show browse entry annotate
  #                                  changes diff stats graph]
  #
  #   repo.permission :commit_access,
  #                   {}
  #
  #   repo.permission :manage_repository,
  #                   { repositories: %i[edit create update committers
  #                                    destroy_info destroy] },
  #                   require: :member
  #
  #   repo.permission :view_changesets,
  #                   repositories: %i[show revisions revision]
  #
  #
  #   repo.permission :view_commit_author_statistics,
  #                   {}
  # end
  # -tan

  map.project_module :boards do |board|
    board.permission :manage_boards,
                     { boards: %i[new create edit update move destroy] },
                     require: :member

    board.permission :view_messages,
                     { boards: %i[index show],
                       messages: [:show] },
                     public: true

    board.permission :add_messages,
                     messages: %i[new create reply like quote preview]

    board.permission :edit_messages,
                     { messages: %i[edit update preview] },
                     require: :member

    board.permission :edit_own_messages,
                     { messages: %i[edit update preview] },
                     require: :loggedin

    board.permission :delete_messages,
                     { messages: :destroy },
                     require: :member

    board.permission :delete_own_messages,
                     { messages: :destroy },
                     require: :loggedin
  end

  map.project_module :calendar do |cal|
    cal.permission :view_calendar,
                   :'work_packages/calendars' => [:index]
  end

  map.project_module :activity

  #knm(
  map.permission :desktop,
                 {homescreen: %i[ vkladka1 index ]}

  map.permission :milestones,
                 {homescreen: %i[ vkladka1 index ]}

  map.permission :risks,
                 {homescreen: %i[ vkladka1 index ]}

  map.permission :indicators,
                 {homescreen: %i[ vkladka1 index ]}

  map.permission :costs,
                 {homescreen: %i[ vkladka1 index ]}

  map.permission :kpi,
                 {homescreen: %i[ vkladka1 index ]}

  map.permission :protocol,
                 {homescreen: %i[ vkladka1 index ]}

  map.permission :discussions,
                 {homescreen: %i[ vkladka1 index ]}

  map.permission :rating,
                 {homescreen: %i[ vkladka1 index ]}

  map.permission :municipality,
                 {homescreen: %i[ vkladka1 index ]}

  map.project_module :colorlight do |i_map|
    i_map.permission :view_colorlight,
                     { project_colorlight: %i[ index create] },
                     require: :member
    end
  map.project_module :interactive_map do |i_map|
    i_map.permission :view_interactive_map,
                     { project_interactive_map: %i[ index get_wps] },
                     require: :member
    end
  map.project_module :strategic_map do |i_map|
    i_map.permission :view_strategic_map,
                     { project_strategic_map: %i[ index get_project] },
                     require: :member
  end
  # )
  #bbm(
  map.project_module :project_risks
  # )


  #knm(

  # map.project_module :head_performance_indicator_values do |hpi|
  #   hpi.permission :manage_hpi_values,
  #                  :'head_performance_indicator_values' => [:edit, :update, :new, :destroy],
  #                  require: :member
  #
  #   hpi.permission :view_hpi_values,
  #                  :'head_performance_indicator_values' => [:index],
  #                  require: :member
  # end
  # map.permission
  # map.project_module :national_projects do |natfed|
  #   natfed.permission :manage_national_and_federal_projects,
  #                     :'national_projects' => [:new_government, :edit, :new, :destroy, :edit, :update],
  #                     require: :member
  #   natfed.permission :view_national_and_federal_projects,
  #                     :'national_projets' => [:government_programs, :index, :show],
  #                     require: :member
  # end
  # )
  #zbd(
  map.project_module :stages
  map.project_module :work_package_targets
  # )
  #xcc(
  map.project_module :targets
  map.project_module :arbitary_objects
  map.project_module :agreements
  map.project_module :report_progress_project
  map.project_module :report_wp_by_period
  map.project_module :report_passport
  map.project_module :report_change_request

  # )

end
