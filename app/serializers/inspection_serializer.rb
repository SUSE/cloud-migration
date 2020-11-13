class InspectionSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :description, :machine_id, :notes, :scopes, :status, :links
  type :inspection
  has_many :inspection_filters

  def links
    { self: v1_machine_inspection_url(@instance_options[:fqdn], object.id) }
  end
end
