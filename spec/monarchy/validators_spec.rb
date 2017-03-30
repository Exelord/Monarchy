# frozen_string_literal: true

require 'rails_helper'

describe Monarchy::Validators do
  let!(:guest_role) { create(:role, name: :guest, level: 0, inherited: false) }
  let!(:member_role) { create(:role, name: :member, level: 1, inherited: false, inherited_role: guest_role) }

  let!(:user) { create(:user) }
  let!(:resource) { create(:memo) }
  let!(:hierarchy) { resource.hierarchy }

  describe '.last_role?' do
    let(:member) { user.member_for(resource) }

    subject { described_class.last_role?(member, member_role) }

    context 'is last role' do
      before { user.grant(:member, resource) }

      it { is_expected.to be_truthy }
    end

    context 'is not last role' do
      before { user.grant(:member, :guest, resource) }

      it { is_expected.to be_falsy }
    end
  end

  describe '.default_role?' do
    subject { described_class.default_role?(resource, role) }

    context 'is default_role' do
      let(:role) { guest_role }

      it { is_expected.to be_truthy }
    end

    context 'is not default_role' do
      let(:role) { member_role }

      it { is_expected.to be_falsy }
    end
  end

  describe '.role_name' do
    subject { described_class.role_name(role_name) }

    context 'role exist' do
      let(:role_name) { :member }
      it { is_expected.to eq member_role }
    end

    context 'role not exist' do
      let(:role_name) { :manager }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::RoleNotExist) }
    end
  end

  describe '.role_names' do
    subject { described_class.role_names(role_names) }

    context 'only one role' do
      let(:role_names) { [:member] }
      it { is_expected.to match_array [member_role] }

      context 'as symbol' do
        let(:role_names) { :member }
        it { is_expected.to match_array [member_role] }
      end
    end

    context 'roles exist' do
      let(:role_names) { %i(member guest) }
      it { is_expected.to match_array [member_role, guest_role] }
    end

    context 'role not exist' do
      let(:role_names) { %i(member manager) }
      it { is_expected_block.to raise_exception(Monarchy::Exceptions::RoleNotExist) }
    end
  end

  describe '.resource' do
    context 'allow nil' do
      context 'persistance' do
        context 'turn on by default' do
          subject { described_class.resource(nil, true) }
          it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::ResourceNotPersist) }
        end

        context 'turn off by default' do
          subject { described_class.resource(nil, true, false) }
          it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::ResourceNotPersist) }
        end
      end

      context 'model is nil' do
        subject { described_class.resource(nil, true) }
        it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::ResourceIsNil) }
        it { is_expected.to be nil }
      end

      context 'model is resource' do
        subject { described_class.resource(resource, true) }
        it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::ModelNotResource) }
        it { is_expected.to eq resource }
      end

      context 'model not resource' do
        subject { described_class.resource(user, true) }
        it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotResource) }
      end
    end

    context 'not allow nil' do
      context 'persistance' do
        context 'turn on by default' do
          subject { described_class.resource(build(:memo)) }
          it { is_expected_block.to raise_exception(Monarchy::Exceptions::ResourceNotPersist) }
        end

        context 'turn off by default' do
          subject { described_class.resource(build(:memo), false, false) }
          it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::ResourceNotPersist) }
        end
      end

      context 'model is nil' do
        subject { described_class.resource(nil) }
        it { is_expected_block.to raise_exception(Monarchy::Exceptions::ResourceIsNil) }
      end

      context 'model is resource' do
        subject { described_class.resource(resource) }
        it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::ModelNotResource) }
        it { is_expected.to eq resource }
      end

      context 'model not resource' do
        subject { described_class.resource(user) }
        it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotResource) }
      end
    end
  end

  describe '.hierarchy' do
    context 'allow nil' do
      context 'persistance' do
        context 'turn on by default' do
          subject { described_class.hierarchy(nil, true) }
          it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::HierarchyNotPersist) }
        end

        context 'turn off by default' do
          subject { described_class.hierarchy(nil, true, false) }
          it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::HierarchyNotPersist) }
        end
      end

      context 'model is nil' do
        subject { described_class.hierarchy(nil, true) }
        it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::HierarchyIsNil) }
        it { is_expected.to be nil }
      end

      context 'model is hierarchy' do
        subject { described_class.hierarchy(hierarchy, true) }
        it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::ModelNotHierarchy) }
        it { is_expected.to eq hierarchy }
      end

      context 'model not hierarchy' do
        subject { described_class.hierarchy(user, true) }
        it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotHierarchy) }
      end
    end

    context 'not allow nil' do
      context 'persistance' do
        context 'turn on by default' do
          subject { described_class.hierarchy(build(:hierarchy)) }
          it { is_expected_block.to raise_exception(Monarchy::Exceptions::HierarchyNotPersist) }
        end

        context 'turn off by default' do
          subject { described_class.hierarchy(build(:hierarchy), false, false) }
          it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::HierarchyNotPersist) }
        end
      end

      context 'model is nil' do
        subject { described_class.hierarchy(nil) }
        it { is_expected_block.to raise_exception(Monarchy::Exceptions::HierarchyIsNil) }
      end

      context 'model is hierarchy' do
        subject { described_class.hierarchy(hierarchy) }
        it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::ModelNotHierarchy) }
        it { is_expected.to eq hierarchy }
      end

      context 'model not hierarchy' do
        subject { described_class.hierarchy(user) }
        it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotHierarchy) }
      end
    end
  end

  describe '.user' do
    context 'allow nil' do
      context 'model is nil' do
        subject { described_class.user(nil, true) }
        it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::UserIsNil) }
        it { is_expected.to be nil }
      end

      context 'model is user' do
        subject { described_class.user(user, true) }
        it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::ModelNotUser) }
        it { is_expected.to eq user }
      end

      context 'model not user' do
        subject { described_class.user(resource, true) }
        it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotUser) }
      end
    end

    context 'not allow nil' do
      context 'model is nil' do
        subject { described_class.user(nil) }
        it { is_expected_block.to raise_exception(Monarchy::Exceptions::UserIsNil) }
      end

      context 'model is user' do
        subject { described_class.user(user) }
        it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::ModelNotUser) }
        it { is_expected.to eq user }
      end

      context 'model not user' do
        subject { described_class.user(resource) }
        it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotUser) }
      end
    end
  end

  describe '.member' do
    let(:member) { user.grant(:member, resource) }

    context 'allow nil' do
      context 'model is nil' do
        subject { described_class.member(nil, true) }
        it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::MemberIsNil) }
        it { is_expected.to be nil }
      end

      context 'model is member' do
        subject { described_class.member(member, true) }
        it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::ModelNotMember) }
        it { is_expected.to eq member }
      end

      context 'model not member' do
        subject { described_class.member(resource, true) }
        it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotMember) }
      end
    end

    context 'not allow nil' do
      context 'model is nil' do
        subject { described_class.member(nil) }
        it { is_expected_block.to raise_exception(Monarchy::Exceptions::MemberIsNil) }
      end

      context 'model is member' do
        subject { described_class.member(member) }
        it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::ModelNotMember) }
        it { is_expected.to eq member }
      end

      context 'model not member' do
        subject { described_class.member(resource) }
        it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotMember) }
      end
    end
  end

  describe '.role' do
    let(:role) { member_role }

    context 'allow nil' do
      context 'model is nil' do
        subject { described_class.role(nil, true) }
        it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::RoleIsNil) }
        it { is_expected.to be nil }
      end

      context 'model is role' do
        subject { described_class.role(role, true) }
        it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::ModelNotRole) }
        it { is_expected.to eq role }
      end

      context 'model not role' do
        subject { described_class.role(resource, true) }
        it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotRole) }
      end
    end

    context 'not allow nil' do
      context 'model is nil' do
        subject { described_class.role(nil) }
        it { is_expected_block.to raise_exception(Monarchy::Exceptions::RoleIsNil) }
      end

      context 'model is role' do
        subject { described_class.role(role) }
        it { is_expected_block.not_to raise_exception(Monarchy::Exceptions::ModelNotRole) }
        it { is_expected.to eq role }
      end

      context 'model not role' do
        subject { described_class.role(resource) }
        it { is_expected_block.to raise_exception(Monarchy::Exceptions::ModelNotRole) }
      end
    end
  end
end
