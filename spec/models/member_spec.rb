# frozen_string_literal: true
require 'rails_helper'

<<<<<<< Updated upstream
describe Monarchy::Member, type: :model do
=======
<<<<<<< Updated upstream
describe Member, type: :model do
=======
describe Monarchy::Member, type: :model do
>>>>>>> Stashed changes
>>>>>>> Stashed changes
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:hierarchy) }
  it { is_expected.to have_many(:roles).through(:members_roles) }
  it { is_expected.to have_many(:members_roles).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:hierarchy_id) }
  it { is_expected.to validate_presence_of(:hierarchy) }

  describe 'after create' do
    context 'set default role' do
      let(:member) { create(:member) }
<<<<<<< Updated upstream
      let(:default_role) { Monarchy::Role.find_by_name(Monarchy.configuration.default_role.name) }
=======
<<<<<<< Updated upstream
      let(:default_role) { Role.find_by_name(Monarchy.configuration.default_role.name) }
=======
      let(:default_role) { Monarchy::Role.find_by_name(Monarchy.configuration.default_role.name) }
>>>>>>> Stashed changes
>>>>>>> Stashed changes

      subject { member.roles }

      it { is_expected.to eq([default_role]) }
    end
  end
end
