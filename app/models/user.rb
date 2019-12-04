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

require 'digest/sha1'

class User < Principal
  USER_FORMATS_STRUCTURE = {
    firstname_lastname:       [:firstname, :lastname],
    firstname:                [:firstname],
    lastname_firstname:       [:lastname, :firstname],
    lastname_coma_firstname:  [:lastname, :firstname],
    username:                 [:login]
  }.freeze

  USER_MAIL_OPTION_ALL            = ['all', :label_user_mail_option_all].freeze
  USER_MAIL_OPTION_SELECTED       = ['selected', :label_user_mail_option_selected].freeze
  USER_MAIL_OPTION_ONLY_MY_EVENTS = ['only_my_events', :label_user_mail_option_only_my_events].freeze
  USER_MAIL_OPTION_ONLY_ASSIGNED  = ['only_assigned', :label_user_mail_option_only_assigned].freeze
  USER_MAIL_OPTION_ONLY_OWNER     = ['only_owner', :label_user_mail_option_only_owner].freeze
  USER_MAIL_OPTION_NON            = ['none', :label_user_mail_option_none].freeze

  MAIL_NOTIFICATION_OPTIONS = [
    USER_MAIL_OPTION_ALL,
    USER_MAIL_OPTION_SELECTED,
    USER_MAIL_OPTION_ONLY_MY_EVENTS,
    USER_MAIL_OPTION_ONLY_ASSIGNED,
    USER_MAIL_OPTION_ONLY_OWNER,
    USER_MAIL_OPTION_NON
  ].freeze

  has_and_belongs_to_many :groups,
                          join_table:   "#{table_name_prefix}group_users#{table_name_suffix}",
                          after_add:    ->(user, group) { group.user_added(user) },
                          after_remove: ->(user, group) { group.user_removed(user) }

  has_many :categories, foreign_key: 'assigned_to_id',
           dependent: :nullify
  has_many :assigned_issues, foreign_key: 'assigned_to_id',
           class_name: 'WorkPackage',
           dependent: :nullify
  has_many :responsible_for_issues, foreign_key: 'responsible_id',
           class_name: 'WorkPackage',
           dependent: :nullify
  has_many :watches, class_name: 'Watcher',
           dependent: :delete_all
  has_many :changesets, dependent: :nullify
  has_many :passwords, -> {
    order('id DESC')
  }, class_name: 'UserPassword',
           dependent: :destroy,
           inverse_of: :user
  has_one :rss_token, class_name: '::Token::Rss', dependent: :destroy
  has_one :api_token, class_name: '::Token::Api', dependent: :destroy
  belongs_to :auth_source

  # Authorized OAuth grants
  has_many :oauth_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: 'resource_owner_id'

  # User-defined oauth applications
  has_many :oauth_applications,
           class_name: 'Doorkeeper::Application',
           as: :owner
  #tan(
  has_many :work_package_problems, foreign_key: 'user_creator_id'
  has_many :work_package_problems, foreign_key: 'user_source_id', dependent: :nullify
  # )
  # +tan tmd
  belongs_to :organization, foreign_key: 'organization_id'
  # -
  # +tan
  belongs_to :direct_manager, foreign_key: 'direct_manager_id', class_name: 'User'
  # -tan
  # +xcc
  belongs_to :position, foreign_key: 'position_id'
  # -

  # Users blocked via brute force prevention
  # use lambda here, so time is evaluated on each query
  scope :blocked, -> { create_blocked_scope(self, true) }
  scope :not_blocked, -> { create_blocked_scope(self, false) }

  def self.create_blocked_scope(scope, blocked)
    scope.where(blocked_condition(blocked))
  end

  def self.blocked_condition(blocked)
    #bbm( block_duration = Setting.brute_force_block_minutes.to_i.minutes
    # blocked_if_login_since = Time.now - block_duration
    blocked_if_login_since = DateTime.strptime("00:00 01.01.1900", "%H:%M %d.%m.%Y")
    # )
    negation = blocked ? '' : 'NOT'

    ["#{negation} (users.failed_login_count >= ? AND users.last_failed_login_on > ?)",
     Setting.brute_force_block_after_failed_logins.to_i,
     blocked_if_login_since]
  end

  acts_as_customizable
  # acts_as_journalized

  attr_accessor :password, :password_confirmation
  attr_accessor :last_before_login_on

  validates_presence_of :login,
                        :firstname,
                        :lastname,
                        :mail,
                        unless: Proc.new { |user| user.is_a?(AnonymousUser) || user.is_a?(DeletedUser) || user.is_a?(SystemUser) }

  validates_uniqueness_of :login, if: Proc.new { |user| !user.login.blank? }, case_sensitive: false
  validates_uniqueness_of :mail, allow_blank: true, case_sensitive: false
  # Login must contain letters, numbers, underscores only
  validates_format_of :login, with: /\A[a-z0-9_\-@\.+ ]*\z/i
  validates_length_of :login, maximum: 256
  validates_length_of :firstname, :lastname, maximum: 30
  #zbd(
  validates_length_of :patronymic, maximum: 30
  validates_format_of :mail_add, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, allow_blank: true
  validates_length_of :mail_add, maximum: 60, allow_nil: true
  validates_format_of :phone_wrk, with: /\A((8|\+7)[\- ]?)?(\(?\d{3}\)?[\- ]?)?[\d\- ]{3,10}\z/i, allow_blank: true
  validates_format_of :phone_wrk_add, with: /\A[0-9]{1,4}\z/i, allow_blank: true
  validates_format_of :phone_mobile, with: /\A^((8|\+7)[\- ]?)?(\(?\d{3}\)?[\- ]?)?[\d\- ]{7,10}\z/i, allow_blank: true
  validates_length_of :address, maximum: 255
  validates_length_of :cabinet, maximum: 6
  #)
  validates_format_of :mail, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, allow_blank: true
  validates_length_of :mail, maximum: 60, allow_nil: true
  validates_confirmation_of :password, allow_nil: true
  validates_inclusion_of :mail_notification, in: MAIL_NOTIFICATION_OPTIONS.map(&:first), allow_blank: true

  validate :login_is_not_special_value
  validate :password_meets_requirements

  after_save :update_password

  before_create :sanitize_mail_notification_setting
  before_create :enforce_user_limit
  before_destroy :delete_associated_private_queries
  before_destroy :reassign_associated

  scope :in_group, ->(group) {
    group_id = group.is_a?(Group) ? group.id : group.to_i
    where(["#{User.table_name}.id IN (SELECT gu.user_id FROM #{table_name_prefix}group_users#{table_name_suffix} gu WHERE gu.group_id = ?)", group_id])
  }
  scope :not_in_group, ->(group) {
    group_id = group.is_a?(Group) ? group.id : group.to_i
    where(["#{User.table_name}.id NOT IN (SELECT gu.user_id FROM #{table_name_prefix}group_users#{table_name_suffix} gu WHERE gu.group_id = ?)", group_id])
  }
  scope :admin, -> { where(admin: true) }

  scope :newest, -> { not_builtin.order(created_on: :desc) }

  def self.unique_attribute
    :login
  end
  prepend ::Mixins::UniqueFinder

  def sanitize_mail_notification_setting
    self.mail_notification = Setting.default_notification_option if mail_notification.blank?
    true
  end

  def current_password
    passwords.first
  end

  def password_expired?
    current_password.expired?
  end

  # create new password if password was set
  def update_password
    if password && auth_source_id.blank?
      new_password = passwords.build(type: UserPassword.active_type.to_s)
      new_password.plain_password = password
      new_password.save

      # force reload of passwords, so the new password is sorted to the top
      passwords.reload

      clean_up_former_passwords
    end
  end

  def reload(*args)
    @name = nil
    @projects_by_role = nil
    @authorization_service = ::Authorization::UserAllowedService.new(self)

    super
  end

  def mail=(arg)
    write_attribute(:mail, arg.to_s.strip)
  end

  def self.search_in_project(query, options)
    options.fetch(:project).users.like(query)
  end

  # Returns the user that matches provided login and password, or nil
  def self.try_to_login(login, password, session = nil, request = nil)
    # Make sure no one can sign in with an empty password
    return nil if password.to_s.empty?
    user = find_by_login(login)
    user = if user
             try_authentication_for_existing_user(user, password, session)
           else
             try_authentication_and_create_user(login, password)
           end
    unless prevent_brute_force_attack(user, login).nil?
      user.log_successful_login(request) if user && !user.new_record?
      return user
    end
    nil
  end

  # Tries to authenticate a user in the database via external auth source
  # or password stored in the database
  def self.try_authentication_for_existing_user(user, password, session = nil)
    activate_user! user, session if session

    return nil if !user.active? || OpenProject::Configuration.disable_password_login?

    if user.auth_source
      # user has an external authentication method
      return nil unless user.auth_source.authenticate(user.login, password)
    else
      # authentication with local password
      return nil unless user.check_password?(password)
      return nil if user.force_password_change
      return nil if user.password_expired?
    end
    user
  end

  def self.activate_user!(user, session)
    if session[:invitation_token]
      token = Token::Invitation.find_by_plaintext_value session[:invitation_token]
      invited_id = token && token.user.id

      if user.id == invited_id
        user.activate!
        token.destroy
        session.delete :invitation_token
      end
    end
  end

  # Tries to authenticate with available sources and creates user on success
  def self.try_authentication_and_create_user(login, password)
    return nil if OpenProject::Configuration.disable_password_login?

    user = nil
    attrs = AuthSource.authenticate(login, password)
    if attrs
      # login is both safe and protected in chilis core code
      # in case it's intentional we keep it that way
      user = new(attrs.except(:login))
      user.login = login
      user.language = Setting.default_language

      if OpenProject::Enterprise.user_limit_reached?
        OpenProject::Enterprise.send_activation_limit_notification_about user

        user.errors.add :base, I18n.t(:error_enterprise_activation_user_limit)
      elsif user.save
        user.reload
        logger.info("User '#{user.login}' created from external auth source: #{user.auth_source.type} - #{user.auth_source.name}") if logger && user.auth_source
      end
    end
    user
  end

  # Returns the user who matches the given autologin +key+ or nil
  def self.try_to_autologin(key)
    token = Token::AutoLogin.find_by_plaintext_value(key)
    # Make sure there's only 1 token that matches the key
    if token
      if (token.created_on > Setting.autologin.to_i.day.ago) && token.user && token.user.active?
        token.user.log_successful_login
        token.user
      end
    end
  end

  # Formats the user's name.
  def name(formatter = nil)
    case formatter || Setting.user_format

    when :firstname_lastname      then "#{firstname} #{lastname}"
    when :lastname_firstname      then "#{lastname} #{firstname}"
    when :lastname_coma_firstname then "#{lastname}, #{firstname}"
    when :firstname               then firstname
    when :username                then login
      #bbm(
    when :lastname_f_p then begin
      fshort = firstname ? firstname[0,1] : ''
      fshort += firstname ? '.' : ''
      pshort = patronymic ? patronymic[0,1] : ''
      pshort += patronymic ? '.' : ''
      "#{lastname} #{fshort}#{pshort}"
    end
      #)
    else
      #zbd "#{firstname} #{lastname}"
      "#{firstname} #{patronymic} #{lastname}"
      #zbd
    end
  end

  # Return user's authentication provider for display
  def authentication_provider
    return if identity_url.blank?
    identity_url.split(':', 2).first.titleize
  end

  def status_name
    STATUSES.keys[status].to_s
  end

  def active?
    status == STATUSES[:active]
  end

  def registered?
    status == STATUSES[:registered]
  end

  def locked?
    status == STATUSES[:locked]
  end

  ##
  # Allows the API and other sources to determine locking actions
  # on represented collections of children of Principals.
  # This only covers the transition from:
  # lockable?: active -> locked.
  # activatable?: locked -> active.
  alias_method :lockable?, :active?
  alias_method :activatable?, :locked?

  def activate
    self.status = STATUSES[:active]
  end

  def register
    self.status = STATUSES[:registered]
  end

  def invite
    self.status = STATUSES[:invited]
  end

  def lock
    self.status = STATUSES[:locked]
  end

  def activate!
    update_attribute(:status, STATUSES[:active])
  end

  def register!
    update_attribute(:status, STATUSES[:registered])
  end

  def invite!
    update_attribute(:status, STATUSES[:invited])
  end

  def invited?
    status == STATUSES[:invited]
  end

  def lock!
    update_attribute(:status, STATUSES[:locked])
  end

  # Returns true if +clear_password+ is the correct user's password, otherwise false
  # If +update_legacy+ is set, will automatically save legacy passwords using the current
  # format.
  def check_password?(clear_password, update_legacy: true)
    if auth_source_id.present?
      auth_source.authenticate(login, clear_password)
    else
      return false if current_password.nil?
      current_password.matches_plaintext?(clear_password, update_legacy: update_legacy)
    end
  end

  # Does the backend storage allow this user to change their password?
  def change_password_allowed?
    return false if uses_external_authentication? ||
      OpenProject::Configuration.disable_password_login?
    return true if auth_source_id.blank?
    auth_source.allow_password_changes?
  end

  # Is the user authenticated via an external authentication source via OmniAuth?
  def uses_external_authentication?
    identity_url.present?
  end

  #
  # Generate and set a random password.
  #
  # Also force a password change on the next login, since random passwords
  # are at some point given to the user, we do this via email. These passwords
  # are stored unencrypted in mail accounts, so they must only be valid for
  # a short time.
  def random_password!
    self.password = OpenProject::Passwords::Generator.random_password
    self.password_confirmation = password
    self.force_password_change = true
    self
  end

  ##
  # Brute force prevention - public instance methods
  #
  def failed_too_many_recent_login_attempts?
    block_threshold = Setting.brute_force_block_after_failed_logins.to_i
    return false if block_threshold == 0  # disabled
    (last_failed_login_within_block_time? and
      failed_login_count >= block_threshold)
  end

  def log_failed_login
    log_failed_login_count
    log_failed_login_timestamp
    save
  end

  def log_successful_login (request = nil)
    update_attribute(:last_login_on, Time.now)
    if !request.nil?
      update_attribute(:last_ip, request.remote_ip)
    end
  end

  def pref
    preference || build_preference
  end

  def time_zone
    @time_zone ||= (pref.time_zone.blank? ? nil : ActiveSupport::TimeZone[pref.time_zone])
  end

  def wants_comments_in_reverse_order?
    pref.comments_in_reverse_order?
  end

  # Return an array of project ids for which the user has explicitly turned mail notifications on
  def notified_projects_ids
    @notified_projects_ids ||= memberships.reload.select(&:mail_notification?).map(&:project_id)
  end

  def notified_project_ids=(ids)
    Member.where(['user_id = ?', id])
      .update_all("mail_notification = #{self.class.connection.quoted_false}")
    Member.where(['user_id = ? AND project_id IN (?)', id, ids])
      .update_all("mail_notification = #{self.class.connection.quoted_true}") if ids && !ids.empty?
    @notified_projects_ids = nil
    notified_projects_ids
  end

  def valid_notification_options
    self.class.valid_notification_options(self)
  end

  #+tmd
  def organization_options
    sql = "SELECT name, id FROM organizations"
    records_array = ActiveRecord::Base.connection.execute(sql)
    result = []

    for i in 0...records_array.values.length
      result.push(records_array[i])
    end
    result
  end
  #-
  #+xcc
  def position_options
    sql = "SELECT name, id FROM positions"
    records_array = ActiveRecord::Base.connection.execute(sql)
    result = []

    for i in 0...records_array.values.length
      result.push(records_array[i])
    end
    result
  end
  #-

  # +tan
  def direct_manager_users
    User.all.to_a || []
  end
  # -tan

  # Only users that belong to more than 1 project can select projects for which they are notified
  def self.valid_notification_options(user = nil)
    # Note that @user.membership.size would fail since AR ignores
    # :include association option when doing a count
    if user.nil? || user.memberships.length < 1
      MAIL_NOTIFICATION_OPTIONS.reject { |option| option.first == 'selected' }
    else
      MAIL_NOTIFICATION_OPTIONS
    end
  end

  # Find a user account by matching the exact login and then a case-insensitive
  # version.  Exact matches will be given priority.
  def self.find_by_login(login)
    # force string comparison to be case sensitive on MySQL
    type_cast = (OpenProject::Database.mysql?) ? 'BINARY' : ''
    # First look for an exact match
    user = where(["#{type_cast} login = ?", login]).first
    # Fail over to case-insensitive if none was found
    user ||= where(["#{type_cast} LOWER(login) = ?", login.to_s.downcase]).first
  end

  def self.find_by_rss_key(key)
    return nil unless Setting.feeds_enabled?
    token = Token::Rss.find_by(value: key)

    if token && token.user.active?
      token.user
    end
  end

  def self.find_by_api_key(key)
    return nil unless Setting.rest_api_enabled?
    token = Token::Api.find_by_plaintext_value(key)

    if token && token.user.active?
      token.user
    end
  end

  ##
  # Finds all users with the mail address matching the given mail
  # Includes searching for suffixes from +Setting.mail_suffix_separtors+.
  #
  # For example:
  #  - With Setting.mail_suffix_separators = '+'
  #  - Will find 'foo+bar@example.org' with input of 'foo@example.org'
  def self.where_mail_with_suffix(mail)
    skip_suffix_check, regexp = mail_regexp(mail)

    # If the recipient part already contains a suffix, don't expand
    return where("LOWER(mail) = ?", mail) if skip_suffix_check

    command =
      if OpenProject::Database.mysql?
        'REGEXP'
      else
        '~*'
      end

    where("LOWER(mail) #{command} ?", regexp)
  end

  ##
  # Finds a user by mail where it checks whether the mail exists
  # NOTE: This will return the FIRST matching user.
  def self.find_by_mail(mail)
    where_mail_with_suffix(mail).first
  end

  def rss_key
    token = rss_token || ::Token::Rss.create(user: self)
    token.value
  end

  def to_s
    name
  end

  # Returns the current day according to user's time zone
  def today
    if time_zone.nil?
      Date.today
    else
      Time.now.in_time_zone(time_zone).to_date
    end
  end

  def logged?
    true
  end

  def anonymous?
    !logged?
  end

  # Return user's roles for project
  def roles_for_project(project)
    roles = []
    # No role on archived projects
    return roles unless project && project.active?
    if logged?
      # Find project membership
      membership = memberships.detect { |m| m.project_id == project.id }
      if membership
        roles = membership.roles
      else
        @role_non_member ||= Role.non_member
        roles << @role_non_member
      end
    else
      @role_anonymous ||= Role.anonymous
      roles << @role_anonymous
    end
    roles
  end

  # +-tan 2019.11.15
  # Return user's roles for project
  def roles_for_project_id(project_id)
    roles = []
    # No role on archived projects
    if logged?
      # Find project membership
      membership = memberships.detect { |m| m.project_id == project_id }
      if membership
        roles = membership.roles
      else
        @role_non_member ||= Role.non_member
        roles << @role_non_member
      end
    else
      @role_anonymous ||= Role.anonymous
      roles << @role_anonymous
    end
    roles
  end

  # Cheap version of Project.visible.count
  def number_of_known_projects
    if admin?
      Project.count
    else
      Project.public_projects.count + memberships.size
    end
  end

  # Return true if the user is a member of project
  def member_of?(project)
    roles_for_project(project).any?(&:member?)
  end

  # Returns a hash of user's projects grouped by roles
  def projects_by_role
    return @projects_by_role if @projects_by_role

    @projects_by_role = Hash.new { |h, k| h[k] = [] }
    memberships.each do |membership|
      membership.roles.each do |role|
        @projects_by_role[role] << membership.project if membership.project
      end
    end
    @projects_by_role.each do |_role, projects|
      projects.uniq!
    end

    @projects_by_role
  end

  # Returns true if user is arg or belongs to arg
  def is_or_belongs_to?(arg)
    if arg.is_a?(User)
      self == arg
    elsif arg.is_a?(Group)
      arg.users.include?(self)
    else
      false
    end
  end

  def self.allowed(action, project)
    Authorization.users(action, project)
  end

  def self.allowed_members(action, project)
    Authorization.users(action, project).where.not(members: { id: nil })
  end

  def allowed_to?(action, context, options = {})
    authorization_service.call(action, context, options).result
  end

  def allowed_to_in_project?(action, project, options = {})
    authorization_service.call(action, project, options).result
  end

  def allowed_to_globally?(action, options = {})
    authorization_service.call(action, nil, options.merge(global: true)).result
  end

  def preload_projects_allowed_to(action)
    authorization_service.preload_projects_allowed_to(action)
  end

  # Utility method to help check if a user should be notified about an
  # event.
  def notify_about?(object)
    active? && (mail_notification == 'all' || (object.is_a?(WorkPackage) && object.notify?(self)))
  end

  def reported_work_package_count
    WorkPackage.on_active_project.with_author(self).visible.count
  end

  #bbm(
  def self.global_role=(id)
    @global_role_id = id
  end

  def self.global_role
    @global_role_id ||= '0'
  end
  # )
  def self.current=(user)
    @current_user = user
  end

  def self.current
    @current_user ||= User.anonymous
  end

  def self.execute_as(user)
    previous_user = User.current
    User.current = user
    yield
  ensure
    User.current = previous_user
  end

  def roles(project)
    User.current.admin? ? Role.all : User.current.roles_for_project(project)
  end

  def all_roles()
    user_roles = Array.new()
    Project.find_each do |project|
      user_roles = user_roles + User.current.roles(project)
    end
    user_roles
  end
  #+tan 2019.07.05
  #project_admin, project_curator, project_customer,
  #  project_office_manager, project_activity_coordinator, project_office_coordinator,
  #  events_responsible, project_head, project_office_admin

  def project_admin?(project)
    roles = User.current.roles_for_project(project)
    roles.find_all{ |r| r.name == Role.project_admin.name}.size > 0
  end

  def project_curator?(project)
    roles = User.current.roles_for_project(project)
    roles.find_all{ |r| r.name == Role.project_curator.name}.size > 0
  end

  def project_customer?(project)
    roles = User.current.roles_for_project(project)
    roles.find_all{ |r| r.name == Role.project_customer.name}.size > 0
  end

  def project_office_manager?(project)
    roles = User.current.roles_for_project(project)
    roles.find_all{ |r| r.name == Role.project_office_manager.name}.size > 0
  end

  def project_activity_coordinator?(project)
    roles = User.current.roles_for_project(project)
    roles.find_all{ |r| r.name == Role.project_activity_coordinator.name}.size > 0
  end

  def project_region_head?(project)
    roles = User.current.roles_for_project(project)
    roles.find_all{ |r| r.name == Role.glava_regiona.name}.size > 0
  end

  def project_office_coordinator?(project)
    roles = User.current.roles_for_project(project)
    roles.find_all{ |r| r.name == Role.project_office_coordinator.name}.size > 0
  end
  # +tan 2019.11.15
  def members_with_roles(roles_names_array)
    slq =  <<-SQL
      select m.*
      from (
             select member_id
             from member_roles mr
                    inner join(
               select id
               from roles as r
               where r.id in (?)
             ) as r
                              on mr.role_id = r.id
      ) as mr
      inner join (
        select * from
        members as m
        where m.user_id = ?
        ) as m
      on mr.member_id = m.id
    SQL
    roles_ids = Role.where(name: roles_names_array).map{|r| r.id}
    Member.find_by_sql([slq, roles_ids, id])
  end
  # -tan

  #является координатором от проектного офиса хотя бы по одному проекту
  def detect_project_office_coordinator?()
    poc = Role.find {|r| r.name == Role.project_office_coordinator.name}
    member = memberships.detect { |m| m.roles.where(id: poc.id).size() > 0 }
    member != nil
  end

  #является администратором проекта хотя бы по одному проекту
  def detect_project_administrator?()
    poc = Role.find {|r| r.name == Role.project_admin.name}
    member = memberships.detect { |m| m.roles.where(id: poc.id).size() > 0 }
    member != nil
  end

  #zbd есть ли в списке глобальных ролей
  def detect_in_global?()
    PrincipalRole.find_by(principal_id: User.current.id).present?
  end

  def events_responsible?(project)
    roles = User.current.roles_for_project(project)
    roles.find_all{ |r| r.name == Role.events_responsible.name}.size() > 0
  end

  def project_office_admin?(project)
    roles = User.current.roles_for_project(project)
    roles.find_all{ |r| r.name == Role.project_office_admin.name}.size > 0
  end

  def has_priveleged?(project)
    #+-tan 2019.11.15 добавил РП
    project_admin?(project) || project_curator?(project) || project_customer?(project) || project_office_manager?(project) ||
      project_activity_coordinator?(project) || project_office_coordinator?(project) || project_head?(project) || project_region_head?(project)
  end

  def has_priveleged_id?(project_id)
    #+-tan 2019.11.15 добавил РП
    project_admin_id?(project_id) || project_curator_id?(project_id) || project_customer_id?(project_id) || project_office_manager_id?(project_id) ||
      project_activity_coordinator_id?(project_id) || project_office_coordinator_id?(project_id) || project_head_id?(project_id) || project_region_head_id?(project_id)
  end

  def project_head?(project)
    roles = User.current.roles_for_project(project)
    roles.find_all{ |r| r.name == Role.project_head.name}.size > 0
  end

  def project_head_id?(project_id)
    roles = User.current.roles_for_project(project_id)
    roles.find_all{ |r| r.name == Role.project_head.name}.size > 0
  end

  def events_responsible?(project)
    roles = User.current.roles_for_project(project)
    roles.find_all{ |r| r.name == Role.events_responsible.name}.size > 0
  end
  #-tan 2019.07.05

  ##
  # Returns true if no authentication method has been chosen for this user yet.
  # There are three possible methods currently:
  #
  #   - username & password
  #   - OmniAuth
  #   - LDAP
  def missing_authentication_method?
    identity_url.nil? && passwords.empty? && auth_source.nil?
  end

  # Returns the anonymous user.  If the anonymous user does not exist, it is created.  There can be only
  # one anonymous user per database.
  def self.anonymous
    anonymous_user = AnonymousUser.first
    if anonymous_user.nil?
      (anonymous_user = AnonymousUser.new.tap do |u|
        u.lastname = 'Anonymous'
        u.login = ''
        u.firstname = ''
        #zbd
        u.patronymic = ''
        # zbd
        u.mail = ''
        u.status = 0
      end).save
      raise 'Unable to create the anonymous user.' if anonymous_user.new_record?
    end
    anonymous_user
  end

  def self.system
    system_user = SystemUser.first

    if system_user.nil?
      system_user = SystemUser.new(
        firstname: "",
        lastname: "System",
        patronymic: "",
        login: "",
        mail: "",
        admin: false,
        status: User::STATUSES[:locked],
        first_login: false
      )

      system_user.save(validate: false)

      raise 'Unable to create the automatic migration user.' unless system_user.persisted?
    end

    system_user
  end

  protected

  # Login must not be special value 'me'
  def login_is_not_special_value
    if login.present? && login == 'me'
      errors.add(:login, :invalid)
    end
  end

  # Password requirement validation based on settings
  def password_meets_requirements
    # Passwords are stored hashed as UserPasswords,
    # self.password is only set when it was changed after the last
    # save. Otherwise, password is nil.
    unless password.nil? or anonymous?
      password_errors = OpenProject::Passwords::Evaluator.errors_for_password(password)
      password_errors.each do |error| errors.add(:password, error) end

      if former_passwords_include?(password)
        errors.add(:password,
                   I18n.t(:reused,
                          count: Setting[:password_count_former_banned].to_i,
                          scope: [:activerecord,
                                  :errors,
                                  :models,
                                  :user,
                                  :attributes,
                                  :password]))
      end
    end
  end

  def enforce_user_limit
    return if anonymous?
    return unless active? && OpenProject::Enterprise.user_limit_reached?

    if OpenProject::Enterprise.fail_fast?
      errors.add :base, :user_limit_reached

      throw :abort # prevent user creation
    else
      # allow creation but change status to registered so user cannot login
      register!
    end
  end

  private

  def self.mail_regexp(mail)
    separators = Regexp.escape(Setting.mail_suffix_separators)
    recipient, domain = mail.split('@').map { |part| Regexp.escape(part) }
    skip_suffix_check = recipient.nil? || Setting.mail_suffix_separators.empty? || recipient.match?(/.+[#{separators}].+/)
    regexp = "#{recipient}([#{separators}][^@]+)*@#{domain}"

    [skip_suffix_check, regexp]
  end

  def authorization_service
    @authorization_service ||= ::Authorization::UserAllowedService.new(self)
  end

  def former_passwords_include?(password)
    return false if Setting[:password_count_former_banned].to_i == 0
    ban_count = Setting[:password_count_former_banned].to_i
    # make reducing the number of banned former passwords immediately effective
    # by only checking this number of former passwords
    passwords[0, ban_count].any? { |f| f.matches_plaintext?(password) }
  end

  def clean_up_former_passwords
    # minimum 1 to keep the actual user password
    keep_count = [1, Setting[:password_count_former_banned].to_i].max
    (passwords[keep_count..-1] || []).each(&:destroy)
  end

  def reassign_associated
    substitute = DeletedUser.first

    [WorkPackage, Attachment, WikiContent, News, Comment, Message].each do |klass|
      klass.where(['author_id = ?', id]).update_all ['author_id = ?', substitute.id]
    end

    [TimeEntry, Journal, ::Query].each do |klass|
      klass.where(['user_id = ?', id]).update_all ['user_id = ?', substitute.id]
    end

    JournalManager.update_user_references id, substitute.id
  end

  def delete_associated_private_queries
    ::Query.where(user_id: id, is_public: false).delete_all
  end

  ##
  # Brute force prevention - class methods
  #
  def self.prevent_brute_force_attack(user, login)
    if user.nil?
      register_failed_login_attempt_if_user_exists_for(login)
    else
      block_user_if_too_many_recent_attempts_failed(user)
    end
  end

  def self.register_failed_login_attempt_if_user_exists_for(login)
    user = User.find_by_login(login)
    user.log_failed_login if user.present?
    nil
  end

  def self.reset_failed_login_count_for(user)
    user.update_attribute(:failed_login_count, 0) unless user.new_record?
  end

  def self.block_user_if_too_many_recent_attempts_failed(user)
    if user.failed_too_many_recent_login_attempts?
      user = nil
    else
      reset_failed_login_count_for user
    end

    user
  end

  ##
  # Brute force prevention - instance methods
  #
  def last_failed_login_within_block_time?
    block_duration = Setting.brute_force_block_minutes.to_i.minutes
    last_failed_login_on and
      Time.now - last_failed_login_on < block_duration
  end

  def log_failed_login_count
    if last_failed_login_within_block_time?
      self.failed_login_count += 1
    else
      self.failed_login_count = 1
    end
  end

  def log_failed_login_timestamp
    self.last_failed_login_on = Time.now
  end

  def self.default_admin_account_changed?
    !User.active.find_by_login('admin').try(:current_password).try(:matches_plaintext?, 'admin')
  end
end

class AnonymousUser < User
  validate :validate_unique_anonymous_user, on: :create

  # There should be only one AnonymousUser in the database
  def validate_unique_anonymous_user
    errors.add :base, 'An anonymous user already exists.' if AnonymousUser.any?
  end

  def available_custom_fields
    []
  end

  # Overrides a few properties
  def logged?; false end

  def admin; false end

  def name(*_args); I18n.t(:label_user_anonymous) end

  def mail; nil end

  def time_zone; nil end

  def rss_key; nil end

  def destroy; false end
end

class DeletedUser < User
  validate :validate_unique_deleted_user, on: :create

  default_scope { where(status: STATUSES[:builtin]) }

  # There should be only one DeletedUser in the database
  def validate_unique_deleted_user
    errors.add :base, 'A DeletedUser already exists.' if DeletedUser.any?
  end

  def self.first
    super || create(type: to_s, status: STATUSES[:builtin])
  end

  # Overrides a few properties
  def logged?; false end

  def admin; false end

  def name(*_args); I18n.t('user.deleted') end

  def mail; nil end

  def time_zone; nil end

  def rss_key; nil end

  def destroy; false end
end
