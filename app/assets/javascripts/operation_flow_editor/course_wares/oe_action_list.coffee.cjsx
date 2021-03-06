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
    saving: false

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
        {
          if @state.saving
            <div className='saving'>
              <i className='fa fa-spinner fa-pulse' />
              <span>正在保存</span>
            </div>
          else
            <BSButton onClick={@props.submit} bsstyle='primary'>
              <i className='fa fa-ok'></i>
              <span>确定保存</span>
            </BSButton>
        }
        <BSButton onClick={@hide}>
          <span>关闭</span>
        </BSButton>
      </BSModal.Footer>
    </BSModal>

  show: ->
    @setState 
      show: true
      saving: false

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


OEScreenModal = React.createClass
  getInitialState: ->
    action: null
  render: ->
    <BSModal.FormModal ref='modal' title="流程节点设置 - #{@state.action?.name}" bs_size='lg' submit={@submit}>

      <div className='action-node-edit'>
        <ul className="nav nav-tabs" role="tablist">
          <li role="presentation" className="active"><a href="#modal-screen" aria-controls="home" role="tab" data-toggle="tab">屏幕关联</a></li>
          <li role="presentation"><a href="#modal-desc" aria-controls="profile" role="tab" data-toggle="tab">描述文本</a></li>
          <li role="presentation"><a href="#modal-attach" aria-controls="messages" role="tab" data-toggle="tab">上传附件</a></li>
          <li role="presentation"><a href="#modal-knet" aria-controls="settings" role="tab" data-toggle="tab">知识关联</a></li>
        </ul>

        <div className="tab-content">
          <div role="tabpanel" className="tab-pane active screen-table" id="modal-screen">
            <ScreensTable ref='table' data={@props.screen_data} xmdm={@props.flow.number} />
          </div>
          <div role="tabpanel" className="tab-pane" id="modal-desc">
            <textarea className='desc-area form-control' placeholder='填写介绍说明内容' rows='10'></textarea>
          </div>
          <div role="tabpanel" className="tab-pane upload" id="modal-attach">
            <label>上传说明附件</label>
            <input type='file' />
          </div>
          <div role="tabpanel" className="tab-pane klink" id="modal-knet">
            从知识网络关联教材知识点（制作中）
          </div>
        </div>
      </div>
    </BSModal.FormModal>

  show: ->
    @refs.modal.show()

  hide: ->
    @refs.modal.hide()

  submit: ->
    hmdms = @refs.table.state.linked_hmdms
    @state.action.linked_screen_ids = hmdms

    @refs.modal.setState saving: true
    @props.handle.save_actions @props.handle.state.actions



ScreensTable = React.createClass
  displayName: 'ScreensTable'
  getInitialState: ->
    linked_hmdms: []

  render: ->
    <table className='table table-striped table-bordered'>
      <thead><tr>
        <th>联动交易</th><th>输入屏幕</th><th>响应屏幕</th><th>复核屏幕</th>
      </tr></thead>
      <tbody>
      {
        idx = 0
        for ldjy in @props.data
          <tr key={idx++}>
            <td>{ldjy.jymc}-{ldjy.jydm}</td>
            <td>
            {
              for screen in ldjy.input_screens || []
                checked = @state.linked_hmdms.indexOf(screen.hmdm) > -1 
                <ScreensTable.Screen checked={checked} key={screen.hmdm} data={screen} xmdm={@props.xmdm} on_click={@on_click} />
            }
            </td>
            <td>
            {
              if ldjy.response_screen?
                checked = @state.linked_hmdms.indexOf(ldjy.response_screen.hmdm) > -1 
                <ScreensTable.Screen checked={checked} data={ldjy.response_screen} xmdm={@props.xmdm} on_click={@on_click} />
            }
            </td>
            <td>
            {
              if ldjy.compound_screen
                checked = @state.linked_hmdms.indexOf(ldjy.compound_screen.hmdm) > -1 
                <ScreensTable.Screen checked={checked} data={ldjy.compound_screen} xmdm={@props.xmdm} on_click={@on_click} />
            }
            </td>
          </tr>
      }
      </tbody>
    </table>

  on_click: (evt)->
    $screen = jQuery(evt.target).closest('.screen')
    hmdm = $screen.data('hmdm') + ""
    linked_hmdms = @state.linked_hmdms
    if $screen.hasClass('checked')
      linked_hmdms = linked_hmdms.filter (x)->
        x != hmdm
    else
      linked_hmdms.push hmdm

    @setState linked_hmdms: linked_hmdms

  statics: 
    Screen: React.createClass
      getInitialState: ->
        show: false
      render: ->
        klass = if @props.checked then 'screen checked' else 'screen'

        <div className={klass} data-hmdm={@props.data.hmdm}>
          <a href="/editor/screen/#{@props.xmdm}/#{@props.data.hmdm}" target='_blank'>{@props.data.hmdm}</a>
          <div className='cb' onClick={@props.on_click}>
            <i className='fa fa-check' />
          </div>
        </div>



@OEActionList = React.createClass
  displayName: 'OEActionList'
  getInitialState: ->
    actions: @props.flow.actions || {}

  render: ->
    <div className='OEActionList'>
      <div className='toolbar'>
        <a className='add-action' href='javascript:;' onClick={@show_create_action_modal}>
          <i className='fa fa-plus'></i>
        </a>
        <div className='baseinfo'>
          <div className='number'>{@props.flow.number}</div>
          <div className='name'>{@props.flow.name}</div>
        </div>
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
              <a className='screen' href='javascript:;' onClick={@show_screen_modal}>
                <i className='fa fa-desktop'></i>
              </a>
              <a className='remove' href='javascript:;' onClick={@remove_action}>
                <i className='fa fa-times'></i>
              </a>
            </div>
        }
      </div>
      <OEActionModal ref='action_modal' submit={@submit} actions={@state.actions} />
      <OEScreenModal ref='screen_modal' flow={@props.flow} screen_data={@props.screen_data} handle={@} />
    </div>

  show_screen_modal: (evt)->
    action_id = jQuery(evt.target).closest('.action').data('id')

    action = @state.actions[action_id]
    @refs.screen_modal.setState
      action: action
    @refs.screen_modal.refs.table.setState
      linked_hmdms: action.linked_screen_ids || []
    @refs.screen_modal.refs.modal.setState
      saving: false

    @refs.screen_modal.show()


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

  hide_screen_modal: ->
    @refs.screen_modal.hide()

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
    @refs.action_modal.setState saving: true

    jQuery.ajax
      url: @props.update_url
      type: 'PUT'
      data:
        actions: actions
    .done (res)=>
      @hide_action_modal()
      @hide_screen_modal()
      @setState actions: actions
      jQuery(document).trigger 'editor:action-changed', actions
    .fail ->
      console.log 2
