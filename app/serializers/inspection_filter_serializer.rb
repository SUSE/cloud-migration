class InspectionFilterSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :scope, :definition, :description, :enable, :links

  def links
    { self: v1_machine_inspection_filter_url(
        @instance_options[:fqdn], object.inspection_id, object.id) }
  end
end
