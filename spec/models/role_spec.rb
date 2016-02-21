require 'rails_helper'

describe Role, type: :model do
  it { is_expected.to have_and_belong_to_many(:members) }
end
