OEActionSelectGrid = React.createClass
  displayName: 'OEActionSelectGrid'
  getInitialState: ->
    selected_ids: []

  render: ->
    <div className='actions-select-grid'>
      {
        for id, action of @props.optional_actions
          klass = ['action']
          klass.push 'selected' if @state.selected_ids.indexOf(id) > -1

          <div key={action.id} className={klass.join(' ')} data-id={action.id}>
            <div className='inner' onClick={@select}>
              <div className='name'>{action.name}</div>
            </div>
          </div>
      }
    </div>

  select: (evt)->
    $action = jQuery(evt.target).closest('.action')
    id = $action.data('id')

    selected_ids = @state.selected_ids

    if selected_ids.indexOf(id) > -1
      selected_ids = selected_ids.filter (x)-> x != id
    else
      selected_ids.push id

    @setState selected_ids: selected_ids


OEActionModal = React.createClass
  getInitialState: ->
    show: false
    id: null
    name: ''
    role: '柜员'
    optional_actions: {}

  render: ->
    if @state.id?
      title = '修改操作节点'
    else
      title = '新增操作节点'

    <BSModal show={@state.show} bs_size='default'>
      <BSModal.Header>
        <BSModal.Title>{title}</BSModal.Title>
      </BSModal.Header>
      <BSModal.Body>
        <div className='row'>
          <div className='col-sm-8'>
            <div className='form-group'>
              <label>操作名称</label>
              <input ref='name_inputer' name='name' className='form-control' type='text' placeholder='名称' value={@state.name} onChange={@on_name_change} />
            </div>
          </div>
          <div className='col-sm-4'>
            <div className='form-group'>
              <label>操作角色</label>
              <select ref='role_inputer' className='form-control' onChange={@on_role_change} value={@state.role}>
                <option value='柜员'>柜员</option>
                <option value='客户'>客户</option>
              </select>
            </div>
          </div>
        </div>
        {
          if Object.keys(@state.optional_actions).length
            klass = 'row'
          else
            klass = 'row hide'

          <div className={klass}>
            <div className='col-sm-12'>
              <div className='form-group'>
                <label>后续操作(点击选中)</label>
                <OEActionSelectGrid ref='grids' optional_actions={@state.optional_actions} />
              </div>
            </div>
          </div>
        }
      </BSModal.Body>
      <BSModal.Footer>
        <BSButton onClick={@props.submit} bsstyle='primary'>
          <i className='fa fa-ok'></i>
          <span>确定保存</span>
        </BSButton>
        <BSButton onClick={@hide}>
          <span>关闭</span>
        </BSButton>
      </BSModal.Footer>
    </BSModal>

  show: ->
    @setState show: true

  hide: ->
    @setState show: false

  set_action: (action)->
    @setState
      id: action.id
      name: action.name
      role: action.role

    return @

  set_optional_actions: (optional_actions, selected_ids)->
    @setState optional_actions: optional_actions
    @refs.grids.setState selected_ids: selected_ids.map (x)-> x

    return @

  get_action_data: ->
    id = @state.id || "id#{new Date().getTime()}"
    name = @state.name
    name = '未命名操作' if jQuery.trim(name).length is 0
    role = @state.role
    post_action_ids = (_id for _id in @refs.grids.state.selected_ids)

    id: id
    name: name
    role: @state.role
    post_action_ids: post_action_ids

  on_name_change: (evt)->
    @setState name: evt.target.value

  on_role_change: (evt)->
    @setState role: evt.target.value


@OEActionList = React.createClass
  displayName: 'OEActionList'
  getInitialState: ->
    actions: @props.actions || {}

  render: ->
    <div className='OEActionList'>
      <div className='toolbar'>
        <a className='add-action' href='javascript:;' onClick={@show_create_action_modal}>
          <i className='fa fa-plus'></i>
        </a>
      </div>
      <div className='actions-list'>
        {
          for id, action of @state.actions
            <div data-role={action.role} data-id={action.id} key={action.id} className='action'>
              <div className='name'>{action.name}</div>
              <div className='role'>{action.role}</div>
              <a className='link' href='javascript:;' onClick={@show_update_action_modal}>
                <i className='fa fa-pencil'></i>
              </a>
              <a className='remove' href='javascript:;' onClick={@remove_action}>
                <i className='fa fa-times'></i>
              </a>
            </div>
        }
      </div>
      <OEActionModal ref='action_modal' submit={@submit} actions={@state.actions} />
    </div>

  show_create_action_modal: ->
    action = 
      id: null
      name: ''
      role: '柜员'
      post_action_ids: []

    @refs.action_modal
      .set_action action
      .set_optional_actions {}, []
      .show()

  show_update_action_modal: (evt)->
    $a = jQuery evt.target
    $action = $a.closest('.action')
    id = $action.data('id')

    action = @state.actions[id]
    optional_actions = {}
    all_pres_action_ids = Object.keys @get_all_pres_actions action

    for a_id, _action of @state.actions
      if all_pres_action_ids.indexOf(_action.id) < 0
        optional_actions[_action.id] = _action

    console.log action
    @refs.action_modal
      .set_action action
      .set_optional_actions optional_actions, action.post_action_ids || []
      .show()

  # 获取所有直接前置节点
  get_pre_actions: (action)->
    pre_actions = {}
    for _id, _action of @state.actions
      if (_action.post_action_ids || []).indexOf(action.id) > -1
        pre_actions[_action.id] = _action
    pre_actions 

  get_all_pres_actions: (action)->
    all_pres_actions = {}
    @_r_ga action, all_pres_actions
    all_pres_actions


  _r_ga: (action, all_pres_actions)->
    all_pres_actions[action.id] = action
    for _id, _action of @get_pre_actions(action)
      @_r_ga _action, all_pres_actions


  hide_action_modal: ->
    @refs.action_modal.hide()

  submit: ->
    action = @refs.action_modal.get_action_data()
    actions = @state.actions
    actions[action.id] = action
    @save_actions actions

  remove_action: (evt, react_id)->
    $btn = jQuery("[data-reactid='#{react_id}']")
    $action = $btn.closest('.action')
    id = $action.data('id')

    if confirm '确定要删除吗？'
      actions = @state.actions
      delete actions[id]

      # 从其他节点的后续节点中去掉
      for _id, action of actions
        if action.post_action_ids?
          action.post_action_ids = action.post_action_ids.filter (x)->
            x != id

      $action.fadeOut =>
        @save_actions actions

  save_actions: (actions)->
    jQuery.ajax
      url: @props.update_url
      type: 'PUT'
      data:
        actions: actions
    .done (res)=>
      @hide_action_modal()
      @setState actions: actions
      jQuery(document).trigger 'editor:action-changed', actions
    .fail ->
      console.log 2


# @OEFlowEditor = React.createClass
#   displayName: 'OEFlowEditor'
#   getInitialState: ->
#     actions: @props.actions

#   render: ->
#     <div className='editor'>
#       <OEActionList actions={@state.actions} update_url={@props.update_url} />
#       <div className='preview'>
#         <OEPreviewer data={actions: @state.actions} />
#       </div>
#     </div>

#   componentDidMount: ->
#     jQuery(document).on 'editor:action-changed', (evt, actions)=>
#       @setState actions: actions