# Treelify

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

This will create for you
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
1. [Resource Model]()
2. [User Model]()
2. [Roles]()

### Resource Model

To generate a new resource you can use:
```
rake treelify:resource [resource_name]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/exelord/treelify. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## Development
Gem dependencies:
https://github.com/mceachen/closure_tree
https://github.com/beatrichartz/configurations

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
