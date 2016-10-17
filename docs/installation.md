# Installation
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
