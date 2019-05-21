class ControlLevelRole < ActiveRecord::Base
  belongs_to :control_level
  belongs_to :role

  validates_presence_of :role
  validates_presence_of :control_level

  # Add alias, so ControlLevel can still destroy ControlLevelRoles
  # Don't call this from anywhere else, use remove_control_level_role on ControlLevel.
  alias :destroy_for_control_level :destroy

  # You shouldn't call this, only ActiveRecord itself is allowed to do this
  # when destroying a ControlLevel. Use ControlLevel.remove_control_level_role to remove a role from a member.
  #
  # You may remove this once we have a layer above persistence that handles business logic
  # and prevents or at least discourages working on persistence objects from controllers
  # or unrelated business logic.
  def destroy(*args)
    unless caller[2] =~ /has_many_association\.rb:[0-9]+:in `delete_records'/
      raise 'ControlLevelRole.destroy called from method other than HasManyAssociation.delete_records' +
              "\n  on #{inspect}\n from #{caller.first} / #{caller[6]}"
    else
      super
    end
  end

end
