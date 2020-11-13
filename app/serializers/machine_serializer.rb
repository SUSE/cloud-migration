class MachineSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :fqdn, :port, :nickname, :user, :key, :notes, :links
  type :machine

  def links
    { self: v1_machine_url(object) }
  end

  #def links
  #  [
  #    {
  #      rel: :self,
  #      href: v1_machine_url(object)
  #    }
  #  ]
  #end
end
