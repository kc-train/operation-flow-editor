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
  get 'net/:name/catalog', to: 'net#catalog', as: 'net_catalog'
  get 'net/:name/tags', to: 'net#tags', as: 'net_tags'
  get 'net/:name/tagging', to: 'net#tagging', as: 'net_tagging'
  post 'net/:name/create_tagging_store', to: 'net#create_tagging_store', as: 'net_create_tagging_store'
  get 'net/:name/get_tagging_store/:id', to: 'net#get_tagging_store', as: 'net_get_tagging_store'
  put 'net/:name/save_tagging_store/:id', to: 'net#save_tagging_store', as: 'net_save_tagging_store'
end