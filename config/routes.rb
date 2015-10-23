OperationFlowEditor::Engine.routes.draw do
  root 'home#index'

  get '/yaml_sample', to: 'editor#yaml_sample'

  resources :flows
  get '/editor/:flow_id/actions', to: 'editor#actions'
  put '/editor/:flow_id/actions', to: 'editor#update_actions', as: 'update_actions'

  get '/demo/screen_parse', to: 'home#screen_parse'
  get '/oracle_json', to: 'home#oracle_json'
  get '/screen/:id', to: 'home#screen'
end