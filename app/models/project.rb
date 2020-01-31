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

class Project < ActiveRecord::Base
  extend Pagination::Model
  extend FriendlyId

  include Project::Copy
  include Project::Storage
  include Project::Activity
  include Project::DoneRatio

  # Project statuses
  STATUS_ACTIVE     = 1
  STATUS_ARCHIVED   = 9

  self.inheritance_column = nil # иначе колонка type используется для
  # single table inheritance т.е наследования сущностей, хранящихся в одной таблице

  #zbd(
  # Project types
  TYPE_PROJECT    = 'project'
  TYPE_TEMPLATE   = 'template'
  #)

  # Maximum length for project identifiers
  IDENTIFIER_MAX_LENGTH = 100

  # reserved identifiers
  RESERVED_IDENTIFIERS = %w( new )

  # Specific overridden Activities
  has_many :time_entry_activities
  has_many :members, -> {
    includes(:user, :roles)
      .where(
        "#{Principal.table_name}.type='User' AND (
          #{User.table_name}.status=#{Principal::STATUSES[:active]} OR
          #{User.table_name}.status=#{Principal::STATUSES[:invited]}
        )"
      )
      .references(:users, :roles)
  }

  has_many :possible_assignee_members, -> {
    includes(:principal, :roles)
      .where(Project.possible_principles_condition)
      .references(:principals, :roles)
  }, class_name: 'Member'
  # Read only
  has_many :possible_assignees, -> (object){
    # Have to reference members and roles again although
    # possible_assignee_members does already specify it to be able to use the
    # Project.possible_principles_condition there
    #
    # The .where(members_users: { project_id: object.id })
    # part is an optimization preventing to have all the members joined
    includes(members: :roles)
      .where(members_users: { project_id: object.id })
      .references(:roles)
      .merge(Principal.order_by_name)
  },
  through: :possible_assignee_members,
  source: :principal
  has_many :possible_responsible_members, -> {
    includes(:principal, :roles)
      .where(Project.possible_principles_condition)
      .references(:principals, :roles)
  }, class_name: 'Member'
  # Read only
  has_many :possible_responsibles,
           ->(object) {
             # Have to reference members and roles again although
             # possible_responsible_members does already specify it to be able to use
             # the Project.possible_principles_condition there
             #
             # The .where(members_users: { project_id: object.id })
             # part is an optimization preventing to have all the members joined
             includes(members: :roles)
               .where(members_users: { project_id: object.id })
               .references(:roles)
               .merge(Principal.order_by_name)
           },
           through: :possible_responsible_members,
           source: :principal
  has_many :memberships, class_name: 'Member'
  has_many :member_principals,
           -> {
             includes(:principal)
               .references(:principals)
               .where("#{Principal.table_name}.type='Group' OR " +
               "(#{Principal.table_name}.type='User' AND " +
               "(#{Principal.table_name}.status=#{Principal::STATUSES[:active]} OR " +
               "#{Principal.table_name}.status=#{Principal::STATUSES[:registered]} OR " +
               "#{Principal.table_name}.status=#{Principal::STATUSES[:invited]}))")
           },
           class_name: 'Member'
  has_many :users, through: :members
  has_many :principals, through: :member_principals, source: :principal
  acts_as_journalized
  has_many :enabled_modules, dependent: :delete_all
  has_and_belongs_to_many :types, -> {
    order("#{::Type.table_name}.position")
  }
  has_many :work_packages, -> {
    order("#{WorkPackage.table_name}.created_at DESC")
      .includes(:status, :type)
  }
  has_many :work_package_changes, through: :work_packages, source: :journals
  has_many :versions, -> {
    order("#{Version.table_name}.effective_date DESC, #{Version.table_name}.name DESC")
  }, dependent: :destroy
  has_many :time_entries, dependent: :delete_all
  has_many :queries, dependent: :delete_all
  has_many :news, -> { includes(:author) }, dependent: :destroy
  has_many :categories, -> { order("#{Category.table_name}.name") }, dependent: :delete_all
  has_many :boards, -> { order('position ASC') }, dependent: :destroy
  has_one :repository, dependent: :destroy
  has_many :changesets, through: :repository
  has_one :wiki, dependent: :destroy
  # Custom field for the project's work_packages
  has_and_belongs_to_many :work_package_custom_fields, -> {
    order("#{CustomField.table_name}.position")
  }, class_name: 'WorkPackageCustomField',
     join_table: "#{table_name_prefix}custom_fields_projects#{table_name_suffix}",
     association_foreign_key: 'custom_field_id'

  #tmd
  #has_one :address, dependent: :destroy
  #accepts_nested_attributes_for :address, :reject_if => :all_blank

  #bbm(
  has_many :project_risks
  belongs_to :national_project, -> { where(type: 'National') }, class_name: "NationalProject", foreign_key: "national_project_id"
  belongs_to :federal_project, -> { where(type: 'Federal') }, class_name: "NationalProject", foreign_key: "federal_project_id"
  # )

  #zbd(
  has_many :stages, dependent: :destroy

  has_many :stakeholder_users, dependent: :destroy
  has_many :stakeholder_organizations, dependent: :destroy
  has_many :stakeholder_outers, dependent: :destroy
  # )
  #xcc(
  has_many :targets
  has_many :arbitary_objects
  has_many :agreements
  # )
  #tan(
  has_many :work_package_problems, foreign_key: 'work_package_id'
  has_many :work_package_targets, foreign_key: 'work_package_id'
  has_many :work_package_quarterly_targets, foreign_key: 'project_id'
  has_many :plan_fact_yearly_target_values, foreign_key: 'project_id'
  has_many :plan_quarterly_target_values, foreign_key: 'project_id'
  has_many :plan_fact_quarterly_target_values, foreign_key: 'project_id'
  # )
  # knm(
  has_many :target_calc_procedures
  after_save :create_default_board
  # )
  #tan(
  def get_project_approve_status
    if project_approve_status_id == nil
      ProjectApproveStatus.default
    else
      begin
        ProjectApproveStatus.find(project_approve_status_id)
      rescue
        ProjectApproveStatus.default
      end
    end
  end

  def get_project_status
    if project_status_id == nil
      ProjectStatus.default
    else
      begin
        ProjectStatus.find(project_status_id)
      rescue
        ProjectStatus.default
      end
    end
  end

  def get_allowed_project_statuses
    ProjectStatus.all
  end

  def get_allowed_project_approve_status
    if User.current.admin? && false
      statuses = ProjectApproveStatus.all
    else
      statuses = ProjectApproveStatus.where name: I18n.t(:default_project_approve_status_init)

      if User.current.project_head? self
        statuses += ProjectApproveStatus.where name: I18n.t(:default_project_approve_status_approve_project_head)
      elsif User.current.project_office_coordinator? self
        statuses += ProjectApproveStatus.where name: I18n.t(:default_project_approve_status_agreed_project_office_coordinator)
      elsif User.current.project_office_manager? self
        statuses += ProjectApproveStatus.where name: I18n.t(:default_project_approve_status_agreed_project_office_manager)
      elsif User.current.project_curator? self
        statuses += ProjectApproveStatus.where name: I18n.t(:default_project_approve_status_approve_curator)
      elsif User.current.project_activity_coordinator? self
        statuses += ProjectApproveStatus.where name: I18n.t(:default_project_approve_status_approve_glava)
      end
    end
    statuses
  end

  #tmd
  def get_national_projects
    NationalProject.where(:type => "National")
  end

  def get_federal_projects
    NationalProject.where(:type => "Federal")
  end

  # def full
  #   sql = "SELECT u.first_name, u.last_name, p.due_date FROM projects p JOIN members m ON p.id = m.project_id JOIN users u ON u.id = m.project_id"
  #   records_array = ActiveRecord::Base.connection.execute(sql).values
  #
  #   records_array
  #
  # end
  def get_default_board
    default_board = Board.find_by(project_id: self.id, is_default: true)
    if default_board.nil?
      default_board = Board.find_by(project_id: self.id)
      if default_board.nil?
        default_board = nil
      end
    end
    default_board
  end

  def curator
    role_name_curator = I18n.t(:default_role_project_curator)
    sql = "
    with curators as(
        select  name, id
        from roles as r
        where r.name = '#{role_name_curator}'
    ),
    members_curator as (
        select member_id, role_id
        from member_roles as mr
                 inner join curators on
            mr.role_id = curators.id
    )

    select users.id, login,
    coalesce(firstname,'') as firstname,
    coalesce(lastname,'') as lastname,
    coalesce(patronymic,'') as patronymic
    from
    (select *
        from members as m
        where project_id = #{id}
    ) as proj_members
    inner join members_curator on proj_members.id = members_curator.member_id
    inner join users on proj_members.user_id = users.id"

    records_array = ActiveRecord::Base.connection.execute(sql)
    # curator_name = records_array[0]['firstname'] + " " + records_array[0]['lastname']

    if records_array.any?
      arr = records_array[0]
      arr['fio'] = arr['lastname'] + ' ' + arr['firstname'].slice(0...1) +'.' + arr['patronymic'].slice(0...1)+'.'
      arr
    else
      arr = []
      arr
    end
  end

  def rukovoditel
    role_name_rukovoditel = I18n.t(:default_role_project_head)
    sql = "
    with rukovoditel as(
        select  name, id
        from roles as r
        where r.name = '#{role_name_rukovoditel}'
    ),
    members_rukovoditel as (
        select member_id, role_id
        from member_roles as mr
                 inner join rukovoditel on
            mr.role_id = rukovoditel.id
    )

    select users.id, login,
    coalesce(firstname,'') as firstname,
    coalesce(lastname,'') as lastname,
    coalesce(patronymic,'') as patronymic
    from
    (select *
        from members as m
        where project_id = #{id}
    ) as proj_members
    inner join members_rukovoditel on proj_members.id = members_rukovoditel.member_id
    inner join users on proj_members.user_id = users.id"

    records_array = ActiveRecord::Base.connection.execute(sql)
    #rukovoditel_name = records_array[0]['firstname'] + " " + records_array[0]['lastname']

    if records_array.any?
      arr = records_array[0]
      arr['fio'] = arr['lastname'] + ' ' + arr['firstname'].slice(0...1) + '.' + arr['patronymic'].slice(0...1)+'.'
      arr
    else
      arr = []
      arr
    end
  end

  def get_due_date
    sql = "select due_date from projects where id = #{id}"
    records_array = ActiveRecord::Base.connection.execute(sql)

    if records_array.any?
      arr = records_array[0]
      arr
    else
      arr = []
      arr
    end
  end

  # эти статусы необходимы для того, чтобы соблюсти требования ТТ (стр 27) - ProjectStatus
  # ProjectApproveStatus - для соблюдения 469 постановления, чтобы с помощью эжтого статуса можно было проводить
  # согласование
  # поле status используется чтобы передавать проект в архив т.е могут быть завершенные проекты, но в архив их
  # передавать еще рано, например по ним проводится анализ или есть связанные с ними проекты
  #belongs_to :project_approve_status#, class_name: 'ProjectApproveStatus'#, foreign_key: 'project_approve_status_id'
  #belongs_to :project_status#, class_name: 'ProjectStatus', foreign_key: 'project_status_id'
  #   #)

  acts_as_nested_set order_column: :name, dependent: :destroy

  acts_as_customizable
  acts_as_searchable columns: ["#{table_name}.name", "#{table_name}.identifier", "#{table_name}.description"], project_key: 'id', permission: nil
  acts_as_event title: Proc.new { |o| "#{Project.model_name.human}: #{o.name}" },
                url: Proc.new { |o| { controller: '/projects', action: 'show', id: o } },
                author: nil,
                datetime: :created_on

  validates_presence_of :name, :identifier
  # TODO: we temporarily disable this validation because it leads to failed tests
  # it implicitly assumes a db:seed-created standard type to be present and currently
  # neither development nor deployment setups are prepared for this
  # validates_presence_of :types
  validates_uniqueness_of :identifier
  validates_associated :repository, :wiki
  validates_length_of :name, maximum: 255
  validates_length_of :identifier, in: 1..IDENTIFIER_MAX_LENGTH
  # starts with lower-case letter, a-z, 0-9, dashes and underscores afterwards
  validates :identifier,
            format: { with: /\A[a-z][a-z0-9\-_]*\z/ },
            if: -> (p) { p.identifier_changed? }
  # reserved words
  validates_exclusion_of :identifier, in: RESERVED_IDENTIFIERS

  friendly_id :identifier, use: :finders

  before_destroy :delete_all_members
  before_destroy :destroy_all_work_packages

  scope :has_module, ->(mod) {
    where(["#{Project.table_name}.id IN (SELECT em.project_id FROM #{EnabledModule.table_name} em WHERE em.name=?)", mod.to_s])
  }
  #scope :active, -> { where(status: STATUS_ACTIVE) }
  #scope :public_projects, -> { where(is_public: true) }
  #scope :visible, ->(user = User.current) { Project.visible_by(user) }
  #scope :newest, -> { order(created_on: :desc) }

  #zbd(
  scope :visible, ->(user = User.current) { Project.where(type: TYPE_PROJECT).visible_by(user) }
  scope :active, -> { where(status: STATUS_ACTIVE, type: TYPE_PROJECT) }
  scope :public_projects, -> { where(is_public: true, type: TYPE_PROJECT) }
  scope :newest, -> { where(type: TYPE_PROJECT).order(created_on: :desc) }

  scope :projects, -> { where(type: TYPE_PROJECT) }
  scope :templates, -> { where(type: TYPE_TEMPLATE) }
  # )

  def visible?(user = User.current)
    self.active? and (self.is_public? or user.admin? or user.member_of?(self))
  end

  def copy_allowed?
    User.current.allowed_to?(:copy_projects, self) && (parent.nil? || User.current.allowed_to?(:add_subprojects, parent))
  end

  def self.selectable_projects
    Project.visible.select { |p| User.current.member_of? p }.sort_by(&:to_s)
  end

  def self.search_scope(query)
    # overwritten from Pagination::Model
    visible.like(query)
  end

  # end timelines
  def initialize(attributes = nil)
    super

    initialized = (attributes || {}).stringify_keys
    if !initialized.key?('identifier') && Setting.sequential_project_identifiers?
      self.identifier = Project.next_identifier
    end
    if !initialized.key?('is_public')
      self.is_public = Setting.default_projects_public?
    end
    if !initialized.key?('enabled_module_names')
      self.enabled_module_names = Setting.default_projects_modules
    end
    if !initialized.key?('types') && !initialized.key?('type_ids')
      self.types = ::Type.default
    end

    #+tan
    if !initialized.key?('project_status_id')
      self.project_status_id = ProjectStatus.default.id
    end
    if !initialized.key?('project_approve_status_id')
      self.project_approve_status_id = ProjectApproveStatus.default.id
    end
    # -tan
  end

  def possible_members(criteria, limit)
    Principal.active_or_registered.like(criteria).not_in_project(self).limit(limit)
  end

  def add_member(user, roles)
    members.build.tap do |m|
      m.principal = user
      m.roles = Array(roles)
    end
  end

  def add_member!(user, roles)
    add_member(user, roles)
    save
  end
  # Returns all projects the user is allowed to see.
  #
  # Employs the :view_project permission to perform the
  # authorization check as the permissino is public, meaning it is granted
  # to everybody having at least one role in a project regardless of the
  # role's permissions.
  def self.visible_by(user = User.current)
    #zbd allowed_to(user, :view_project)
    allowed_to(user, :view_project).where(type: TYPE_PROJECT)
  end

  # Returns a ActiveRecord::Relation to find all projects for which
  # +user+ has the given +permission+
  def self.allowed_to(user, permission)
    Authorization.projects(permission, user)
  end

  def reload(*args)
    @all_work_package_custom_fields = nil

    super
  end

  # Returns the Systemwide and project specific activities
  def activities(include_inactive = false)
    if include_inactive
      all_activities
    else
      active_activities
    end
  end

  # Will create a new Project specific Activity or update an existing one
  #
  # This will raise a ActiveRecord::Rollback if the TimeEntryActivity
  # does not successfully save.
  def update_or_create_time_entry_activity(id, activity_hash)
    if activity_hash.respond_to?(:has_key?) && activity_hash.has_key?('parent_id')
      create_time_entry_activity_if_needed(activity_hash)
    else
      activity = project.time_entry_activities.find_by(id: id.to_i)
      activity.update_attributes(activity_hash) if activity
    end
  end

  # Create a new TimeEntryActivity if it overrides a system TimeEntryActivity
  #
  # This will raise a ActiveRecord::Rollback if the TimeEntryActivity
  # does not successfully save.
  def create_time_entry_activity_if_needed(activity)
    if activity['parent_id']

      parent_activity = TimeEntryActivity.find(activity['parent_id'])
      activity['name'] = parent_activity.name
      activity['position'] = parent_activity.position

      if Enumeration.overridding_change?(activity, parent_activity)
        project_activity = time_entry_activities.create(activity)

        if project_activity.new_record?
          raise ActiveRecord::Rollback, 'Overridding TimeEntryActivity was not successfully saved'
        else
          time_entries.where(['activity_id = ?', parent_activity.id])
            .update_all("activity_id = #{project_activity.id}")
        end
      end
    end
  end

  # Returns a :conditions SQL string that can be used to find the issues associated with this project.
  #
  # Examples:
  #   project.project_condition(true)  => "(projects.id = 1 OR (projects.lft > 1 AND projects.rgt < 10))"
  #   project.project_condition(false) => "projects.id = 1"
  def project_condition(with_subprojects)
    cond = "#{Project.table_name}.id = #{id}"
    cond = "(#{cond} OR (#{Project.table_name}.lft > #{lft} AND #{Project.table_name}.rgt < #{rgt}))" if with_subprojects
    cond
  end

  def active?
    status == STATUS_ACTIVE
  end

  def archived?
    status == STATUS_ARCHIVED
  end

  def template?
    type == TYPE_TEMPLATE
  end

  # Archives the project and its descendants
  def archive
    # Check that there is no issue of a non descendant project that is assigned
    # to one of the project or descendant versions
    v_ids = self_and_descendants.map(&:version_ids).flatten
    if v_ids.any? && WorkPackage.includes(:project)
                     .where(["(#{Project.table_name}.lft < ? OR #{Project.table_name}.rgt > ?)" +
                        " AND #{WorkPackage.table_name}.fixed_version_id IN (?)", lft, rgt, v_ids])
                     .references(:projects)
                     .first
      return false
    end
    Project.transaction do
      archive!
    end
    true
  end

  # Unarchives the project
  # All its ancestors must be active
  def unarchive
    return false if ancestors.detect { |a| !a.active? }
    update_attribute :status, STATUS_ACTIVE
  end

  # Returns an array of projects the project can be moved to
  # by the current user
  def allowed_parents
    return @allowed_parents if @allowed_parents
    @allowed_parents = Project.allowed_to(User.current, :add_subprojects)
    @allowed_parents = @allowed_parents - self_and_descendants
    if User.current.allowed_to?(:add_project, nil, global: true) || (!new_record? && parent.nil?)
      @allowed_parents << nil
    end
    unless parent.nil? || @allowed_parents.empty? || @allowed_parents.include?(parent)
      @allowed_parents << parent
    end
    @allowed_parents
  end

  def allowed_parent?(p)
    p = guarantee_project_or_nil_or_false(p)
    return false if p == false # have to explicitly check for false

    !((p.nil? && persisted? && allowed_parents.empty?) ||
      (p.present? && allowed_parents.exclude?(p)))
  end

  # Sets the parent of the project with authorization check
  def set_allowed_parent!(p)
    set_parent!(p) if allowed_parent?(p)
  end

  # Sets the parent of the project
  # Argument can be either a Project, a String, a Fixnum or nil
  def set_parent!(p)
    p = guarantee_project_or_nil_or_false(p)
    return false if p == false # have to explicitly check for false

    if p == parent && !p.nil?
      # Nothing to do
      true
    elsif p.nil? || (p.active? && move_possible?(p))
      # Insert the project so that target's children or root projects stay alphabetically sorted
      sibs = (p.nil? ? self.class.roots : p.children)
      to_be_inserted_before = sibs.detect { |c| c.name.to_s.downcase > name.to_s.downcase }
      if to_be_inserted_before
        move_to_left_of(to_be_inserted_before)
      elsif p.nil?
        if sibs.empty?
          # move_to_root adds the project in first (ie. left) position
          move_to_root
        else
          move_to_right_of(sibs.last) unless self == sibs.last
        end
      else
        # move_to_child_of adds the project in last (ie.right) position
        move_to_child_of(p)
      end
      WorkPackage.update_versions_from_hierarchy_change(self)
      true
    else
      # Can not move to the given target
      false
    end
  end

  def types_used_by_work_packages
    ::Type.where(id: WorkPackage.where(project_id: project.id)
                                .select(:type_id)
                                .distinct)
  end

  # Returns an array of the types used by the project and its active sub projects
  def rolled_up_types
    @rolled_up_types ||=
      ::Type.joins(:projects)
      .select("DISTINCT #{::Type.table_name}.*")
      .where(["#{Project.table_name}.lft >= ? AND #{Project.table_name}.rgt <= ? AND #{Project.table_name}.status = #{STATUS_ACTIVE}", lft, rgt])
      .order("#{::Type.table_name}.position")
  end

  # Closes open and locked project versions that are completed
  def close_completed_versions
    Version.transaction do
      versions.where(status: %w(open locked)).each do |version|
        if version.completed?
          version.update_attribute(:status, 'closed')
        end
      end
    end
  end

  # Returns a scope of the Versions on subprojects
  def rolled_up_versions
    @rolled_up_versions ||=
      Version.includes(:project)
      .where(["#{Project.table_name}.lft >= ? AND #{Project.table_name}.rgt <= ? AND #{Project.table_name}.status = #{STATUS_ACTIVE}", lft, rgt])
      .references(:projects)
  end

  # Returns a scope of the Versions used by the project
  def shared_versions
    @shared_versions ||= begin
      r = root? ? self : root

      Version.includes(:project)
      .where("#{Project.table_name}.id = #{id}" +
                                    " OR (#{Project.table_name}.status = #{Project::STATUS_ACTIVE} AND (" +
                                          " #{Version.table_name}.sharing = 'system'" +
                                          " OR (#{Project.table_name}.lft >= #{r.lft} AND #{Project.table_name}.rgt <= #{r.rgt} AND #{Version.table_name}.sharing = 'tree')" +
                                          " OR (#{Project.table_name}.lft < #{lft} AND #{Project.table_name}.rgt > #{rgt} AND #{Version.table_name}.sharing IN ('hierarchy', 'descendants'))" +
                                          " OR (#{Project.table_name}.lft > #{lft} AND #{Project.table_name}.rgt < #{rgt} AND #{Version.table_name}.sharing = 'hierarchy')" +
                                          '))')
      .references(:projects)
    end
  end

  # Returns all versions a work package can be assigned to.  Opposed to
  # #shared_versions this returns an array of Versions, not a scope.
  #
  # The main benefit is in scenarios where work packages' projects are eager
  # loaded.  Because eager loading the project e.g. via
  # WorkPackage.includes(:project).where(type: 5) will assign the same instance
  # (same object_id) for every work package having the same project this will
  # reduce the number of db queries when performing operations including the
  # project's versions.
  def assignable_versions
    @all_shared_versions ||= shared_versions.with_status_open.to_a
  end

  # Returns a hash of project users grouped by role
  def users_by_role
    members.includes(:user, :roles).inject({}) do |h, m|
      m.roles.each do |r|
        h[r.position] ||= []
        h[r.position] << m.user
      end
      h
    end
  end

  # Deletes all project's members
  def delete_all_members
    me = Member.table_name
    mr = MemberRole.table_name
    self.class.connection.delete("DELETE FROM #{mr} WHERE #{mr}.member_id IN (SELECT #{me}.id FROM #{me} WHERE #{me}.project_id = #{id})")
    Member.where(project_id: id).destroy_all
  end

  def destroy_all_work_packages
    work_packages.each do |wp|
      begin
        wp.reload
        wp.destroy
      rescue ActiveRecord::RecordNotFound => e
      end
    end
  end

  # Returns users that should be always notified on project events
  def recipients
    notified_users
  end

  # Returns the users that should be notified on project events
  def notified_users
    # TODO: User part should be extracted to User#notify_about?
    notified_members = members.select do |member|
      setting = member.user.mail_notification

      (setting == 'selected' && member.mail_notification?) || setting == 'all'
    end

    notified_members.map(&:user)
  end

  # +-tan 2019.11.30
  # Returns the all users that should be notified on project events
  def all_notified_users
    members.map(&:user)
  end

  # Returns an array of all custom fields enabled for project issues
  # (explictly associated custom fields and custom fields enabled for all projects)
  #
  # Supports the :include option.
  def all_work_package_custom_fields(options = {})
    @all_work_package_custom_fields ||= (
      WorkPackageCustomField.for_all(options) + (
        if options.include? :include
          WorkPackageCustomField.joins(:projects)
            .where(projects: { id: id })
            .includes(options[:include]) # use #preload instead of #includes if join gets too big
        else
          work_package_custom_fields
        end
      )
    ).uniq.sort
  end

  def project
    self
  end

  def <=>(project)
    name.downcase <=> project.name.downcase
  end

  def to_s
    name
  end

  # Returns a short description of the projects (first lines)
  def short_description(length = 255)
    unless description.present?
      return ''
    end

    description.gsub(/\A(.{#{length}}[^\n\r]*).*\z/m, '\1...').strip
  end

  # The earliest start date of a project, based on it's issues and versions
  # def start_date
  #   [
  #     work_packages.minimum('start_date'),
  #     shared_versions.map(&:effective_date),
  #     shared_versions.map(&:start_date)
  #   ].flatten.compact.min
  # end
  #
  # # The latest finish date of an issue or version
  # def due_date
  #   [
  #     work_packages.maximum('due_date'),
  #     shared_versions.map(&:effective_date),
  #     shared_versions.map { |v| v.fixed_issues.maximum('due_date') }
  #   ].flatten.compact.max
  # end

  def overdue?
    active? && !due_date.nil? && (due_date < Date.today)
  end

  # Returns the percent completed for this project, based on the
  # progress on it's versions.
  def completed_percent(options = { include_subprojects: false })
    if options.delete(:include_subprojects)
      total = self_and_descendants.map(&:completed_percent).sum

      total / self_and_descendants.count
    else
      if versions.count > 0
        total = versions.map(&:completed_percent).sum

        total / versions.count
      else
        100
      end
    end
  end

  #bbm(
  def get_budget_fraction(raion_id)
    budget = AllBudgetsHelper.cost_by_project self
    if budget then
      if budget[:total_budget] == 0 then
        0
      else
        budget[:spent] / budget[:total_budget]
      end
    else
      0
    end
  end

  def total_wps
    work_packages.where(:plan_type => :execution).count
  end
  # )

  # Return true if this project is allowed to do the specified action.
  # action can be:
  # * a parameter-like Hash (eg. controller: '/projects', action: 'edit')
  # * a permission Symbol (eg. :edit_project)
  def allows_to?(action)
    if action.is_a? Hash
      allowed_actions.include? "#{action[:controller]}/#{action[:action]}"
    else
      allowed_permissions.include? action
    end
  end

  # tmd
  def create_default_board
    if Board.find_by(project_id: self.id, is_default: true).nil?
      default_board = Board.new
      default_board.project_id = self.id
      default_board.name = "Основная дискуссия проекта"
      default_board.description = "Основная дискуссия проекта"
      default_board.position = 1
      default_board.is_default = true
      default_board.topics_count = 0
      default_board.messages_count = 0
      default_board.save
    end
  end

  def module_enabled?(module_name)
    module_name = module_name.to_s
    enabled_modules.any? { |m| m.name == module_name }
  end

  def enabled_module_names=(module_names)
    if module_names && module_names.is_a?(Array)
      module_names = module_names.map(&:to_s).reject(&:blank?)
      self.enabled_modules = module_names.map { |name| enabled_modules.detect { |mod| mod.name == name } || EnabledModule.new(name: name) }
    else
      enabled_modules.clear
    end
  end

  # Returns an array of the enabled modules names
  def enabled_module_names
    enabled_modules.map(&:name)
  end

  # Returns an array of projects that are in this project's hierarchy
  #
  # Example: parents, children, siblings
  def hierarchy
    parents = project.self_and_ancestors || []
    descendants = project.descendants || []
    parents | descendants # Set union
  end

  # Returns an auto-generated project identifier based on the last identifier used
  def self.next_identifier
    p = Project.order(Arel.sql('created_on DESC')).first
    p.nil? ? nil : p.identifier.to_s.succ
  end

  # builds up a project hierarchy helper structure for use with #project_tree_from_hierarchy
  #
  # it expects a simple list of projects with a #lft column (awesome_nested_set)
  # and returns a hierarchy based on #lft
  #
  # the result is a nested list of root level projects that contain their child projects
  # but, each entry is actually a ruby hash wrapping the project and child projects
  # the keys are :project and :children where :children is in the same format again
  #
  #   result = [ root_level_project_info_1, root_level_project_info_2, ... ]
  #
  # where each entry has the form
  #
  #   project_info = { project: the_project, children: [ child_info_1, child_info_2, ... ] }
  #
  # if a project has no children the :children array is just empty
  #
  def self.build_projects_hierarchy(projects)
    ancestors = []
    result    = []

    projects.sort_by(&:lft).each do |project|
      while ancestors.any? && !project.is_descendant_of?(ancestors.last[:project])
        # before we pop back one level, we sort the child projects by name
        ancestors.last[:children] = ancestors.last[:children].sort_by { |h| h[:project].name.downcase if h[:project].name }
        ancestors.pop
      end

      current_hierarchy = { project: project, children: [] }
      current_tree      = ancestors.any? ? ancestors.last[:children] : result

      current_tree << current_hierarchy
      ancestors << current_hierarchy
    end

    # at the end the root level must be sorted as well
    result.sort_by { |h| h[:project].name.downcase if h[:project].name }
  end

  def self.project_tree_from_hierarchy(projects_hierarchy, level, &block)
    projects_hierarchy.each do |hierarchy|
      project = hierarchy[:project]
      children = hierarchy[:children]
      yield project, level
      # recursively show children
      project_tree_from_hierarchy(children, level + 1, &block) if children.any?
    end
  end

  # Yields the given block for each project with its level in the tree
  def self.project_tree(projects, &block)
    projects_hierarchy = build_projects_hierarchy(projects)
    project_tree_from_hierarchy(projects_hierarchy, 0, &block)
  end

  def self.project_level_list(projects)
    list = []
    project_tree(projects) do |project, level|
      element = {
        project: project,
        level:   level
      }

      element.merge!(yield(project)) if block_given?

      list << element
    end
    list
  end

  def allowed_permissions
    @allowed_permissions ||= begin
      names = enabled_modules.loaded? ? enabled_module_names : enabled_modules.pluck(:name)

      Redmine::AccessControl.modules_permissions(names).map(&:name)
    end
  end

  def allowed_actions
    @actions_allowed ||= allowed_permissions.inject([]) { |actions, permission| actions += Redmine::AccessControl.allowed_actions(permission) }.flatten
  end

  # Returns all the active Systemwide and project specific activities
  def active_activities
    overridden_activity_ids = time_entry_activities.map(&:parent_id)

    if overridden_activity_ids.empty?
      return TimeEntryActivity.shared.active
    else
      return system_activities_and_project_overrides
    end
  end

  # Returns all the Systemwide and project specific activities
  # (inactive and active)
  def all_activities
    overridden_activity_ids = time_entry_activities.map(&:parent_id)

    if overridden_activity_ids.empty?
      return TimeEntryActivity.shared
    else
      return system_activities_and_project_overrides(true)
    end
  end

  # Returns the systemwide active activities merged with the project specific overrides
  def system_activities_and_project_overrides(include_inactive = false)
    if include_inactive
      TimeEntryActivity.shared
        .where(['id NOT IN (?)', time_entry_activities.map(&:parent_id)]) +
        time_entry_activities
    else
      TimeEntryActivity.shared.active
        .where(['id NOT IN (?)', time_entry_activities.map(&:parent_id)]) +
        time_entry_activities.active
    end
  end

  # Archives subprojects recursively
  def archive!
    children.each do |subproject|
      subproject.send :archive!
    end
    update_attribute :status, STATUS_ARCHIVED
  end

  #+tan
  def get_done_ratio #TODO: plan type execution!

    sql = "with
         rels as (
           select from_id, to_id
           from relations as r
           where  hierarchy > 0 and from_id <> to_id
         )
         ,
         only_childs as(
           select distinct to_id as child_id
           from rels
         ),
         wp as(
           select id, done_ratio
           from work_packages as w
           where project_id = #{id}
         ),
         rels_wp as( select distinct w.id as id, from_id
           from wp as w
           inner join rels as r
           on w.id = from_id
         ),
         done_wp as( select distinct w.id as id, done_ratio, from_id, child_id
           from wp as w
           left join rels_wp as r
           on w.id = from_id
           left join only_childs as o
           on w.id = o.child_id
         ),
         only_parents as (select *
           from done_wp as r
           where r.child_id is null or (not r.from_id is null and r.child_id is null)
         )
    select avg(done_ratio) as done_ratio
    from only_parents"
    records_array = ActiveRecord::Base.connection.execute(sql)

    # res = records_array[0]['done_ratio'].to_i
    res = records_array[0]['done_ratio']
    res.to_f.round
  end
  #-tan

  protected

  def self.possible_principles_condition
    condition = Setting.work_package_group_assignment? ?
                  ["(#{Principal.table_name}.type=? OR #{Principal.table_name}.type=?)", 'User', 'Group'] :
                  ["(#{Principal.table_name}.type=?)", 'User']

    condition[0] += " AND (#{User.table_name}.status=? OR #{User.table_name}.status=?) AND roles.assignable = ?"
    condition << Principal::STATUSES[:active]
    condition << Principal::STATUSES[:invited]
    condition << true

    sanitize_sql_array condition
  end

  def guarantee_project_or_nil_or_false(p)
    if p.is_a?(Project)
      p
    elsif p.to_s.blank?
      nil
    else
      p = Project.find_by(id: p)
      return false unless p
      p
    end
  end


end
