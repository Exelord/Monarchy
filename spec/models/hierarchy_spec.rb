# frozen_string_literal: true

require 'rails_helper'

describe Monarchy::Hierarchy, type: :model do
  it { is_expected.to have_many(:members).dependent(:destroy) }
  it { is_expected.to belong_to(:resource) }

  it { is_expected.to validate_presence_of(:resource_id) }
  it { is_expected.to validate_presence_of(:resource_type) }

  describe '.hierarchies_for' do
    subject { described_class.hierarchies_for(projects) }

    context 'when projects are ActiveRecord relation' do
      let!(:projects) { Project.where(id: create_list(:project, 3)) }

      it { expect { subject.to_a }.to make_database_queries(count: 1) }
      it { expect(subject.uniq.count).to be(3) }
      it { is_expected.to match_array(projects.map(&:hierarchy)) }
    end

    context 'when projects is ActiveRecord object' do
      let!(:projects) { create(:project) }

      it { expect { subject.to_a }.to make_database_queries(count: 1) }
      it { expect(subject.uniq.count).to be(1) }
      it { is_expected.to match_array([projects.hierarchy]) }
    end

    context 'when project is nil' do
      let!(:projects) { nil }

      it { expect { subject.to_a }.to make_database_queries(count: 0) }
      it { expect(subject.uniq.count).to be(0) }
    end

    context 'when project is an array' do
      let!(:projects) { [] }

      it { is_expected_block.to raise_exception(ArgumentError) }
    end
  end

  describe '.children_for' do
    subject { described_class.children_for(hierarchies) }

    let!(:project) { create :project }
    let!(:memo1) { create :memo, parent: project }

    context 'when hierarchies are ActiveRecord relation' do
      let!(:project2) { create :project }
      let!(:memo3) { create :memo, parent: project2 }

      let!(:hierarchies) { described_class.where(resource: Project.all) }

      it { expect { subject.to_a }.to make_database_queries(count: 1) }
      it { expect(subject.uniq.count).to be(4) }
      it { is_expected.to match_array(project.hierarchy.children.reload + project2.hierarchy.children.reload) }
    end

    context 'when hierarchies is ActiveRecord object' do
      let!(:hierarchies) { project.hierarchy }

      it { expect { subject.to_a }.to make_database_queries(count: 1) }
      it { expect(subject.uniq.count).to be(2) }
      it { is_expected.to match_array(project.hierarchy.children.reload) }
    end

    context 'when project is nil' do
      let!(:hierarchies) { nil }

      it { expect { subject.to_a }.to make_database_queries(count: 0) }
      it { expect(subject.uniq.count).to be(0) }
    end

    context 'when project is an array' do
      let!(:hierarchies) { [] }

      it { is_expected_block.to raise_exception(ArgumentError) }
    end
  end

  describe '.descendants_for' do
    subject { described_class.descendants_for(hierarchies) }

    let!(:project) { create :project }
    let!(:memo1) { create :memo, parent: project }
    let!(:memo2) { create :memo, parent: memo1 }

    context 'when hierarchies are ActiveRecord relation' do
      let!(:project2) { create :project }
      let!(:memo3) { create :memo, parent: project2 }

      let!(:hierarchies) { described_class.where(resource: Project.all) }

      it { expect { subject.to_a }.to make_database_queries(count: 1) }
      it { expect(subject.uniq.count).to be(5) }
      it { is_expected.to match_array([memo1, memo2, memo3, project2.status, project.status].map(&:hierarchy)) }
    end

    context 'when hierarchies is ActiveRecord object' do
      let!(:hierarchies) { project.hierarchy }

      it { expect { subject.to_a }.to make_database_queries(count: 1) }
      it { expect(subject.uniq.count).to be(3) }
      it { is_expected.to match_array([memo1, memo2, project.status].map(&:hierarchy)) }
    end

    context 'when project is nil' do
      let!(:hierarchies) { nil }

      it { expect { subject.to_a }.to make_database_queries(count: 0) }
      it { expect(subject.uniq.count).to be(0) }
    end

    context 'when project is an array' do
      let!(:hierarchies) { [] }

      it { is_expected_block.to raise_exception(ArgumentError) }
    end
  end

  describe '.parents_for' do
    subject { described_class.parents_for(hierarchies) }

    let!(:project) { create :project }
    let!(:memo1) { create :memo, parent: project }
    let!(:memo2) { create :memo, parent: memo1 }

    context 'when hierarchies are ActiveRecord relation' do
      let!(:project2) { create :project }
      let!(:memo3) { create :memo, parent: project2 }

      let!(:hierarchies) { described_class.where(resource: Memo.where(id: [memo2, memo3])) }

      it { expect { subject.to_a }.to make_database_queries(count: 1) }
      it { expect(subject.uniq.count).to be(2) }
      it { is_expected.to match_array([memo1, project2].map(&:hierarchy)) }
    end

    context 'when hierarchies is ActiveRecord object' do
      let!(:hierarchies) { described_class.where(resource: memo2) }

      it { expect { subject.to_a }.to make_database_queries(count: 1) }
      it { expect(subject.uniq.count).to be(1) }
      it { is_expected.to match_array([memo1.hierarchy]) }
    end

    context 'when project is nil' do
      let!(:hierarchies) { nil }

      it { expect { subject.to_a }.to make_database_queries(count: 0) }
      it { expect(subject.uniq.count).to be(0) }
    end

    context 'when project is an array' do
      let!(:hierarchies) { [] }

      it { is_expected_block.to raise_exception(ArgumentError) }
    end
  end

  describe '.ancestors_for' do
    subject { described_class.ancestors_for(hierarchies) }

    let!(:project) { create :project }
    let!(:memo1) { create :memo, parent: project }
    let!(:memo2) { create :memo, parent: memo1 }

    context 'when hierarchies are ActiveRecord relation' do
      let!(:project2) { create :project }
      let!(:memo3) { create :memo, parent: project2 }

      let!(:hierarchies) { described_class.where(resource: Memo.where(id: [memo2, memo3])) }

      it { expect { subject.to_a }.to make_database_queries(count: 1) }
      it { expect(subject.uniq.count).to be(3) }
      it { is_expected.to match_array([memo1, project, project2].map(&:hierarchy)) }
    end

    context 'when hierarchies is ActiveRecord object' do
      let!(:hierarchies) { described_class.where(resource: memo2) }

      it { expect { subject.to_a }.to make_database_queries(count: 1) }
      it { expect(subject.uniq.count).to be(2) }
      it { is_expected.to match_array([memo1.hierarchy, project.hierarchy]) }
    end

    context 'when project is nil' do
      let!(:hierarchies) { nil }

      it { expect { subject.to_a }.to make_database_queries(count: 0) }
      it { expect(subject.uniq.count).to be(0) }
    end

    context 'when project is an array' do
      let!(:hierarchies) { [] }

      it { is_expected_block.to raise_exception(ArgumentError) }
    end
  end

  describe '.in' do
    subject { described_class.in(project.hierarchy) }

    let(:project) { create :project }
    let!(:project2) { create :project, parent: project }
    let!(:memo1) { create :memo, parent: project }
    let!(:memo3) { create :memo, parent: project }

    it { expect { subject.to_a }.to make_database_queries(count: 1) }

    it do
      expect(subject).to match_array([project2.status.hierarchy, project.status.hierarchy,
                                      memo1.hierarchy, project2.hierarchy, memo3.hierarchy])
    end

    context 'nested memo in memo' do
      let!(:memo3) { create :memo, parent: project2 }

      it { expect { subject.to_a }.to make_database_queries(count: 1) }

      it do
        expect(subject).to match_array([project2.status.hierarchy, project.status.hierarchy,
                                        memo1.hierarchy, project2.hierarchy, memo3.hierarchy])
      end
    end
  end

  describe '#accessible_for' do
    subject { hierarchy1.accessible_for(user) }

    let!(:project) { create(:project) }
    let!(:hierarchy1) { create(:memo, parent: project).hierarchy }

    let!(:user) { create :user }

    context 'where user has not access' do
      it { is_expected_block.to make_database_queries(count: 1) }
      it { is_expected.to be false }
    end

    context 'where user has an access' do
      let!(:member_role) { create(:role, name: :member, level: 1, inherited: false) }
      let!(:memo_member) { create(:member, user: user, hierarchy: hierarchy1) }

      it { is_expected_block.to make_database_queries(count: 1) }
      it { is_expected.to be true }
    end
  end

  describe '.accessible_for' do
    subject { described_class.accessible_for(user) }

    let!(:project) { create :project }
    let!(:memo1) { create :memo, parent: project }
    let!(:memo2) { create :memo, parent: project }
    let!(:memo3) { create :memo, parent: memo2 }
    let!(:memo4) { create :memo, parent: memo3 }
    let!(:memo5) { create :memo, parent: memo2 }
    let!(:memo6) { create :memo, parent: memo3 }

    let!(:user) { create :user }

    it { expect { subject.to_a }.to make_database_queries(count: 1) }

    context 'user has access to all parents memos and self' do
      let!(:guest_role) { create(:role, name: :guest, level: 0, inherited: false) }
      let!(:member_role) { create(:role, name: :member, level: 1, inherited: false, inherited_role: guest_role) }

      let!(:memo_member) { create(:member, user: user, hierarchy: memo4.hierarchy) }

      it { expect { subject.to_a }.to make_database_queries(count: 1) }
      it { is_expected.to match_array([project.hierarchy, memo2.hierarchy, memo3.hierarchy, memo4.hierarchy]) }
      it { is_expected.not_to include(memo6.hierarchy, memo5.hierarchy, memo1.hierarchy) }

      context 'user has access to resources bellow' do
        let!(:manager_role) { create(:role, name: :manager, level: 1) }
        let!(:memo_member) { create(:member, user: user, hierarchy: memo3.hierarchy, roles: [manager_role, member_role]) }

        it do
          expect(subject).to match_array([project.hierarchy, memo2.hierarchy,
                                          memo3.hierarchy, memo4.hierarchy, memo6.hierarchy])
        end

        it { is_expected.not_to include(memo5.hierarchy, memo1.hierarchy) }
        it { expect { subject.to_a }.to make_database_queries(count: 1) }
      end

      context 'user has not access to resources bellow as guest' do
        let!(:memo_member) { create(:member, user: user, hierarchy: memo3.hierarchy, roles: [guest_role]) }

        it { expect { subject.to_a }.to make_database_queries(count: 1) }
        it { is_expected.to match_array([project.hierarchy, memo2.hierarchy, memo3.hierarchy]) }
        it { is_expected.not_to include(memo5.hierarchy, memo1.hierarchy, memo4.hierarchy, memo6.hierarchy) }
      end

      context 'user has not access to resources bellow as member without roles' do
        let!(:memo_member) { create(:member, user: user, hierarchy: memo3.hierarchy, roles: []) }

        it { expect { subject.to_a }.to make_database_queries(count: 1) }
        it { is_expected.to match_array([project.hierarchy, memo2.hierarchy, memo3.hierarchy]) }
        it { is_expected.not_to include(memo5.hierarchy, memo1.hierarchy, memo4.hierarchy, memo6.hierarchy) }
      end

      context 'user has not access to resources bellow as member' do
        context 'when user is member in memo3' do
          let!(:memo_member) { create(:member, user: user, hierarchy: memo3.hierarchy, roles: [member_role]) }

          it { expect { subject.to_a }.to make_database_queries(count: 1) }
          it { is_expected.to match_array([project.hierarchy, memo2.hierarchy, memo3.hierarchy]) }
          it { is_expected.not_to include(memo5.hierarchy, memo1.hierarchy, memo4.hierarchy, memo6.hierarchy) }

          context 'when user has access to memo4 as visitor' do
            let!(:memo4_member) { create(:member, user: user, hierarchy: memo4.hierarchy) }

            it { expect { subject.to_a }.to make_database_queries(count: 1) }
            it { is_expected.to match_array([project.hierarchy, memo2.hierarchy, memo3.hierarchy, memo4.hierarchy]) }
            it { is_expected.not_to include(memo5.hierarchy, memo1.hierarchy, memo6.hierarchy) }
          end

          context 'when user has access to memo4 as member' do
            let!(:memo4_member) { create(:member, user: user, hierarchy: memo4.hierarchy, roles: [member_role]) }

            it { expect { subject.to_a }.to make_database_queries(count: 1) }
            it { is_expected.to match_array([project.hierarchy, memo2.hierarchy, memo3.hierarchy, memo4.hierarchy]) }
            it { is_expected.not_to include(memo5.hierarchy, memo1.hierarchy, memo6.hierarchy) }
          end
        end

        context 'when user is an owner in memo3' do
          let!(:owner_role) { create(:role, name: :owner, level: 3) }
          let!(:memo_member) { create(:member, user: user, hierarchy: memo2.hierarchy, roles: [member_role]) }
          let!(:memo3_member) { create(:member, user: user, hierarchy: memo3.hierarchy, roles: [owner_role]) }

          it do
            expect(subject).to match_array([project.hierarchy, memo2.hierarchy, memo3.hierarchy,
                                            memo4.hierarchy, memo6.hierarchy])
          end

          it { expect { subject.to_a }.to make_database_queries(count: 1) }
          it { is_expected.not_to include(memo5.hierarchy, memo1.hierarchy) }
        end
      end

      context 'user has access to resources bellow as manager' do
        let!(:owner_role) { create(:role, name: :owner, level: 3) }
        let!(:manager_role) { create(:role, name: :manager, level: 2, inherited_role: owner_role) }
        let!(:memo_member) { create(:member, user: user, hierarchy: memo3.hierarchy, roles: [manager_role]) }

        it do
          expect(subject).to match_array([project.hierarchy, memo2.hierarchy,
                                          memo3.hierarchy, memo4.hierarchy, memo6.hierarchy])
        end

        it { is_expected.not_to include(memo5.hierarchy, memo1.hierarchy) }
        it { expect { subject.to_a }.to make_database_queries(count: 1) }
      end
    end

    context '.accessible_for and .in' do
      context 'when have access to leaves' do
        let!(:owner_role) { create(:role, name: :owner, level: 3) }
        let!(:memo_member) { create(:member, user: user, hierarchy: project.hierarchy, roles: [owner_role]) }
        let(:hierarchy) { memo3.hierarchy }

        it { expect(described_class.accessible_for(user).in(hierarchy)).to match_array([memo6.hierarchy, memo4.hierarchy]) }
        it { expect(described_class.in(hierarchy).accessible_for(user)).to match_array([memo6.hierarchy, memo4.hierarchy]) }
        it { expect { described_class.in(hierarchy).accessible_for(user).to_a }.to make_database_queries(count: 1) }
        it { expect { described_class.accessible_for(user).in(hierarchy).to_a }.to make_database_queries(count: 1) }
      end

      context 'when have access to roots' do
        let!(:memo_member) { create(:member, user: user, hierarchy: memo4.hierarchy) }
        let(:hierarchy) { memo2.hierarchy }

        it { expect(described_class.accessible_for(user).in(hierarchy)).to match_array([memo3.hierarchy, memo4.hierarchy]) }
        it { expect(described_class.in(hierarchy).accessible_for(user)).to match_array([memo3.hierarchy, memo4.hierarchy]) }
        it { expect { described_class.in(hierarchy).accessible_for(user).to_a }.to make_database_queries(count: 1) }
        it { expect { described_class.accessible_for(user).in(hierarchy).to_a }.to make_database_queries(count: 1) }
      end
    end

    context 'with specified allowed roles' do
      context 'when only member role is allowed' do
        subject { described_class.accessible_for(user, inherited_roles: [:member]) }

        let!(:owner_role) { create(:role, name: :owner, level: 3) }
        let!(:member_role) { create(:role, name: :member, level: 1, inherited: false) }
        let!(:no_access_role) { create(:role, name: :blocked, level: 1, inherited: false) }
        let!(:memo7) { create :memo, parent: memo6 }

        it { expect { subject.to_a }.to make_database_queries(count: 1) }

        context 'user has a member role in project' do
          before { user.grant(:member, memo3) }

          it do
            expect(subject).to match_array([project.hierarchy, memo2.hierarchy,
                                            memo3.hierarchy, memo4.hierarchy, memo6.hierarchy,
                                            memo7.hierarchy])
          end

          it { expect { subject.to_a }.to make_database_queries(count: 1) }
        end

        context 'user has a inherited role' do
          before { user.grant(:owner, memo3) }

          it do
            expect(subject).to match_array([project.hierarchy, memo2.hierarchy,
                                            memo3.hierarchy, memo4.hierarchy, memo6.hierarchy,
                                            memo7.hierarchy])
          end

          it { expect { subject.to_a }.to make_database_queries(count: 1) }
        end

        context 'user has other role without inheritance' do
          before { user.grant(:blocked, memo3) }

          it { is_expected.to match_array([memo3.hierarchy, memo2.hierarchy, project.hierarchy]) }
          it { expect { subject.to_a }.to make_database_queries(count: 1) }
        end
      end
    end

    context 'with parent role access' do
      subject { described_class.accessible_for(user, parent_access: true) }

      let!(:member_role) { create(:role, name: :member, level: 1, inherited: false) }

      before { user.grant(:member, memo5) }

      it do
        expect(subject).to match_array([project.hierarchy, project.status.hierarchy, memo2.hierarchy,
                                        memo1.hierarchy, memo5.hierarchy, memo3.hierarchy])
      end

      it { expect { subject.to_a }.to make_database_queries(count: 1) }
    end
  end
end
