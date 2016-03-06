# frozen_string_literal: true
require 'rails_helper'

describe Resource, type: :model do
  it { is_expected.to have_many(:members).through(:hierarchy) }
  it { is_expected.to have_one(:hierarchy).dependent(:destroy) }

  describe 'acts_as_resource' do
    context 'parent_as setter' do
      let(:memo) { create :memo }
      let(:resource) { Resource.create }

      subject { resource.parent }

      it 'assign parent if assing memo' do
        resource.update(memo: memo)
        is_expected.to eq(memo)
      end
    end
  end

  describe 'after create' do
    describe 'ensure_hierarchy' do
      subject { resource.hierarchy }

      context 'create hierarchy if not exist' do
        let(:resource) { Project.create }

        it { is_expected.to be_truthy }
      end

      context 'not create hierarchy if exist' do
        let(:hierarchy) { Hierarchy.create }
        let(:resource) { Project.create(hierarchy: hierarchy) }

        it { is_expected.to eq(hierarchy) }
      end
    end
  end

  describe '#children' do
    subject { Project.find(project.id).children }
    let!(:memo1) { create :memo }
    let!(:memo2) { create :memo }
    let!(:memo3) { create :memo }

    context 'getter' do
      let(:project) { create :project, children: [memo1, memo2, memo3] }

      it { is_expected.to eq([memo1, memo2, memo3]) }
    end

    context 'setter' do
      let(:project) { create :project }

      it do
        project.children = [memo1, memo2, memo3]
        is_expected.to eq([memo1, memo2, memo3])
      end
    end
  end

  describe '#parent' do
    let!(:project) { create :project }
    subject { Memo.find(memo.id).parent }

    context 'getter' do
      let(:memo) { create :memo, parent: project }

      it { is_expected.to eq(project) }
    end

    context 'setter' do
      let!(:memo) { create :memo }

      it do
        memo.parent = project
        is_expected.to eq(project)
      end

      it 'can assign nil' do
        memo.parent = nil
        is_expected.to be_nil
      end
    end
  end

  describe '.in' do
    let(:project) { create :project }
    let!(:memo_root) { create :memo }
    let!(:memo1) { create :memo, parent: project }
    let!(:memo2) { create :memo, parent: project }
    let!(:memo3) { create :memo, parent: project }

    it { expect(Memo.in(project)).to eq([memo1, memo2, memo3]) }
  end

  describe '.accessible_for' do
    let(:member_role) { create(:role, name: :member, level: 1) }
    let(:manager_role) { create(:role, name: :manager, level: 2) }

    let!(:project) { create :project }
    let!(:memo1) { create :memo, parent: project }
    let!(:memo2) { create :memo, parent: project }
    let!(:memo3) { create :memo, parent: memo2 }
    let!(:memo4) { create :memo, parent: memo3 }

    let!(:user) { create :user }

    context 'user has access to all parents and self of' do
      subject { Memo.accessible_for(user) }
      context 'memo4' do
        let!(:memo_member) { create(:member, user: user, hierarchy: memo4.hierarchy, roles: [member_role]) }

        it { is_expected.to match_array([memo2, memo3, memo4]) }
      end

      context 'memo3' do
        let!(:memo_member) { create(:member, user: user, hierarchy: memo3.hierarchy, roles: [member_role]) }

        it { is_expected.to match_array([memo2, memo3]) }
      end
    end

    context 'accessible_for in' do
      let!(:memo_member) { create(:member, user: user, hierarchy: memo4.hierarchy, roles: [member_role]) }

      it { expect(Memo.accessible_for(user).in(project)).to match_array([memo2]) }
    end
  end
end
