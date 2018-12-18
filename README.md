<p align="center">
  <img src="monarchy.png?raw=true" alt="Sublime's custom image"/>
  <a href="https://travis-ci.org/Exelord/Monarchy">
    <img src="https://travis-ci.org/Exelord/Monarchy.svg?branch=master">
  </a>
  <a href="https://gitter.im/Exelord/Monarchy?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge">
    <img src="https://badges.gitter.im/Exelord/Monarchy.svg">
  </a>
  <a href="https://codeclimate.com/github/Exelord/Monarchy">
    <img src="https://codeclimate.com/github/Exelord/Monarchy/badges/gpa.svg">
  </a>
  <a href="https://codeclimate.com/github/Exelord/Monarchy/coverage">
    <img src="https://codeclimate.com/github/Exelord/Monarchy/badges/coverage.svg" />
  </a>
</p>

Monarchy is a ruby gem offering a complete solution to manage an authorization access in Ruby on Rails applications. A hierarchical structure as well as built-in roles inheritance options make it the most powerful tool to control access to application data resources.

Thanks to [closure_tree](https://github.com/mceachen/closure_tree) - a gem used to manage binary trees - Monarchy can deliver the best-in-class algorithmic performance and enables developers to forget about hierarchies and complicated structures.

If you feel limited while using rolify, feel free to use Monarchy with its advanced capacity to inherit roles and collect all accessible resources with just one method.

## Usage Example
After Monarchy setup you can enjoy with roles inheritance and accessible resources.

```ruby
# Create roles
admin_role = Monarchy.role_class.create(name: :admin, level: 5, inherited: true)
manager_role = Monarchy.role_class.create(name: :manager, level: 4, inherited_role: admin_role, inherited: true)

# Create resources
project1 = Project.create()
project2 = Project.create(parent: project1)
project3 = Project.create(parent: project2)
project4 = Project.create(parent: project1)

# Grant user
user.grant(:manager, project2)

# Accessible projects
Project.accessible_for(user)  # returns [project1, project2, project3]

# User inherited roles
user.roles_for(project1) # returns a default role eg. [guest_role]
user.roles_for(project2) # returns [manager_role]
user.roles_for(project3) # returns [admin_role]
user.roles_for(project4) # returns empty array []

# Graphical visualization

#                              project1 (default role, eg. guest)
#                                 |
#                                 |
#   (granted as manager) project2   project4 (no access)
#                           |
#                           |
#                        project3 (admin | inherited role from manager_role)
```

## Requirements
Monarchy requires:
  - Ruby 2.3

## Documentation
We are preparing an official [website][5c7e0096] with documentation.
Meanwhile you can look to the `docs` directory for actual [documentation](https://github.com/Exelord/Monarchy/tree/master/docs).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/exelord/Monarchy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

This version of the gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[5c7e0096]: https://exelord.github.io/Monarchy/ "Monarchy Website"
