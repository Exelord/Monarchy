# frozen_string_literal: true
require 'rails_helper'

describe Monarchy::Hierarchy, type: :model do
  it { is_expected.to have_many(:members) }
  it { is_expected.to belong_to(:resource) }

  it { is_expected.to validate_presence_of(:resource) }
end
