# frozen_string_literal: true
require 'rails_helper'

describe Resource, type: :model do
  it { is_expected.to have_many(:members).through(:hierarchy).dependent(:destroy) }
  it { is_expected.to have_one(:hierarchy).dependent(:destroy) }

  describe 'acts_as_resource' do
    context 'parent_as' do
      let!(:resource) { Resource.create }
      let!(:project) { create :project }
      let!(:memo) { create :memo }

      context 'project parent' do
        subject { project.parent }

        it 'assign parent if assing resource' do
          project.update(resource: resource)
          is_expected.to eq(resource)
        end
      end

      context 'memo parent' do
        let!(:project) { create :project, resource: resource }
        subject { memo.parent }

        it { expect(project.parent).to eq(resource) }

        it 'assign parent if assing project' do
          memo.update(project: project)
          is_expected.to eq(project)
        end
      end
    end
  end

  describe 'after create' do
    describe 'ensure_hierarchy' do
      subject { resource.hierarchy }

      context 'create hierarchy if not exist' do
        let(:resource) { create(:project) }

        it { is_expected.not_to be_nil }
      end

      context 'not create hierarchy if exist' do
        let(:hierarchy) { Monarchy::Hierarchy.create }
        let(:resource) { Project.create(hierarchy: hierarchy) }

        it { is_expected.to eq(hierarchy) }
      end
    end
  end

  describe '#children' do
    let!(:memo) { create :memo }
    let!(:memo2) { create :memo }
    let!(:project2) { create :project }

    subject { Project.find(project.id).children }

    context 'getter' do
      let(:project) { create(:project, children: [memo, memo2, project2]) }

      it { is_expected.to eq([memo, memo2, project2]) }
    end

    context 'setter' do
      let(:project) { create :project }

      it do
        project.children = [memo, memo2, project2]
        is_expected.to eq([memo, memo2, project2])
      end

      it 'can assign empty array' do
        project.children = []
        is_expected.to be_empty
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
    let!(:memo1) { create :memo, parent: project }
    let!(:memo2) { create :memo, parent: project }
    let!(:memo3) { create :memo, parent: project }

    it { expect(Memo.in(project)).to eq([memo1, memo2, memo3]) }

    context 'nested memo in memo' do
      let!(:memo3) { create :memo, parent: memo2 }

      it { expect(Memo.in(project)).to eq([memo1, memo2, memo3]) }
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

    let!(:user) { create :user }
    subject { Memo.accessible_for(user) }

    context 'user has access to all parents memos and self' do
      let!(:memo_member) { create(:member, user: user, hierarchy: memo4.hierarchy) }

      it { is_expected.to match_array([memo2, memo3, memo4]) }
      it { is_expected.not_to include(memo5, memo1) }

      context 'user has access to resources bellow' do
        let!(:memo_member) { create(:member, user: user, hierarchy: memo3.hierarchy) }

        it { is_expected.to match_array([memo2, memo3, memo4, memo6]) }
        it { is_expected.not_to include(memo5, memo1) }
      end
    end

    context 'accessible_for in' do
      let!(:memo_member) { create(:member, user: user, hierarchy: memo4.hierarchy) }

      it { expect(Memo.accessible_for(user).in(memo2)).to match_array([memo3, memo4]) }
    end
  end
end
