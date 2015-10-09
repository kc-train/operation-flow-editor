OperationFlowEditor::Engine.routes.draw do
  root 'home#index'

  get '/roles', to: 'home#roles'
  get '/actions', to: 'home#actions'
end