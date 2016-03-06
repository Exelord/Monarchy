# Treelify [![Build Status](https://travis-ci.org/Exelord/Treelify.svg?branch=master)](https://travis-ci.org/Exelord/Treelify)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'treelify'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install treelify

## Setup
To create initials migrations and necessary files run:
```
rails g treelify:setup
```

This will create for you:

1. Migrations:
  - `treelify_create_users`
  - `treelify_create_hierarchis`
  - `treelify_create_memberships`


2. Configuration file in `config/initializers/treelify`
3. Default `User` model

**If you want to use your current `User` model just skip generation of: **
 - `db/migrate/treelify_create_users.rb`
 - `app/models/user.rb`

and add `acts_as_user` like:

``` ruby
class User < ActiveRecord::Base
  acts_as_user
end
```

### ** Warning!!! **
This gem uses internal models like `Member`, `Role`, `MemberRoles`, `Hierarchy`, `HierarchyHierarchies`. If you currently use name of one of them you have to remove them.

## Configuration
You can configure Treelify in `config/initializers/treelify.rb` file.

``` ruby
Treelify.configure do |config|
  config.default_role.name = :guest
  config.default_role.level = 0
  config.default_role.inherited = false
end
```

## Usage
1. [Resource Model](#1-resource-model)
2. [User Model]()
2. [Roles]()

### 1. Resource Model
#### Acts as resource
To generate a new resource you can use:
```
rails g treelify:resource [resource_name]
```
or add to an existing model `acts_as_resource`, eg:
```ruby
class Resource < ActiveRecord::Base
  acts_as_resource
end
```

##### - Options
You can pass an options to `acts_as_resource`:
- `parent_as: :[association_name]`

  This let you directly assign parent when you assign an association,
  eg:
  ``` ruby
  resource.update(project: Project.last)
  resource.parent  # returns Project.last
  ```

___
#### #parent
You can easily assign parent by using `parent=` method, eg:
``` ruby
resource.parent = Project.last
```
and read value by using `parent` method:
``` ruby
resource.parent   # returns Project.last
```

Parents can be only models that have `acts_as_resource`

#### #children
You can easily assign children by using `children=` method, eg:
``` ruby
resource.children = [child1, child2, child3]
```
and read value by using `parent` method:
``` ruby
resource.children   # returns [child1, child2, child3]
```
Children can be only models that have `acts_as_resource`

#### .accessible_for
You can select all resources accessible for specyfic user by using scope: `accessible_for`, eg:
``` ruby
Resource.accessible_for(current_user)   # returns [resource1, resource2, resource5]
```

#### .in
You can select all resources scoped into another by using scope: `in`, eg:
``` ruby
Resource.in(Project.first) # returns [resource1, resource5]
```
It will returns for you all `resources` which parent is `Project.first`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/exelord/treelify. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## Development
Gem dependencies:
https://github.com/mceachen/closure_tree
https://github.com/beatrichartz/configurations

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
