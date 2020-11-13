Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :v1 do
    constraints(fqdn: /[a-z0-9\-\.]+/) do
      resources :machines, param: :fqdn do
        resources :inspections, param: :id do
          get :manifest, on: :member
          put :manifest, on: :member, to: 'inspections#update_manifest'
          put :start,    on: :member, to: 'inspections#start_inspection'
          resources :filters, param: :id, controller: 'inspection_filters'
          resources :exports, param: :id, controller: 'inspection_exports' do
            get :archive, on: :member
          end
        end
      end
      namespace :defaults do
        namespace :inspection do
          resources :filters, param: :id
        end
      end
      namespace :migrations do
        namespace :aws do
          resources :vms, param: :instance_id do 
            put :stop, on: :member, to: 'vms#stop_instance' 
            put :start, on: :member, to: 'vms#start_instance'
            put :terminate, on: :member, to: 'vms#terminate_instance'

            resources :plans, param: :id
          end
        end
      end
    end
  end

  get '/*a', to: 'application#not_found'

end
