# frozen_string_literal: true
require 'rails_helper'

describe Member, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:hierarchy) }
  it { is_expected.to have_many(:roles).through(:members_roles) }
  it { is_expected.to have_many(:members_roles) }

  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:hierarchy_id) }
  it { is_expected.to validate_presence_of(:hierarchy) }

  describe 'after create' do
    context 'set default role' do
      let(:member) { create(:member) }
      let(:default_role) { Role.find_by_name(Treelify.configuration.default_role.name) }

      subject { member.roles }

      it { is_expected.to eq([default_role]) }
    end
  end
end
