class ControlLevel < ActiveRecord::Base
  belongs_to :color
  has_many :control_level_roles, dependent: :destroy, autosave: true
  has_many :work_packages, foreign_key: 'control_level', dependent: :nullify#, class_name: 'Project', foreign_key: 'project_status_id'
  has_many :roles, through: :control_level_roles

  validates_presence_of :name, :code
  validates_length_of :name, maximum: 30
  validates_length_of :code, maximum: 15

  def color_label
    I18n.t('control_levels.edit.control_level_color_text')
  end

  def to_s; name end

  def assign_roles(roles_or_role_ids)
    do_assign_roles(roles_or_role_ids, false)
  end

  def do_assign_roles(roles_or_role_ids, save_and_possibly_destroy)
    # ensure we have integer ids
    ids = roles_or_role_ids.map { |r| (r.is_a? Role) ? r.id : r.to_i }

    new_role_ids = ids - role_ids
    # Add new roles
    # Do this before destroying them, otherwise the Member is destroyed due to not having any
    # Roles assigned via MemberRoles.
    new_role_ids.each do |id| do_add_role(id, save_and_possibly_destroy) end

    control_level_roles_to_destroy = control_level_roles.select { |clr| !ids.include?(clr.role_id) }
    control_level_roles_to_destroy.each { |clr| do_remove_control_level_role(clr, save_and_possibly_destroy) }
  end

  def do_add_role(role_or_role_id, save_immediately)
    id = (role_or_role_id.is_a? Role) ? role_or_role_id.id : role_or_role_id

    if save_immediately
      control_level_roles << ControlLevelRole.new.tap do |control_level_role|
        control_level_role.role_id = id
      end
    else
      control_level_roles.build.tap do |control_level_role|
        control_level_role.role_id = id
      end
    end
  end

  def do_remove_control_level_role(control_level_role, destroy)
    to_destroy = control_level_roles.detect { |clr| clr.id == control_level_role.id }

    if destroy
      to_destroy.destroy_for_control_level
    else
      to_destroy.mark_for_destruction
    end
  end
end
