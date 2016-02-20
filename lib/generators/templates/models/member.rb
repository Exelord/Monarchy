class Member < ActiveRecord::Base
  has_and_belongs_to_many :roles
  belongs_to :user
  belongs_to :hierarchy

  validates :user_id, uniqueness: { scope: :hierarchy_id }
end
