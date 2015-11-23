OperationFlowEditor::Engine.routes.draw do
  root 'home#index'

  # 课件编辑
  resources :flows
  get '/editor/:flow_id/actions', to: 'editor#actions'
  put '/editor/:flow_id/actions', to: 'editor#update_actions', as: 'update_actions'
  get '/editor/screen/:xmdm/:hmdm', to: 'editor#screen'

  # 进度概览
  get '/progress', to: 'home#progress', as: 'progress'
  get '/xmdm/:xmdm', to: 'home#xmdm'


  # 查询规则说明
  get '/query_rule', to: 'home#screen_parse', as: 'query_rule'
  get '/oracle_json', to: 'home#oracle_json'

  # 课件展示
  get '/show', to: 'home#show', as: 'show'
  get '/cw/:xmdm', to: 'course_ware#show'

  # 知识网络组织
  get 'net', to: 'net#index', as: 'net'
  get 'net/:name', to: 'net#show', as: 'net_show'
end