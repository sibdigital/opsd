#-- copyright
# OpenProject Costs Plugin
#
# Copyright (C) 2009 - 2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#++

# A CostObject is an item that is created as part of the project.  These items
# contain a collection of work packages.
class CostObject < ActiveRecord::Base
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :project, -> { where type: Project::TYPE_PROJECT }
  #gly(
  has_many :children, class_name: 'CostObject', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'CostObject', foreign_key: 'parent_id'
  # )
  has_many :work_packages, dependent: :nullify

  #bbm(
  belongs_to :target
  # )
  has_many :cost_entries, through: :work_packages
  has_many :time_entries, through: :work_packages

  include ActiveModel::ForbiddenAttributesProtection

  acts_as_attachable
  acts_as_journalized

  acts_as_event type: 'cost-objects',
                title: Proc.new { |o| "#{I18n.t(:label_cost_object)} ##{o.id}: #{o.subject}" },
                url: Proc.new { |o| { controller: 'cost_objects', action: 'show', id: o.id } }

  validates_presence_of :subject, :project, :author, :kind, :fixed_date
  validates_length_of :subject, maximum: 255
  validates_length_of :subject, minimum: 1

  after_create :send_cost_object_added_mail

  User.before_destroy do |user|
    CostObject.replace_author_with_deleted_user user
  end

  def self.visible(user)
    includes(:project)
      .references(:projects)
      .merge(Project.allowed_to(user, :view_cost_objects))
  end

  #ban
  def visible?(user = User.current)
    !user.nil? && user.allowed_to?(:view_cost_objects, project)
  end

  def initialize(attributes = nil)
    super
    self.author = User.current if self.new_record?
  end

  def copy_from(arg)
    if !arg.is_a?(Hash)
      # turn args into an attributes hash if it is not already (which is the case when called from VariableCostObject)
      arg = (arg.is_a?(CostObject) ? arg : self.class.find(arg)).attributes.dup
    end
    arg.delete('id')
    self.type = arg.delete('type')
    self.attributes = arg
  end

  # Wrap type column to make it usable in views (especially in a select tag)
  def kind
    self[:type]
  end

  def kind=(type)
    self[:type] = type
  end

  # Assign all the work_packages with +version_id+ to this Cost Object
  def assign_work_packages_by_version(version_id)
    version = Version.find_by_id(version_id)
    return 0 if version.nil? || version.fixed_work_packages.blank?

    version.fixed_work_packages.each do |work_package|
      work_package.update_attribute(:cost_object_id, id)
    end

    version.fixed_work_packages.size
  end

  # Change the Cost Object type to another type. Valid types are
  #
  # * FixedCostObject
  # * VariableCostObject
  def change_type(to)
    if [FixedCostObject.name, VariableCostObject.name].include?(to)
      self.type = to
      self.save!
      CostObject.find(id)
    else
      self
    end
  end

  # Amount spent.  Virtual accessor that is overriden by subclasses.
  def spent
    0
  end

  # Budget of labor.  Virtual accessor that is overriden by subclasses.
  def labor_budget
    0.0
  end

  # Budget of material, i.e. all costs besides labor costs.  Virtual accessor that is overriden by subclasses.
  def material_budget
    0.0
  end

  def budget
    material_budget + labor_budget
  end

  def budget_by_cost_type
    0.0
  end

  # Label of the current type for display in GUI.  Virtual accessor that is overriden by subclasses.
  def type_label
    I18n.t(:label_cost_object)
  end

  # Amount of the budget spent.  Expressed as as a percentage whole number
  def budget_ratio
    return 0.0 if budget.nil? || budget == 0.0
    ((spent / budget) * 100).round
  end

  def css_classes
    'cost_object'
  end

  def self.replace_author_with_deleted_user(user)
    substitute = DeletedUser.first

    where(author_id: user.id).update_all(author_id: substitute.id)
  end

  def to_s
    subject
  end

  def name
    subject
  end
  #ban(
  def send_cost_object_added_mail
    @timenow = Time.now.strftime("%d/%m/%Y %H:%M")
    if Setting.notified_events.include?('cost_object_added')
      recipients.uniq.each do |user|
        UserMailer.cost_object_added(user, self, User.current, @timenow).deliver_later
      end
    end
  end
  #)
  # SQL
  # +tan
  def self.by_user (user, cost_types = [])
    CostObject.includes(:cost_entries, :time_entries).where("cost_objects.project_id in (
      select project_id
      from members as m
               inner join projects p on p.id = m.project_id
      where m.user_id = ?
        and p.status = ?)", user.id, Project::STATUS_ACTIVE)
    # projectids = []
    # user.projects.each do |p|
    #   if p.type == Project::TYPE_PROJECT
    #     projectids << p.id
    #   end
    # end
    # #CostType.where('name in (?)', cost_types.map {|ct| ct.id}).map {|ct| ct.id}
    # # ct_ids = cost_types.map {|ct| ct.id}
    # # if ct_ids.size > 0
    # #   CostObject.where('project_id in (?) and', projectids)
    # # else
    # #   CostObject.where('project_id in (?)', projectids)
    # # end
    # CostObject.where('project_id in (?) ', projectids)
  end
  # -tan
end
