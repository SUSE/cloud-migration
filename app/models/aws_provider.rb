# Copyright (c) 2020 SUSE LLC
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of version 3 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact SUSE LLC.
#
# To contact SUSE about this file by physical or electronic mail,
# you may find current contact information at www.suse.com
#
require 'cloud_utils'
class AWSProvider < CloudProvider
include CloudUtils
require 'aws-sdk-ec2'
require 'abstract_method'

  attr_accessor :instance_name, :image_id, :instance_type, :key_name, :subnet_id, :security_id, :availability_zone, :vpc_id, :iam_role, :secret_file_path 
  attr_accessor :instance_id, :salt_minion, :region

  def connect_using_config
    creds = CloudUtils.get_config_file(@secret_file_path)
    credentials = Aws::Credentials.new(
      creds['AccessKeyId'],
      creds['SecretAccessKey']
    )
    Aws.config.update({
      region: @region,
      credentials: credentials
    })

    @ec2 = Aws::EC2::Resource.new
  end

  def connect_using_iamrole
    creds = Aws::InstanceProfileCredentials.new

    Aws.config.update({
      region: @region,
      credentials: creds
    })

    @ec2 = Aws::EC2::Resource.new
  end

  def connect
    if CloudMigration::Application.config.aws_iam_authentication == false
      connect_using_config
    else
      connect_using_iamrole
    end
  end

  def wait_for_instances(state, ids)
    begin
      @ec2.client.wait_until(state, instance_ids: ids)
      puts "Success: #{state}."
    rescue Aws::Waiters::Errors::WaiterFailed => error
      puts "Failed: #{error.message}"
    end
  end
 
  def create_instance 
    connect 
    if @instance_name.nil?
       @instance_name = CloudUtils.generate_instance_name('cm-')
    end
   
    kwargs = {
      image_id: @image_id,
      min_count: 1,
      max_count: 1,
      instance_type: @instance_type,
      network_interfaces: [{
        device_index: 0,
        associate_public_ip_address: true
      }]
    } 

    if !@key_name.nil?
      kwargs = kwargs.merge(key_name: @key_name)
    end
 
    if !@security_grp.nil?
      kwargs = kwargs.merge(security_group_ids: [@security_grp])
    end

    if !@availability_zone.nil?
      kwargs = kwargs.merge(
        placement: { availability_zone: @availability_zone }
      )
    end

    if !@subnet_id.nil?
      kwargs = kwargs.merge(subnet_id: @subnet_id)
    end
      
    if !@iam_role.nil?
      kwargs = kwargs.merge(iam_instance_profile: { arn: @iam_role })
    end 

    instance = @ec2.create_instances(kwargs)

# Wait for the instance to be created, running, and passed status checks
    wait_for_instances(:instance_status_ok, [instance[0].id])

    instance.batch_create_tags({ tags: [{ key: 'Name', value: @instance_name }]})

    @instance_id = instance[0].id
    @salt_minion = instance[0].private_dns_name
  end

  def start_instance
    connect
    @ec2.client.start_instances({ instance_ids: [@instance_id] })
    wait_for_instances(:instance_running, [@instance_id])
  end

  def stop_instance
    connect
    @ec2.client.stop_instances({ instance_ids: [@instance_id] })
    wait_for_instances(:instance_stopped, [@instance_id])
  end

  def terminate_instance
    connect
    @ec2.client.terminate_instances({ instance_ids: [@instance_id] })
    wait_for_instances(:instance_terminated, [@instance_id])
  end

end  
