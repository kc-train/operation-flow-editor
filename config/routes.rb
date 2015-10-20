OperationFlowEditor::Engine.routes.draw do
  root 'home#index'

  get '/yaml_sample', to: 'editor#yaml_sample'

  resources :flows
  get '/editor/:flow_id/actions', to: 'editor#actions'
  put '/editor/:flow_id/actions', to: 'editor#update_actions', as: 'update_actions'

  get '/quick-chat-note', to: 'home#qcn'
end