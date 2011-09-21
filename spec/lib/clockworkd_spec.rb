require 'spec_helper'

describe Clockworkd do
  it "should define rails" do
    ::Rails::VERSION::MAJOR.should be
  end

end
