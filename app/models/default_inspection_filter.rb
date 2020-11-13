class DefaultInspectionFilter < ApplicationRecord
  validates :scope,      presence: true
  validates :definition, presence: true
end
