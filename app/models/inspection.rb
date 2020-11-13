class Inspection < ApplicationRecord
  belongs_to :machine

  has_many :inspection_filters, :dependent => :destroy

  # TODO(gyee): need to delete the exports on disk as well
  has_many :inspection_exports, :dependent => :destroy

  serialize :scopes

  validates :machine, presence: true
  validate :validate_scopes
  validate :set_start_time!

  #after_find do |inspection|
    #inspection.description = JSON.parse(inspection.description) if inspection.description
  #end

  def validate_scopes()
    if self.scopes.empty?
      self.scopes = machinery_scopes
    else
      scopes.each do |scope|
        unless machinery_scopes().include? scope
          logger.error("includes an invalid scope: '#{scope}'")
          errors.add(:scopes, "includes an invalid scope: '#{scope}'")
        end
      end
    end
  end

  def set_start_time!()
    self.start ||= DateTime.now.utc
  end

  def title()
    "#{self.machine.nickname} @ #{self.start}"
  end

  def machinery_scopes()
    @machinery_scopes ||= Machinery::Inspector.all_scopes()
  end

  def inspection_name()
    set_start_time!
    "#{machine.fqdn}--#{self.start.strftime("%Y%m%d.%H%M%S.%L")}"
  end

  def delayed_job_count()
    Delayed::Job.where(queue: self.id).count
  end

  def progress()
    (self.scopes.count - self.delayed_job_count) / self.scopes.count.to_f
  end

  def progress_percentage()
    sprintf '%.0f%%', 100 * self.progress
  end

  def complete?()
    self.progress >= 1
  end

  def current_status()
    self.status
  end

  def export_salt_states
    self.update(status: "Exporting Salt states")
    description = Machinery::SystemDescription.load(
      inspection_name(), Machinery::SystemDescriptionStore.new)
    exporter = Machinery::SaltStates.new(description)
    task = Machinery::ExportTask.new(exporter)
    task.export(
      File.expand_path("/srv/salt"),
      force: true
    )
  rescue Exception => e
    self.notes << "\nError during Salt states export: #{e}\n"
    self.save
  end

  def salt_states_archive_name()
    inspection_name = inspection_name()
    "/srv/salt/#{inspection_name}.tgz"
  end

  def create_salt_states_archive()
    # FIXME(gyee): need to store the Salt dir name in the DB so we don't
    # have to instantial the exporter in order to get the dir name.
    description = Machinery::SystemDescription.load(
      inspection_name(), Machinery::SystemDescriptionStore.new)
    exporter = Machinery::SaltStates.new(description)

    salt_dir = exporter.export_name
    file_list = ["/srv/salt/#{salt_dir}"]
    localhost = Machinery::System.for('localhost')
    self.update(status: "Creating Salt states archive")
    localhost.create_archive(file_list, salt_states_archive_name())
  rescue Exception => e
    logger.error(e.backtrace.join("\n"))
    self.notes << "\nError during Salt states archive creation: #{e}\n"
    self.save
    raise
  end

  def apply_salt_states(salt_minion)
    logger.info("Applying Salt states to #{salt_minion}")
    localhost = Machinery::System.for('localhost')
    
    # FIXME(gyee): need to store the Salt dir name in the DB so we don't
    # have to instantial the exporter in order to get the dir name.
    description = Machinery::SystemDescription.load(
      inspection_name(), Machinery::SystemDescriptionStore.new)
    exporter = Machinery::SaltStates.new(description)

    localhost.run_command('salt', salt_minion, 'state.apply',
      exporter.export_name, stdout: :capture, stderr: :capture,
      privileged: true)
  end

  def inspect_scopes
    self.update(status: "Inspecting scopes: #{self.scopes}")
    self.machine.with_machinery_system do |m_system|
      begin
        # NOTE(gyee): we always want to extract all files
        inspect_options = {
          :extract_changed_changed_config_files => true,
          :extract_changed_managed_files => true,
          :extract_unmanaged_files => true
        }

        filters = Machinery::Filter.new
        add_default_filters(filters)
        add_instance_filters(filters)
        task = Machinery::InspectTask.new
        task.inspect_system(
          Machinery::SystemDescriptionStore.new,
          m_system,
          inspection_name(),
          Machinery::CurrentUser.new,
          self.scopes,
          filters,
          inspect_options
        )

        # TODO(gyee): need to move these into a workflow method
        update_description_with_manifest()
      rescue Exception => e
        logger.error(e.backtrace.join("\n"))
        logger.error("Failed to inspect scopes '#{self.scopes}': #{e}")
        self.notes << "\nFailed to inspect scopes '#{self.scopes}': #{e}\n"
        self.save
      end
    end
  end

  def manifest_file_path()
    File.join(
      Machinery::SystemDescriptionStore.new.base_path,
      self.inspection_name,
      'manifest.json'
    )
  end

  def params_to_manifest(params)
    manifest_json = JSON.parse(params.to_json)

    # NOTE(gyee): remove these keys from ActionController:Parameters as they
    # are not part of the manifest. Effectives, these keys cannot be used in
    # any future manifest expension or otherwise we'll need to re-design
    # the update manifest API.
    ["controller", "action", "machine_fqdn", "id", "inspection"].each do |p|
      manifest_json.delete(p)
    end
    manifest_json
  end

  def update_manifest(manifest)
    File.open(manifest_file_path(), 'w') do |file|
      file.write(JSON.pretty_generate(manifest))
    end
  end

  def update_description_with_manifest()
    self.update(status: "Updating description")
    File.open(manifest_file_path()) do |file|
      self.update(description: file.read)
    end
  end

  def attach_description!()
    File.open(manifest_file_path()) do |file|
      self.description = JSON.parse(file.read)
    end
  end

  def report()
    @report ||= Machinery::SystemDescription.load(
      self.inspection_name,
      Machinery::SystemDescriptionStore.new
    )
  rescue
    @report = nil
  end

  private

    def add_default_filters(filters)
      DefaultInspectionFilter.all.each do |f|
        filter_string = "/#{f.scope}/#{f.definition}"
        logger.debug("adding default filter #{filter_string}")
        filters.add_element_filter_from_definition(filter_string)
      end
    end

    def add_instance_filters(filters)
      InspectionFilter.all.each do |f|
        filter_string = "/#{f.scope}/#{f.definition}"
        logger.debug("adding inspection filter #{filter_string}")
        filters.add_element_filter_from_definition(filter_string)
      end
    end
end
