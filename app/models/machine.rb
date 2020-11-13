class SshValidationError < StandardError; end

class Machine < ApplicationRecord
  has_many :inspections, :dependent => :destroy

  validates :fqdn,     presence: true, uniqueness: true
  validates :port,     presence: true
  validates :nickname, presence: true
  validates :user,     presence: true
  validates :key,      presence: true
  validate :validate_prerequisites

  PREREQUISITES = [
    ['rpm', 'dpkg'],
    ['zypper', 'yum', 'apt-cache'],
    ['rsync'],
    ['chkconfig', 'initctl', 'systemctl', '/sbin/chkconfig'],
    ['cat'],
    ['sed'],
    ['find'],
    ['tar']
  ]

  @machinery_config = Machinery::Config.new

  def with_machinery_system
    identity_file = Tempfile.new(fqdn)
    begin
      identity_file.write(key)
      identity_file.close
      m_system = Machinery::System.for(
        fqdn,
        remote_user: user,
        ssh_port: port,
        ssh_identity_file: identity_file.path
      )
      yield(m_system)
    ensure
      identity_file.close
      identity_file.unlink
    end
  end

  def know_host()
    error_msg = nil
    begin
      Net::SSH.start(
        self.fqdn,
        self.user,
        port:         self.port,
        key_data:     [key],
        auth_methods: ['publickey'],
        keys_only:    true,
        config:       false,
        timeout:      10,
        logger:       logger,
        verbose:      Logger::DEBUG
      ){|session| session.exec! "echo 'success'" }
    rescue Timeout::Error, Errno::ETIMEDOUT, Net::SSH::ConnectionTimeout
      error_msg = "SSH attempt timed out before a connection was made."
    rescue Errno::EHOSTUNREACH
      error_msg = "#{self.fqdn} is unreachable."
    rescue Errno::ECONNREFUSED
      error_msg = "#{self.fqdn} is not listening for connections on port #{self.port}."
    rescue ArgumentError
      error_msg = "Invalid SSH key."
    rescue Net::SSH::AuthenticationFailed
      error_msg = "The provided key was not accepted for user '#{self.user}'."
    end
    if error_msg then
      raise SshValidationError,
        [
          error_msg,
          "If this is a new VM, please wait for provisioning to complete.",
          "Otherwise, please check the connection settings and try again."
        ].join(' ')
    end
  end

  def validate_prerequisites()
    know_host()
    with_machinery_system do |m_system|
      @tools = PREREQUISITES.collect do |commands|
        unless commands.any? {|cmd| m_system.has_command? cmd }
          errors.add(
            :meets_prerequisites,
            "Need binary '#{commands.join("' or '")}' to be available on the inspected system."
          )
        end
      end
      m_system.check_create_archive_dependencies
      m_system.check_retrieve_files_dependencies
    end
  rescue => e
    errors.add(:meets_prerequisites, "^#{e.class}: #{e.message}")
  rescue Exception => ee
    logger.error("^#{ee.class}: #{ee.message}")
    errors.add(:meets_prerequisites, "Internal error.")
  ensure
    return self.meets_prerequisites = errors[:meets_prerequisites].blank?
  end

  def title()
    self.nickname
  end

  # Enables routing on fqdn instead of id for generated routes
  def to_param
    self.fqdn
  end

  def to_uri
    uri = ''
    if user != 'root'
      uri << "#{self.user}@"
    end
    uri << self.fqdn
    if self.port != 22
      uri << ":#{self.port}"
    end
    return uri
  end
end
