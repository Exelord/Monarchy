# frozen_string_literal: true
require 'rails_helper'

<<<<<<< Updated upstream
describe Monarchy::Role, type: :model do
=======
<<<<<<< Updated upstream
describe Role, type: :model do
=======
describe Monarchy::Role, type: :model do
>>>>>>> Stashed changes
>>>>>>> Stashed changes
  it { is_expected.to have_many(:members).through(:members_roles) }
  it { is_expected.to have_many(:members_roles).dependent(:destroy) }
end
