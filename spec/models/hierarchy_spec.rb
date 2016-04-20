# frozen_string_literal: true
require 'rails_helper'

<<<<<<< Updated upstream
describe Monarchy::Hierarchy, type: :model do
=======
<<<<<<< Updated upstream
describe Hierarchy, type: :model do
=======
describe Monarchy::Hierarchy, type: :model do
>>>>>>> Stashed changes
>>>>>>> Stashed changes
  it { is_expected.to have_many(:members) }
  it { is_expected.to belong_to(:resource) }

  it { is_expected.to validate_presence_of(:resource) }

  describe '#memberless_ancestors_for' do
    let(:user) { create(:user) }
    let(:memo1) { create(:memo) }
    let(:memo2) { create(:memo, parent: memo1) }
    let(:memo3) { create(:memo, parent: memo2) }

    subject { memo3.hierarchy.memberless_ancestors_for(user) }

    context 'user has not any memberships in resources' do
      it { is_expected.to match_array([memo1.hierarchy, memo2.hierarchy]) }
    end

    context 'user has membership in' do
      let(:sample_role) { create(:role) }

      context 'root resource' do
        it do
          user.grant(sample_role.name, memo1)
          is_expected.to match_array([memo2.hierarchy])
        end
      end

      context 'higher level resource' do
        it do
          user.grant(sample_role.name, memo2)
          is_expected.to be_empty
        end
      end
    end
  end
end
