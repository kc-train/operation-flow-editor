OperationFlowEditor::Engine.routes.draw do
  root 'home#index'

  get '/yaml_sample', to: 'editor#yaml_sample'

  resources :flows
  get '/editor/:flow_id/actions', to: 'editor#actions'
end