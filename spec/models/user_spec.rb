# frozen_string_literal: true
require 'rails_helper'

describe User, type: :model do
  it { is_expected.to have_many(:members).dependent(:destroy) }
  it { is_expected.to have_many(:hierarchies).through(:members) }

  let!(:guest_role) { create(:role, name: :guest, level: 0, inherited: false) }
  let!(:member_role) { create(:role, name: :member, level: 1) }
  let!(:manager_role) { create(:role, name: :manager, level: 2) }

  let(:user) { create :user }
  let!(:project) { create :project }
  let!(:memo) { create :memo, parent: project }

  describe '#roles_for' do
    let!(:memo_member) { create(:member, user: user, hierarchy: memo.hierarchy, roles: [member_role]) }
    let!(:project_member) { create(:member, user: user, hierarchy: project.hierarchy, roles: [manager_role]) }

    let(:project_roles) { user.roles_for(project) }
    subject { user.roles_for(memo) }

    context 'inherited_role from higher level' do
      let!(:owner_role) { create(:role, name: :owner, level: 3) }
      let!(:manager_role) { create(:role, name: :manager, level: 2, inherited_role: owner_role) }

      it { is_expected.to match_array([owner_role, member_role]) }

      context 'do not map self roles' do
        let!(:memo_member) { create(:member, user: user, hierarchy: memo.hierarchy, roles: [manager_role]) }
        let!(:project_member) { create(:member, user: user, hierarchy: project.hierarchy, roles: [member_role]) }

        it { is_expected.to eq([manager_role, member_role]) }
      end

      context 'sort roles by name' do
        let!(:manager_role) { create(:role, name: :zzz, level: 2, inherited_role: owner_role) }
        let!(:memo_member) { create(:member, user: user, hierarchy: memo.hierarchy, roles: [manager_role]) }
        let!(:project_member) { create(:member, user: user, hierarchy: project.hierarchy, roles: [member_role]) }

        it { is_expected.to eq([manager_role, member_role]) }
      end
    end

    context 'roles without inheritece' do
      let(:project_roles) { user.roles_for(project, false) }
      subject { user.roles_for(memo, false) }

      it { expect(project_roles).to match_array([manager_role]) }
      it { is_expected.to match_array([member_role]) }

      context 'where memo has no roles' do
        let!(:memo_member) {}

        it { expect(project_roles).to match_array([manager_role]) }
        it { is_expected.to eq([]) }
      end

      context 'when user has access to child of the memo' do
        let!(:child_memo) { create(:memo, parent: memo) }
        let!(:memo_member) { create(:member, user: user, hierarchy: child_memo.hierarchy, roles: [member_role]) }

        it { is_expected.to eq([]) }
      end
    end

    context 'user has no direct access to memo' do
      let!(:memo_member) {}

      it { expect(project_roles).to match_array([manager_role]) }
      it { is_expected.to match_array([manager_role]) }
    end

    context 'user has no direct access to project' do
      let!(:project_member) {}

      it { expect(project_roles).to match_array([guest_role]) }
      it { is_expected.to match_array([member_role]) }

      context 'when there is no memo member ' do
        let!(:memo_member) {}

        it { is_expected.to be_empty }
      end
    end

    context 'returns all roles with the higher level' do
      let(:member_role) { create(:role, name: :member, level: 2) }

      it { expect(project_roles).to match_array([manager_role]) }
      it { is_expected.to eq([manager_role, member_role]) }

      context 'returns non duplicated roles' do
        let!(:project_member) do
          create(:member, user: user,
                          hierarchy: project.hierarchy,
                          roles: [manager_role, member_role])
        end

        it { expect(project_roles).to eq([manager_role, member_role]) }
        it { is_expected.to eq([manager_role, member_role]) }
      end
    end

    context 'parent role is not inherited' do
      let(:manager_role) { create(:role, name: :manager, level: 2, inherited: false) }

      it { expect(project_roles).to match_array([manager_role]) }
      it { is_expected.to match_array([member_role]) }
    end

    context 'when model is not acting_as_resource' do
      subject { user.roles_for(user) }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotResource) }
    end

    context 'when model is nil' do
      subject { user.roles_for(nil) }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ResourceIsNil) }
    end

    context 'when model is not model' do
      subject { user.roles_for('oko') }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotResource) }
    end

    context 'when model is not persist' do
      subject { user.roles_for(build(:memo)) }
      it { is_expected.to match_array([]) }
    end
  end

  describe '#grant' do
    shared_examples 'granted with correct members' do
      it { expect(Monarchy::Member.count).to be(1) }
      it { expect(parent.members).to be_empty }
      it { expect(resource.members.count).to be(1) }
      it { expect(resource.members.first.roles).to match_array([manager_role]) }
    end

    context 'grant multiple roles' do
      let!(:member) { user.grant(:manager, :member, memo) }

      it { expect(member.roles).to match_array([manager_role, member_role]) }
      it { expect(memo.members.first.roles).to match_array([manager_role, member_role]) }
    end

    context 'role does not exist' do
      subject { user.grant(:phantom, memo) }

      it { is_expected_block.to raise_exception(Monarchy::Exceptions::RoleNotExist) }
    end

    context 'memo resource with project as parent' do
      let!(:grant_user) { user.grant(:manager, memo) }

      it_behaves_like 'granted with correct members' do
        let(:resource) { memo }
        let(:parent) { project }
      end

      it 'doubled granted' do
        2.times do
          grant_user
          expect(project.members).to be_empty
          expect(memo.members.first.roles).to match_array([manager_role])
        end
      end
    end

    context 'parent resource' do
      let!(:grant_user) { user.grant(:manager, project) }

      it_behaves_like 'granted with correct members' do
        let(:resource) { project }
        let(:parent) { memo }
      end
    end

    context 'when model is not acting_as_resource' do
      subject { user.grant(:manager, user) }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotResource) }
    end

    context 'when model is nil' do
      subject { user.grant(:manager, nil) }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ResourceIsNil) }
    end

    context 'when model is not model' do
      subject { user.grant(:manager, 'oko') }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotResource) }
    end
  end

  describe '#member_for' do
    let!(:memo_member) { create(:member, user: user, hierarchy: memo.hierarchy, roles: [member_role]) }

    context 'member exist' do
      it { expect(user.member_for(memo)).to eq(memo_member) }
    end

    context 'member not exist' do
      it { expect(user.member_for(project)).to be_nil }
    end

    context 'when model is not acting_as_resource' do
      subject { user.member_for(user) }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotResource) }
    end

    context 'when model is nil' do
      subject { user.member_for(nil) }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ResourceIsNil) }
    end

    context 'when model is not model' do
      subject { user.member_for('oko') }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotResource) }
    end
  end

  describe '#revoke access' do
    let!(:memo2) { create :memo, parent: memo }
    let!(:memo4) { create :memo, parent: memo }
    let!(:memo3) { create :memo, parent: memo2 }

    let(:other_user) { create :user }

    context 'sholud revoke bellow and self' do
      context 'with deafult hierarchy_ids' do
        before do
          user.grant(:manager, project)
          user.grant(:manager, memo3)
          user.grant(:member, memo4)
          other_user.grant(:manager, memo3)

          user.revoke_access(memo2)
        end

        it { expect(project.members.count).to eq(1) }
        it { expect(memo.members.count).to eq(0) }
        it { expect(memo2.members.count).to eq(0) }
        it { expect(memo3.members.count).to eq(1) }
        it { expect(memo4.members.count).to eq(1) }
      end

      context 'with custom hierarchies' do
        before do
          user.grant(:member, project)
          user.grant(:member, memo)
          user.grant(:member, memo3)
          user.grant(:member, memo4)

          user.revoke_access(memo, memo.hierarchy.descendants)
        end

        it { expect(project.members.count).to eq(1) }
        it { expect(memo.members.count).to eq(1) }
        it { expect(memo2.members.count).to eq(0) }
        it { expect(memo3.members.count).to eq(0) }
        it { expect(memo4.members.count).to eq(0) }
      end
    end

    context 'when model is not acting_as_resource' do
      subject { user.revoke_access(user) }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotResource) }
    end

    context 'when model is nil' do
      subject { user.revoke_access(nil) }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ResourceIsNil) }
    end

    context 'when model is not model' do
      subject { user.revoke_access('oko') }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotResource) }
    end
  end

  describe '#revoke role' do
    let!(:memo2) { create :memo, parent: memo }
    let!(:memo3) { create :memo, parent: memo2 }
    let!(:memo4) { create :memo, parent: memo }

    context 'sholud revoke only one role' do
      subject { user.revoke_role(:manager, memo4) }

      before do
        user.grant(:manager, memo4)
        user.grant(:member, memo4)
      end

      it { is_expected_block.to change { Monarchy::MembersRole.count }.by(-1) }
      it { is_expected.to be 1 }

      it do
        subject
        expect(memo4.members.first.roles).to match_array([member_role])
      end
    end

    context 'when user has not member' do
      subject { user.revoke_role(:manager, memo4) }

      it { is_expected_block.not_to change { Monarchy::MembersRole.count } }
      it { is_expected_block.not_to change { Member.count } }
      it { is_expected.to be 0 }
    end

    context 'when revoke last role' do
      before do
        user.grant(:manager, memo3)
      end

      it { expect(memo3.members.first.roles).to match_array([manager_role]) }

      context 'which is manager role' do
        before do
          user.revoke_role(:manager, memo3)
        end

        it { expect(memo3.members.first.roles).to match_array([guest_role]) }

        context 'and then revoke the default one' do
          subject { user.revoke_role(:guest, memo3) }

          it { is_expected_block.to raise_exception(Monarchy::Exceptions::RoleNotRevokable) }
        end
      end
    end

    context 'when model is not acting_as_resource' do
      subject { user.revoke_role(:guest, user) }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotResource) }
    end

    context 'when model is nil' do
      subject { user.revoke_role(:guest, nil) }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ResourceIsNil) }
    end

    context 'when model is not model' do
      subject { user.revoke_role(:guest, 'oko') }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotResource) }
    end
  end

  describe '#revoke role!' do
    let!(:memo2) { create :memo, parent: memo }

    context 'sholud revoke only one role' do
      subject { user.revoke_role!(:manager, memo2) }

      before do
        user.grant(:manager, memo2)
        user.grant(:member, memo2)
      end

      it { is_expected_block.to change { Monarchy::MembersRole.count }.by(-1) }

      it do
        subject
        expect(memo2.members.first.roles).to match_array([member_role])
      end
    end

    context 'when revoke last role' do
      before do
        user.grant(:manager, memo2)
      end

      context 'with revoke_member strategy' do
        subject { user.revoke_role!(:manager, memo2) }

        it { is_expected_block.to change { Member.count }.by(-1) }
      end

      context 'with revoke_access strategy' do
        before do
          Monarchy.configure do |config|
            config.inherited_default_role = :guest
            config.user_class_name = 'User'

            config.role_class_name = 'Role'
            config.member_class_name = 'Member'

            config.members_access_revoke = true
            config.revoke_strategy = :revoke_access
          end

          memo3 = create(:memo, parent: memo2)
          user.grant(:member, memo3)
        end

        subject { user.revoke_role!(:manager, memo2) }

        it { is_expected_block.to change { Member.count }.by(-2) }
      end

      context 'which is default role' do
        before do
          user.revoke_role!(:guest, memo2)
        end

        it { expect(memo2.members.first.roles).to match_array([manager_role]) }

        context 'and then revoke the manager one' do
          let!(:memo3) { create :memo, parent: memo2 }

          before do
            user.grant(:manager, memo3)
            user.revoke_role!(:manager, memo2)
          end

          it { expect(memo2.members).to be_empty }
          it { expect(memo3.members).to be_empty }
        end
      end

      context 'which is not default role' do
        let!(:memo3) { create :memo, parent: memo2 }

        before do
          user.revoke_role!(:manager, memo2)
        end

        it { expect(memo2.members).to be_empty }
        it { expect(memo3.members).to be_empty }
      end
    end

    context 'when model is not acting_as_resource' do
      subject { user.revoke_role!(:guest, user) }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotResource) }
    end

    context 'when model is nil' do
      subject { user.revoke_role!(:guest, nil) }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ResourceIsNil) }
    end

    context 'when model is not model' do
      subject { user.revoke_role!(:guest, 'oko') }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotResource) }
    end
  end

  describe '.accessible_for' do
    let!(:project) { create :project }
    let!(:memo1) { create :memo, parent: project }
    let!(:memo2) { create :memo, parent: project }
    let!(:memo3) { create :memo, parent: memo2 }
    let!(:memo4) { create :memo, parent: memo3 }
    let!(:memo5) { create :memo, parent: memo2 }
    let!(:memo6) { create :memo, parent: memo3 }

    let!(:manager_role) { create(:role, name: :manager, level: 2, inherited: true) }

    let!(:member2) { create :member, resource: memo1 }
    let!(:member3) { create :member, resource: memo5 }
    let!(:member4) { create :member, resource: memo6 }

    subject { User.accessible_for(member.user) }

    context 'when user is not monarchy user' do
      subject { User.accessible_for(member2) }

      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotUser) }
    end

    context 'when user is nil' do
      subject { User.accessible_for(nil) }

      it { is_expected_block.to raise_exception(Monarchy::Exceptions::UserIsNil) }
    end

    context 'user has access to all members if has manager role on root' do
      let!(:member) { create :member, resource: project, roles: [manager_role] }

      it { is_expected.to match_array([member.user, member2.user, member3.user, member4.user]) }
    end

    context 'user has access to only root members if has guest role on root' do
      let!(:member) { create :member, resource: project }

      it { is_expected.to match_array([member.user]) }
    end

    context 'user has access to memo3' do
      let!(:member) { create :member, resource: memo3, roles: [manager_role] }

      it { is_expected.to match_array([member.user, member4.user]) }
    end
  end

  describe '.with_access_to' do
    let!(:project) { create :project }
    let!(:memo1) { create :memo, parent: project }
    let!(:memo2) { create :memo, parent: project }
    let!(:memo3) { create :memo, parent: memo2 }
    let!(:memo4) { create :memo, parent: memo3 }
    let!(:memo5) { create :memo, parent: memo2 }
    let!(:memo6) { create :memo, parent: memo3 }

    let!(:guest_role) { create(:role, name: :guest, level: 0, inherited: false) }
    let!(:member_role) { create(:role, name: :member, level: 1, inherited: true, inherited_role: guest_role) }
    let!(:manager_role) { create(:role, name: :manager, level: 2, inherited: true, inherited_role: owner_role) }
    let!(:owner_role) { create(:role, name: :owner, level: 3, inherited: true) }

    let!(:user1) { create(:user).tap { |model| model.grant(:owner, project) } }
    let!(:user2) { create(:user).tap { |model| model.grant(:manager, memo2) } }
    let!(:user3) { create(:user).tap { |model| model.grant(:guest, memo6) } }
    let!(:user4) { create(:user).tap { |model| model.grant(:member, memo3) } }
    let!(:user5) { create(:user).tap { |model| model.grant(:member, memo1) } }
    let!(:user6) { create(:user).tap { |model| model.grant(:guest, memo1) } }

    subject { described_class.with_access_to(memo3) }

    it { is_expected.to match_array([user1, user2, user3, user4]) }

    context 'resource is not a monarchy resource' do
      subject { described_class.with_access_to(user1) }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotResource) }
    end
  end
end
