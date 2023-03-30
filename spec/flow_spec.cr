require "./spec_helper"

describe Flow do
  Flow::VERSION.should be_nil(false)

  it "works" do
    false.should eq(true)
  end
end
