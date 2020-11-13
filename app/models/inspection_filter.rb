class InspectionFilter < ApplicationRecord
  belongs_to :inspection

  validates :inspection, presence: true
  validates :scope,      presence: true
  validates :definition, presence: true
end
