# spec/models/migrations_aws_vm_spec.rb
require 'rails_helper'

# Test suite for the Todo model
RSpec.describe MigrationsAwsVm, type: :model do
  # Validation tests
  it { should validate_presence_of(:region) }
  it { should validate_presence_of(:image_id) }
  it { should validate_presence_of(:instance_type) }
end
