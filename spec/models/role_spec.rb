# frozen_string_literal: true

require 'rails_helper'

describe Monarchy::Role, type: :model do
  it { is_expected.to have_many(:members).through(:members_roles) }
  it { is_expected.to have_many(:members_roles).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:level) }
end
