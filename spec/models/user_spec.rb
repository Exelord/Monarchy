# frozen_string_literal: true
require 'rails_helper'

describe User, type: :model do
  it { is_expected.to have_many(:members) }

  let!(:guest_role) { create(:role, name: :guest, level: 0, inherited: false) }
  let!(:member_role) { create(:role, name: :member, level: 1) }
  let!(:manager_role) { create(:role, name: :manager, level: 2) }

  let(:user) { create :user }
  let!(:project) { create :project }
  let!(:memo) { create :memo, parent: project }

  describe '#role_for' do
    let!(:memo_member) { create(:member, user: user, hierarchy: memo.hierarchy, roles: [member_role]) }
    let!(:project_member) { create(:member, user: user, hierarchy: project.hierarchy, roles: [manager_role]) }
    subject { user.role_for(memo) }

    context 'user has no direct access to memo' do
      let!(:memo_member) {}

      it { is_expected.to eq(manager_role) }
    end

    context 'user has no direct access to project' do
      let!(:project_member) {}

      it { is_expected.to eq(member_role) }
    end

    context 'parent role is inherited' do
      it { is_expected.to eq(manager_role) }

      context 'model role is inherited' do
        let(:member_role) { create(:role, name: :member, level: 1) }

        it { is_expected.to eq(manager_role) }
      end

      context 'model role is not inherited' do
        let(:member_role) { create(:role, name: :member, level: 1, inherited: false) }

        it { is_expected.to eq(manager_role) }
      end
    end

    context 'parent role in not inherited' do
      let(:manager_role) { create(:role, name: :manager, level: 2, inherited: false) }

      it { is_expected.to eq(member_role) }

      context 'model role is not inherited' do
        let(:member_role) { create(:role, name: :member, level: 1, inherited: false) }

        it { is_expected.to eq(member_role) }
      end

      context 'model role is inherited' do
        let(:member_role) { create(:role, name: :member, level: 1) }

        it { is_expected.to eq(member_role) }
      end
    end
  end

  describe '#roles_for' do
    let!(:memo_member) { create(:member, user: user, hierarchy: memo.hierarchy, roles: [member_role]) }
    let!(:project_member) { create(:member, user: user, hierarchy: project.hierarchy, roles: [manager_role]) }
    subject { user.roles_for(memo) }

    context 'user has no direct access to memo' do
      let!(:memo_member) {}

      it { is_expected.to match_array([manager_role]) }
    end

    context 'user has no direct access to project' do
      let!(:project_member) {}

      it { is_expected.to match_array([member_role, guest_role]) }
    end

    context 'parent role is inherited' do
      it { is_expected.to match_array([manager_role, member_role, guest_role]) }

      context 'model role is inherited' do
        let(:member_role) { create(:role, name: :member, level: 1) }

        it { is_expected.to match_array([manager_role, member_role, guest_role]) }
      end

      context 'model role is not inherited' do
        let(:member_role) { create(:role, name: :member, level: 1, inherited: false) }

        it { is_expected.to match_array([manager_role, member_role, guest_role]) }
      end
    end

    context 'parent role in not inherited' do
      let(:manager_role) { create(:role, name: :manager, level: 2, inherited: false) }

      it { is_expected.to match_array([member_role, guest_role]) }

      context 'model role is not inherited' do
        let(:member_role) { create(:role, name: :member, level: 1, inherited: false) }

        it { is_expected.to match_array([member_role, guest_role]) }
      end

      context 'model role is inherited' do
        let(:member_role) { create(:role, name: :member, level: 1) }

        it { is_expected.to match_array([member_role, guest_role]) }
      end
    end
  end

  describe '#grant' do
    let(:default_role) { Monarchy::Role.find_by_name(Monarchy.configuration.default_role.name) }

    context 'inherited resource' do
      let(:grant_user) { user.grant(:manager, memo) }

      before do
        grant_user
      end

      it { expect(Monarchy::Member.count).to be(2) }

      it 'project with default role' do
        expect(project.members.first.roles).to match_array([default_role])
      end

      it 'memo with selected role' do
        expect(memo.members.first.roles).to match_array([Monarchy::Role.find_by_name(:manager), default_role])
      end

      it 'with doubled grant' do
        2.times do
          grant_user
          expect(project.members.first.roles).to match_array([default_role])
          expect(memo.members.first.roles).to match_array([Monarchy::Role.find_by_name(:manager), default_role])
        end
      end
    end

    context 'root resource' do
      let(:grant_user) { user.grant(:manager, project) }

      before do
        grant_user
      end

      it { expect(Monarchy::Member.count).to be(1) }
      it { expect(project.members.first.roles).to match_array([Monarchy::Role.find_by_name(:manager), default_role]) }
    end
  end

  describe '#member_for' do
    let!(:memo_member) { create(:member, user: user, hierarchy: memo.hierarchy, roles: [member_role]) }

    it { expect(user.member_for(memo)).to eq(memo_member) }
  end

  describe '#revoke access' do
    let!(:memo2) { create :memo, parent: memo }
    let!(:memo3) { create :memo, parent: memo2 }
    let!(:memo4) { create :memo, parent: memo }

    context 'sholud revoke bellow and self' do
      before do
        user.grant(:manager, memo3)
        user.grant(:member, memo4)
        user.revoke_access(memo2)
      end

      it { expect(user.role_for(memo2)).to be_nil }
      it { expect(user.role_for(memo3)).to be_nil }
      it { expect(user.role_for(memo4)).to eq(member_role) }
      it { expect(user.role_for(memo)).to eq(guest_role) }
      it { expect(user.role_for(project)).to eq(guest_role) }
    end

    context 'sholud revoke bellow self and parents' do
      before do
        user.grant(:manager, memo3)
        user.revoke_access(memo2)
      end

      it { expect(user.role_for(project)).to be_nil }
      it { expect(user.role_for(memo)).to be_nil }
      it { expect(user.role_for(memo2)).to be_nil }
      it { expect(user.role_for(memo3)).to be_nil }
      it { expect(user.role_for(memo4)).to be_nil }
    end

    context 'sholud revoke bellow self and parent' do
      let!(:memo4) { create :memo, parent: project }

      before do
        user.grant(:manager, memo3)
        user.grant(:manager, memo4)
        user.revoke_access(memo2)
      end

      it { expect(user.role_for(project)).to eq(guest_role) }
      it { expect(user.role_for(memo)).to be_nil }
      it { expect(user.role_for(memo2)).to be_nil }
      it { expect(user.role_for(memo3)).to be_nil }
      it { expect(user.role_for(memo4)).to eq(manager_role) }
    end
  end

  describe '#revoke role' do
    let!(:memo2) { create :memo, parent: memo }
    let!(:memo3) { create :memo, parent: memo2 }
    let!(:memo4) { create :memo, parent: memo }

    context 'sholud revoke only one role' do
      before do
        user.grant(:manager, memo4)
        user.grant(:member, memo4)
      end

      subject { user.revoke_role(:manager, memo4) }

      it do
        subject
        expect(user.role_for(memo4)).to eq(member_role)
      end

      it { expect { subject }.to change { Monarchy::MembersRole.count }.by(-1) }
    end

    context 'sholud grant default role if no role exist' do
      before do
        user.grant(:manager, memo3)
        user.revoke_role(:manager, memo3)
        user.revoke_role(:guest, memo3)
      end

      it { expect(user.role_for(project)).to eq(guest_role) }
      it { expect(user.role_for(memo)).to eq(guest_role) }
      it { expect(user.role_for(memo2)).to eq(guest_role) }
      it { expect(user.role_for(memo3)).to eq(guest_role) }
      it { expect(user.role_for(memo4)).to be_nil }
    end
  end

  describe '#revoke role!' do
    let!(:memo2) { create :memo, parent: memo }
    let!(:memo3) { create :memo, parent: memo2 }
    let!(:memo4) { create :memo, parent: memo }

    context 'sholud revoke only one role' do
      before do
        user.grant(:manager, memo4)
        user.grant(:member, memo4)
      end

      subject { user.revoke_role!(:manager, memo4) }

      it do
        subject
        expect(user.role_for(memo4)).to eq(member_role)
      end

      it { expect { subject }.to change { Monarchy::MembersRole.count }.by(-1) }
    end

    context 'sholud revoke access recursively' do
      before do
        user.grant(:manager, memo3)
        user.revoke_role!(:guest, memo3)
        user.revoke_role!(:manager, memo3)
      end

      it { expect(user.role_for(project)).to be_nil }
      it { expect(user.role_for(memo)).to be_nil }
      it { expect(user.role_for(memo2)).to be_nil }
      it { expect(user.role_for(memo3)).to be_nil }
      it { expect(user.role_for(memo4)).to be_nil }
    end
  end
end
