require 'spec_helper'

describe User do
  it { should_not allow_mass_assignment_of(:admin) }

  it { should validate_presence_of(:display_name) }
  it { should validate_presence_of(:password) }
end
