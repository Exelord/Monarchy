# Usage

The only think you have to do is mark models to be one of part of Monarchy.

You can use 2 available markers:

1. `acts_as_user`
2. `acts_as_resource`

## Acts as user
For your current `User` model or freshly generated one, add or check if exist, `acts_as_user`.
``` ruby
class User < ActiveRecord::Base
  acts_as_user
end
```

> Check documentation of [Acts as user] (https://github.com/Exelord/Monarchy/wiki/Acts-as-user)

## Acts as resource
For all models that you want to be accessible for users add `acts_as_resource`.

> Check documentation of [Acts as resource] (https://github.com/Exelord/Monarchy/wiki/Acts-as-resource)
