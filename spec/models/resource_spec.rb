# frozen_string_literal: true
require 'rails_helper'

describe Resource, type: :model do
  it { is_expected.to have_many(:members).through(:hierarchy) }
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

        it 'assign parent if assing resource_id' do
          project.update(resource_id: resource.id)
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

        it 'assign parent if assing project_id' do
          memo.update(project_id: project.id)
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

  describe 'after_save' do
    describe '.assign_parent' do
      let!(:project) { create(:project) }
      let(:descendants) { project.hierarchy.descendants }

      context 'belongs_to' do
        let!(:memo) { create(:memo) }

        it { expect { memo.parent = project }.to change { descendants.reload.to_a } }
        it { expect { memo.parent = project }.to change { memo.parent }.to(project) }

        it { expect { memo.update(project: project) }.to change { descendants.reload.to_a } }
        it { expect { memo.update(project: project) }.to change { memo.parent }.to(project) }

        it { expect { memo.update(project_id: project.id) }.to change { descendants.reload.to_a } }
        it { expect { memo.update(project_id: project.id) }.to change { memo.parent }.to(project) }
      end

      context 'belongs_to polymorphic' do
        let!(:task) { create(:task) }

        it { expect { task.parent = project }.to change { descendants.reload.to_a } }
        it { expect { task.parent = project }.to change { task.parent }.to(project) }

        it { expect { task.update(resource: project) }.to change { descendants.reload.to_a } }
        it { expect { task.update(resource: project) }.to change { task.parent }.to(project) }

        it do
          expect { task.update(resource_id: project.id, resource_type: 'Project') }
            .to change { descendants.reload.to_a }
        end

        it do
          expect { task.update(resource_id: project.id, resource_type: 'Project') }
            .to change { task.parent }.to(project)
        end

        context 'change resource_type only' do
          let!(:memo) { create(:memo) }
          let!(:task) { create(:task, resource_id: project.id, resource_type: 'Project') }

          it { expect { task.update(resource_type: 'Memo') }.to change { task.parent }.to(memo) }
          it { expect { task.update(resource_type: 'Memo') }.to change { descendants.reload.to_a } }
        end

        context 'change resource_id only' do
          let!(:project2) { create(:project) }
          let!(:task) { create(:task, resource_id: project.id, resource_type: 'Project') }

          it { expect { task.update(resource_id: project2.id) }.to change { task.parent }.to(project2) }
          it { expect { task.update(resource_id: project2.id) }.to change { descendants.reload.to_a } }
        end
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

    subject { Memo.in(project) }

    it { is_expected.to match_array([memo1, memo2, memo3]) }

    context 'nested memo in memo' do
      let!(:memo3) { create :memo, parent: memo2 }

      it { is_expected.to match_array([memo1, memo2, memo3]) }
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

      context 'user has access to resources bellow if has manager role' do
        let!(:manager_role) { create(:role, name: :manager, level: 2, inherited: true) }
        let!(:memo_member) { create(:member, user: user, hierarchy: memo3.hierarchy, roles: [manager_role]) }

        it { is_expected.to match_array([memo2, memo3, memo4, memo6]) }
        it { is_expected.not_to include(memo5, memo1) }
      end

      context 'user has access to resources bellow if has guest role' do
        let!(:memo_member) { create(:member, user: user, hierarchy: memo3.hierarchy) }

        it { is_expected.to match_array([memo2, memo3]) }
        it { is_expected.not_to include(memo5, memo1, memo4, memo6) }
      end

      context 'user has access to resources bellow if has guest role' do
        let!(:memo7) { create :memo, parent: memo6 }
        let!(:memo_member) { create(:member, user: user, hierarchy: memo3.hierarchy) }
        let!(:memo7_member) { create(:member, user: user, hierarchy: memo7.hierarchy) }

        it { is_expected.to match_array([memo2, memo3, memo6, memo7]) }
        it { is_expected.not_to include(memo5, memo1, memo4) }
      end
    end

    context 'accessible_for in' do
      let!(:memo_member) { create(:member, user: user, hierarchy: memo4.hierarchy) }

      it { expect(Memo.accessible_for(user).in(memo2)).to match_array([memo3, memo4]) }
    end
  end

  describe '@acting_as_resource' do
    context 'when class is a resource' do
      let(:klass) { described_class }

      it { expect(klass.respond_to?(:acting_as_resource)).to be true }
      it { expect(klass.acting_as_resource).to be true }
    end

    context 'when class is not a resource' do
      let(:klass) { User }
      it { expect(klass.respond_to?(:acting_as_resource)).to be false }
    end
  end
end
