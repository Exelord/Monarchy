# User

You have to add it to your user model or the custom one specified in a config file.

``` ruby
class User < ActiveRecord::Base
  acts_as_user
end
```

## Relations

### .hierarchies
Return all hierarchies in which user is explicitly granted.

### .members
Returns all memberships (`member` model) of the user

## Scopes

### .accessible_for (user)
Returns all users accessible for the specific user
It includes all users from all resource which the user has any access.

### .with_access_to
You can select all users with access to the specific resource by using a scope: `with_access_to`, eg:
``` ruby
Monarchy::user_class.with_access_to(resource)   # returns [user1, user2, user5]
```

## Methods

### #roles_for(resource, inheritance = true)
Returns all roles for the user to the specific `resource`.
You can choose if this method should return also inherited roles or just these, granted explicitly.

### #member_for(resource)
Returns a `member` object for the user in specyfic resource.

### #grant(role_names, resource)
By this method, you can give the user an access to a specific resource.
You can specify a role name or an array of roles names.
**Remember to use `symbols`!**

### #revoke_access(resource)
You can revoke total access of a user from the resource and his children by using this method.
Optionally you can specify `hierarchies` as the second argument from which user's members should be deleted.

### #revoke_role(role_name, resource)
It revokes specified role from a user's member of the resource.
If is it last role and the default for the resource it will raise an error `Monarchy::Exceptions::RoleNotRevokable`. Otherwise, if it's just a last role it will remove the one and grant a user with default one.

**It guaranty that user will have always last role or a default one**

### #revoke_role!(role_name, resource)
It behaves exactly like `#revoke_role` but with one difference during revoking last_role.
Depend on which `revoke_strategy` did you choose in configuration,
it will delete a member after revoking the last role or will revoke an access to the resource.

For more information check the [configuration page](https://github.com/Exelord/Monarchy/wiki/Configuration) and `revoke_strategy` property.
