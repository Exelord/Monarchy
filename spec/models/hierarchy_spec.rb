# frozen_string_literal: true
require 'rails_helper'

describe Monarchy::Hierarchy, type: :model do
  it { is_expected.to have_many(:members).dependent(:destroy) }
  it { is_expected.to belong_to(:resource).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:resource_id) }
  it { is_expected.to validate_presence_of(:resource_type) }

  describe '.in' do
    let(:project) { create :project }
    let!(:project2) { create :project, parent: project }
    let!(:memo1) { create :memo, parent: project }
    let!(:memo3) { create :memo, parent: project }

    subject { described_class.in(project) }

    it { is_expected.to match_array([memo1.hierarchy, project2.hierarchy, memo3.hierarchy]) }

    context 'nested memo in memo' do
      let!(:memo3) { create :memo, parent: project2 }

      it { is_expected.to match_array([memo1.hierarchy, project2.hierarchy, memo3.hierarchy]) }
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
    subject { described_class.accessible_for(user) }

    context 'user has access to all parents memos and self' do
      let!(:memo_member) { create(:member, user: user, hierarchy: memo4.hierarchy) }

      it { is_expected.to match_array([project.hierarchy, memo2.hierarchy, memo3.hierarchy, memo4.hierarchy]) }
      it { is_expected.not_to include(memo5.hierarchy, memo1.hierarchy) }

      context 'user has access to resources bellow' do
        let!(:memo_member) { create(:member, user: user, hierarchy: memo3.hierarchy) }

        it do
          is_expected.to match_array([project.hierarchy, memo2.hierarchy,
                                      memo3.hierarchy, memo4.hierarchy, memo6.hierarchy])
        end
        it { is_expected.not_to include(memo5.hierarchy, memo1.hierarchy) }
      end
    end

    context 'accessible_for in' do
      let!(:memo_member) { create(:member, user: user, hierarchy: memo4.hierarchy) }

      it { expect(described_class.accessible_for(user).in(memo2)).to match_array([memo3.hierarchy, memo4.hierarchy]) }
    end
  end
end
