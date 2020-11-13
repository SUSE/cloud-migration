class AwsPlan < ApplicationRecord
  belongs_to :migrations_aws_vm
  belongs_to :inspection_export

  enum status: [ :migration_scheduled, :migration_started,
                 :migration_completed, :migration_failed]

  def execute_plan()
    self.update(status: "migration_started")
    self.inspection_export.inspection.apply_salt_states(self.salt_minion)
  rescue Exception => e
    logger.error(e.backtrace.join("\n"))
    logger.error("Failed to apply Salt states to #{self.salt_minion}: #{e}")
    if e.is_a? Cheetah::ExecutionFailed
      logger.error("STDOUT: #{e.stdout}")
      logger.error("STDERR: #{e.stderr}")
    end
    self.update(status: "migration_failed",
      notes: "Failed to apply Salt states to #{self.salt_minion}: #{e}")
  end
end
