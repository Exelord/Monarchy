# frozen_string_literal: true
require 'rails_helper'

describe Monarchy::Hierarchy, type: :model do
  it { is_expected.to have_many(:members).dependent(:destroy) }
  it { is_expected.to belong_to(:resource).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:resource) }
end
