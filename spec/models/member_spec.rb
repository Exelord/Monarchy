# frozen_string_literal: true
require 'rails_helper'

describe Monarchy::Member, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:hierarchy) }
  it { is_expected.to have_many(:roles).through(:members_roles) }
  it { is_expected.to have_many(:members_roles).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:hierarchy) }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:hierarchy_id) }

  describe 'after create' do
    context 'set default role' do
      let!(:default_role) { create(:role, name: :guest, level: 0, inherited: false) }
      let(:member) { create(:member) }

      it { expect(member.roles).to match_array([default_role]) }
    end
  end
end
