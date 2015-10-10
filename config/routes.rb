OperationFlowEditor::Engine.routes.draw do
  root 'home#index'

  get '/roles', to: 'editor#roles'
  get '/actions', to: 'editor#actions'
  get '/yaml_sample', to: 'editor#yaml_sample'

  resources :flows
end