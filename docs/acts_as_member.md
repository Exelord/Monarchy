# Member
It is a model of class which was registered in Monarchy config and is acting as `acts_as_member`.

## Methods:

### #resource
Returns a resource of member, example:
``` ruby
User was granted to Project so the resource of his Member will be Project
```

### #resource=
You can overwrite a `#resource` for `member` by using:
```ruby
member.resource = new_resource_model
```

## Scopes:

### .accessible_for
You can select all members accessible for specific user by using a scope: `accessible_for`, eg:
``` ruby
Monarchy::member_class.accessible_for(current_user)   # returns [member1, member2, member5]
```

### .with_access_to
You can select all members with access to the specific resource by using a scope: `with_access_to`, eg:
``` ruby
Monarchy::member_class.with_access_to(resource)   # returns [member1, member2, member5]
```

## Public Relations:

### #roles
Returns all roles explicitly assigned to the member.

### #user
Returns a user model of the member.

### #hierarchy
Returns a hierarchy model of the member.
