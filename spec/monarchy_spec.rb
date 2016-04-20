# frozen_string_literal: true
require 'rails_helper'

describe Monarchy do
  it 'has a version number' do
    expect(Monarchy::VERSION).not_to be nil
  end
end
