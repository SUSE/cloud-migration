# spec/requests/migrations_aws_vms_spec.rb
require 'rails_helper'
require 'byebug'
require_relative '../../../../../app/models/aws_provider.rb'
RSpec.describe 'Migrations AWS VMS API', type: :request do

  #Initialize test data
  describe '#instance_created?' do
    let(:migrations_aws_vm_params) do {"migrations_aws_vm": {"region": "us-east-2","image_id": "ami-03f4c416f489586a3","instance_type": "t2.micro"}} end
    let(:region) { 'us-east-2' }
    let(:image_id) { 'ami-03f4c416f489586a3' }
    let(:instance_type) { 't2.micro' }
    let(:instance_id) { 'i-01c7a43263ddbc7EX' }
    let(:ec2_client) do
      Aws::EC2::Client.new(
        stub_responses: {
          create_instances: {
            region: region,
            image_id: image_id,
            instance_type: instance_type,
            key_name: key_pair_name
          },
          start_instances: {
            instances: [
              instance_id: instance_id
            ]
          },
          create_tags: {}
        }
      )
    end
    let(:ec2) { Aws::EC2::Resource.new(client: ec2_client) }
    it 'creates an instance' do
#      byebug
#      connect = double("AWSProvider.connect")
#      connect.stub(@AWSProvider.connect).and_return(:ec2)
#       (@AWSProvider.connect).stub(:ec2) { :ec2 }
#      expect(connect).and_return(:ec2)
      expect(AWSProvider).to receive(:connect).and_return(:ec2)
#      allow("AWSProvider.connect_with_config").and_return( :ec2)
      post '/v1/migrations/aws/vms', params: migrations_aws_vm_params, headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'supersecret') }
      puts response.body
      expect(response.status).to eq 201
    end

    it 'gets an instance' do
#      byebug
      get '/v1/migrations/aws/vms', headers: { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'supersecret') }
      puts response.body
      expect(response.status).to eq 200
    end
  end
end


