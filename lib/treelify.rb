require 'closure_tree'
require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3",
:database => ":memory:")

require 'treelify/acts_as_user'
require 'treelify/resourcify'
require 'treelify/membership'
require 'treelify/hierarchy'

module Treelify
end
