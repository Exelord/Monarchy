Monarchy.configure do |config|
  # REQUIRED SETTINGS

  # You have to define which role will be the default one (read only) during inheritance.
  # Example role: :guest
  # Real case on resources:
  # project: (you have no roles)
  #   section: (you have no roles)
  #     task: (you have a member role here)
  # When you ask for user.roles_for(project) you will get a default role (:guest)
  # in case when member role has inherited flag set to true
  # Remember to create that role before setting it up eg:
  # Monarchy::Role.create(name: :guest, inherited: false, level: 0)
  config.inherited_default_role = nil # symbol

  # You have to define user class name or an actor class which respond to acts_as_user in your model.
  # Example of model:
  # class User < ActiveRecord::Base
  #   acts_as_user
  # end
  config.user_class_name = '' # string


  # OPTIONAL SETTINGS

  # If you want to override Member or Role class you have add correct actors to class definition
  # Available: acts_as_member, acts_as_role, acts_as_hierarchy
  # Example:
  # class Member < ActiveRecord::Base
  #   acts_as_member
  # end
  config.role_class_name = 'Monarchy::Role' # string
  config.member_class_name = 'Monarchy::Member' # string
  config.hierarchy_class_name = 'Monarchy::Hierarchy' # string


  # If this option is setup to true all members bellow the destroying one, will be deleted.
  config.members_access_revoke = false # boolean

  # Set the revoke strategy using during '#revoke_role!' method
  # Available: :revoke_member, :revoke_access
  # Default: :revoke_member
  # Info:
  # :revoke_member - after revoking the last role from user's member remove the member
  # :revoke_access - after revoking the last role from user's member
  #                  remove the member, and all members bellow which belongs to the user
  config.revoke_strategy = :revoke_member # symbol
end
