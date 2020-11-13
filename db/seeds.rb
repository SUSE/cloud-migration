# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/etc/passwd')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/etc/shadow')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/etc/group')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/tmp')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/var/tmp')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/lost+found')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/var/run')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/var/lock')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/var/lib/rpm')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/.snapshots')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/proc')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/etc/init.d/boot.d')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/etc/init.d/rc0.d')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/etc/init.d/rc1.d')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/etc/init.d/rc2.d')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/etc/init.d/rc3.d')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/etc/init.d/rc4.d')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/etc/init.d/rc5.d')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/etc/init.d/rc6.d')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/etc/init.d/rcS.d')
DefaultInspectionFilter.create(scope: 'unmanaged_files',
                               definition: 'name=/var/lib/dpkg')

# TODO(gyee): remove the MigrationsAwsVms data. This is for testing only.
MigrationsAwsVm.create(instance_id: 'foo', image_id: 'test_image',
                       instance_type: 'aws', key_name: 'key',
                       subnet_id: '1', security_id: '1',
                       availability_zone: 'us-west', vpc_id: '1',
                       iam_role: 'all')
