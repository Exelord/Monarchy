# Resource

To generate a new resource you can use:
```
rails g monarchy:resource [resource_name]
```
or add to an existing model `acts_as_resource`, eg:
```ruby
class Resource < ActiveRecord::Base
  acts_as_resource
end
```

#### - Options
You can pass an options to `acts_as_resource`:
- `parent_as: :association_name`

  This let you directly assign parent when you assign an association,
  eg:
  ``` ruby
  class Task << ActiveRecord::Base
    acts_as_resource parent_as: :project
    belongs_to :project
  end

  task.update(project: Project.last)
  task.parent  # returns Project.last
  ```

## Methods

### #parent
You can easily assign parent by using `parent=` method, eg:
``` ruby
resource.parent = Project.last
```
and read value by using `parent` method:
``` ruby
resource.parent   # returns Project.last
```

Parents can be only models which have `acts_as_resource`

### #children
You can easily assign children by using `children=` method, eg:
``` ruby
resource.children = [child1, child2, child3]
```
and read value by using `parent` method:
``` ruby
resource.children   # returns [child1, child2, child3]
```
Children can be only models which have `acts_as_resource`

### #ensure_hierarchy
It creates a hierarchy for resource model if it not exist and `automatic_hierarchy` flag is set to true.
If you want to bypass `automatic_hierarchy` flag you can pass `true` to the method params.

### .default_role_name
Returns default role name for the class

### .default_role
Returns default role object `Monarchy::Role` for the class

### Scopes:

### .accessible_for
You can select all resources accessible for specyfic user by using scope: `accessible_for`, eg:
``` ruby
Resource.accessible_for(current_user)   # returns [resource1, resource2, resource5]
```

#### Options
Optionally you can pass extra allowed roles which should be inherited for this request
``` ruby
Resource.accessible_for(current_user, [:blocked, :visitors])   # returns [resource1, resource2, resource5, resource6]
```

You can also determine if read (default role) access in resource should allow to access theirs children

```ruby
Resource.accessible_for(current_user, { parent_access: true })
#                     (GRANTED) project1
#                                  |
#                                  |
#              (GRANTED) project2   project4 (GRANTED cuz it's a parent of granted resource)
#                           |          |
#                           |          |
#                           |       project5 (NOT granted - it's not a child of granted resource)
#                           |
#                           |
#                        project3 (member role - GRANTED)
```

### .in(resource, true)
You can select all resources scoped into another by using scope: `in`:

- If the second argument is `true` (`true` is by default):
``` ruby
Resource.in(Project.first) # returns [resource1, resource5, resource6]
```
It will return for you all `resources` which parent is `Project.first` or one of his children.

- If the second argument is `false`:
``` ruby
Resource.in(Project.first, false) # returns [resource1, resource5]
```
It will return for you all `resources` which parent is `Project.first`


## Relations

### #members
Return all members explicitly granted to the resource.

### #users
Returns all users which have been granted explicitly to the resource.

### #hierarchy
Returns a hierarchy model of the resource. (DO NOT USE UNLESS IS NECESSARY)

## Flags
Every class which is actually the resource (`acts_as_resource`) has available flags.
### .acting_as_resource
If a model class has `acts_as_resource` it returns `true` otherwise method is undefined.
### .parentize_name
If a model class has `acts_as_resource` it returns class name of the parent if has been set by 'parent_as' option.
