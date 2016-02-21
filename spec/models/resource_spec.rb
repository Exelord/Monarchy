require 'rails_helper'

describe Resource, type: :model do
  it { is_expected.to have_many(:members).through(:hierarchy) }
  it { is_expected.to have_one(:hierarchy).dependent(:destroy) }

  context 'scope in' do
    let(:project) { create :project }
    let!(:memo_root) { create :memo }
    let!(:memo1) { create :memo }
    let!(:memo2) { create :memo }
    let!(:memo3) { create :memo }

    let!(:parentize) do
      memo1.parent = project
      memo2.parent = project
      memo3.parent = project
    end

    it { expect(Memo.in(project)).to eq([memo1, memo2, memo3]) }
  end

  context 'scope accessible_for' do
    let(:member_role) { create(:role, name: :member, level: 1) }
    let(:manager_role) { create(:role, name: :manager, level: 2) }

    let!(:project) { create :project }
    let!(:memo1) { create :memo }
    let!(:memo2) { create :memo }
    let!(:memo3) { create :memo }
    let!(:memo4) { create :memo }

    let!(:parentize) do
      memo1.parent = project
      memo2.parent = project
      memo3.parent = memo2
      memo4.parent = memo3
    end

    let!(:user) { create :user }

    context 'user has access to all parents and self of memo4' do
      let!(:memo_member) { create(:member, user: user, hierarchy: memo4.hierarchy, roles: [member_role]) }

      it { expect(Memo.accessible_for(user)).to match_array([memo2, memo3, memo4]) }
    end

    context 'user has access to all parents and self of memo3' do
      let!(:memo_member) { create(:member, user: user, hierarchy: memo3.hierarchy, roles: [member_role]) }

      it { expect(Memo.accessible_for(user)).to match_array([memo2, memo3]) }
    end

    context 'accessible_for in' do
      let!(:memo_member) { create(:member, user: user, hierarchy: memo4.hierarchy, roles: [member_role]) }

      it { expect(Memo.accessible_for(user).in(project)).to match_array([memo2]) }
    end
  end
end
