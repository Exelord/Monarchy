# Installation and Usage

## Install a gem
Add this line to your application's Gemfile:

```ruby
gem 'monarchy'
```

And then execute:

    $ bundle

To create initials migrations and necessary files run:
```
rails g monarchy:setup
```

This will create for you:

1. Migrations:
  - `monarchy_create_users`
  - `monarchy_create_hierarchies`
  - `monarchy_create_memberships`
2. Configuration file in `config/initializers/monarchy`
3. Default `User` model (optional)

**If you want to use your current `User` model just skip generation of: **
 - `db/migrate/monarchy_create_users.rb`
 - `app/models/user.rb`

And add to your current `User` model `acts_as_user`

## Create roles
Go to `rails console` or create a migration with your new roles.

### How to create a role?
Think about your roles structure.
You can access role class through: `Monarchy.role_class`

Below you can find `Role` parameters with description.

#### Properties description

- `name` - `REQUIRED` - `symbol` - name of the role

- `level` - `0 as DEFAULT` - `number` - higher level means higher level of access, eg. Admin has 10, User has 1

- `inherited` - `true by DEFAULT` - `boolean` - defines if role should be down inherited or not
- `inherited_role_id` - `(SELF) as DEFAULT` - `number` - id of role which should be  inherited to lower resources (ROLE HAS TO EXIST), eg.
  - Role `manager` has `inherited_role` as `member` and `inherited` flag has been set to `true`.
  - Example `User` has been granted as `manager` to `Project`.
  - In all resources bellow `Project`, the user will have a `member` role which was down inherited from `manager`

#### Example hash:
``` ruby
hash_with_properties = {
  name: :admin,
  level: 5,
  inherited_role_id: 4,
  inherited: true
}
```

#### Role creating
```ruby
Monarchy.role_class.create(hash_with_properties)
```

## Setup actors

### Mark user as actor
Setup your resources by adding `acts_as_resource` (for docs look to `Resource` page).

For your current `User` model or freshly generated one, add or check if exist, `acts_as_user`.
``` ruby
class User < ActiveRecord::Base
  acts_as_user
end
```

> Check documentation of [Acts as user] (https://github.com/Exelord/Monarchy/wiki/Acts-as-user)

### Mark resources as actors
For all models that you want to be accessible for users and controlled by `Monarchy` add `acts_as_resource`.

> Check documentation of [Acts as resource] (https://github.com/Exelord/Monarchy/wiki/Acts-as-resource)

## Build a tree!
Build Hierarchies and a tree with just one command in `rails console`

``` ruby
Monarchy.rebuild!
```

That's it...
> Have a long monarchy! :)
