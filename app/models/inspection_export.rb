class InspectionExport < ApplicationRecord
  belongs_to :inspection
  has_many   :aws_plans

  enum export_type: [:salt_states]
end
