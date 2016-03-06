require 'rails_helper'

describe User, type: :model do
  it { is_expected.to have_many(:members) }

  let!(:member_role) { create(:role, name: :member, level: 1) }
  let!(:manager_role) { create(:role, name: :manager, level: 2) }

  let(:user) { create :user }
  let!(:project) { create :project }
  let!(:memo) { create :memo, parent: project }

  describe '#role_for' do
    let!(:memo_member) { create(:member, user: user, hierarchy: memo.hierarchy, roles: [member_role]) }
    let!(:project_member) { create(:member, user: user, hierarchy: project.hierarchy, roles: [manager_role]) }

    context 'user has no direct access to memo' do
      let!(:memo_member) {}

      it { expect(user.role_for(memo)).to eq(manager_role) }
    end

    context 'user has no direct access to project' do
      let!(:project_member) {}

      it { expect(user.role_for(memo)).to eq(member_role) }
    end

    context 'parent role is inherited' do
      it { expect(user.role_for(memo)).to eq(manager_role) }

      context 'model role is inherited' do
        let(:member_role) { create(:role, name: :member, level: 1) }

        it { expect(user.role_for(memo)).to eq(manager_role) }
      end

      context 'model role is not inherited' do
        let(:member_role) { create(:role, name: :member, level: 1, inherited: false) }

        it { expect(user.role_for(memo)).to eq(manager_role) }
      end
    end

    context 'parent role in not inherited' do
      let(:manager_role) { create(:role, name: :manager, level: 2, inherited: false) }

      it { expect(user.role_for(memo)).to eq(member_role) }

      context 'model role is not inherited' do
        let(:member_role) { create(:role, name: :member, level: 1, inherited: false) }

        it { expect(user.role_for(memo)).to eq(member_role) }
      end

      context 'model role is inherited' do
        let(:member_role) { create(:role, name: :member, level: 1) }

        it { expect(user.role_for(memo)).to eq(member_role) }
      end
    end
  end

  describe '#grant' do
    let(:default_role) { Role.find_by_name(Treelify.configuration.default_role.name) }

    context 'inherited resource' do
      subject { user.grant(:manager, memo) }

      it { expect{subject}.to change{Member.count}.by(2) }

      it 'project with default role' do
        subject
        expect(project.members.first.roles).to match_array([default_role])
      end

      it 'memo with selected role' do
        subject
        expect(memo.members.first.roles).to match_array([Role.find_by_name(:manager), default_role])
      end

      it 'with doubled grant' do
        2.times do
          subject
          expect(project.members.first.roles).to match_array([default_role])
          expect(memo.members.first.roles).to match_array([Role.find_by_name(:manager), default_role])
        end
      end
    end

    context 'root resource' do
      subject { user.grant(:manager, project) }

      it { expect{subject}.to change{Member.count}.by(1) }
      it { subject; expect(project.members.first.roles).to match_array([Role.find_by_name(:manager), default_role]) }
    end
  end

  describe '#member_for' do
    let!(:memo_member) { create(:member, user: user, hierarchy: memo.hierarchy, roles: [member_role]) }

    it { expect(user.member_for(memo)).to eq(memo_member) }
  end
end
