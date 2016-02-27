require 'rails_helper'

describe Member, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:hierarchy) }
  it { is_expected.to have_many(:roles).through(:members_roles) }
  it { is_expected.to have_many(:members_roles) }

  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:hierarchy_id) }
  it { is_expected.to validate_presence_of(:hierarchy) }
end
