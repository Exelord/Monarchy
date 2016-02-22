require 'rails_helper'

describe User, type: :model do
  it { is_expected.to have_many(:members) }

  context '#role_for' do
    let(:member_role) { create(:role, name: :member, level: 1) }
    let(:manager_role) { create(:role, name: :manager, level: 2) }

    let(:user) { create :user }
    let(:project) { create :project }
    let(:memo) { create :memo, parent: project }

    let!(:memo_member) { create(:member, user: user, hierarchy: memo.hierarchy, roles: [member_role]) }
    let!(:project_member) { create(:member, user: user, hierarchy: project.hierarchy, roles: [manager_role]) }

    context 'role is inherited' do
      it { expect(user.role_for(memo)).to eq(manager_role) }
    end

    context 'role in not inherited' do
      let(:manager_role) { create(:role, name: :manager, level: 2, inherited: false) }

      it { expect(user.role_for(memo)).to eq(member_role) }
    end

    context 'user has no direct access to memo' do
      let!(:memo_member) { }

      it { expect(user.role_for(memo)).to eq(manager_role) }
    end

    context 'user has no direct access to project' do
      let!(:project_member) { }

      it { expect(user.role_for(memo)).to eq(member_role) }
    end
  end
end
