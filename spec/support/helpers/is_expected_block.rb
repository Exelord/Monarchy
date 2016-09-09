module IsExpectedBlock
  def is_expected_block
    expect { subject }
  end
end

RSpec.configure do |c|
  c.include IsExpectedBlock
end
