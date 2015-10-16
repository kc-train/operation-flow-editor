OEActionSelectGrid = React.createClass
  getInitialState: ->
    optional_actions: {}
    selected_ids: []

  render: ->
    <div className='actions-select-grid'>
      {
        for id, action of @state.optional_actions
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
        <div className='row'>
          <div className='col-sm-12'>
            <div className='form-group'>
              <label>后续操作(点击选中)</label>
              <OEActionSelectGrid ref='grids' />
            </div>
          </div>
        </div>
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

  set_optional_actions: (optional_actions)->
    @refs.grids.setState optional_actions: optional_actions

    return @

  get_action_data: ->
    id = @state.id || "id#{new Date().getTime()}"
    name = @state.name
    name = '未命名操作' if jQuery.trim(name).length is 0
    role = @state.role
    post_action_ids = @refs.grids.state.selected_ids

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
            <div data-id={action.id} key={action.id} className='action'>
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
      .set_optional_actions @state.actions
      .show()

  show_update_action_modal: (evt, react_id)->
    $a = jQuery("[data-reactid='#{react_id}']")
    $action = $a.closest('.action')
    id = $action.data('id')

    @refs.action_modal
      .set_action @state.actions[id]
      .set_optional_actions []
      .show()

  hide_action_modal: ->
    @refs.action_modal.hide()

  submit: ->
    action = @refs.action_modal.get_action_data()
    # console.log action
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
    .fail ->
      console.log 2