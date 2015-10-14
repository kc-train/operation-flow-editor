@OEActionModal = React.createClass
  getInitialState: ->
    show: false

  render: ->
    <BSModal show={@state.show} bs_size='default'>
      <BSModal.Header>
        <BSModal.Title>增加操作节点</BSModal.Title>
      </BSModal.Header>
      <BSModal.Body>
        <div className='form-group'>
          <input ref='name_inputer' name='name' className='form-control' type='text' placeholder='名称' />
        </div>
      </BSModal.Body>
      <BSModal.Footer>
        <BSButton onClick={@props.save} bsstyle='primary'>
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

  get_name: ->
    $name_inputer = jQuery React.findDOMNode @refs.name_inputer
    name = $name_inputer.val()
    name = '未命名' if jQuery.trim(name).length is 0
    name

  get_action_data: ->
    id: "id" + new Date().getTime()
    name: @get_name()

  clear_name: ->
    $name_inputer = jQuery React.findDOMNode @refs.name_inputer
    $name_inputer.val('')



@OEActionList = React.createClass
  getInitialState: ->
    actions: @props.actions || []

  render: ->
    <div className='OEActionList'>
      <div className='toolbar'>
        <a className='add-action' href='javascript:;' onClick={@show_action_modal}>
          <i className='fa fa-plus'></i>
        </a>
      </div>
      <div className='actions-list'>
        {
          for action in @state.actions
            <div data-id={action.id} key={action.id} className='action'>
              <div className='name'>{action.name}</div>
              <a className='link' href='javascript:;' onClick={@show_action_modal}>
                <i className='fa fa-link'></i>
              </a>
              <a className='remove' href='javascript:;' onClick={@remove_action}>
                <i className='fa fa-times'></i>
              </a>
            </div>
        }
      </div>
      <OEActionModal ref='action_modal' save={@create_action} />
    </div>

  show_action_modal: ->
    @refs.action_modal.show()

  hide_action_modal: ->
    @refs.action_modal.hide()

  create_action: ->
    action = @refs.action_modal.get_action_data()

    actions = @state.actions
    actions.push action
    @save_actions actions

  remove_action: (evt, react_id)->
    $btn = jQuery("[data-reactid='#{react_id}']")
    $action = $btn.closest('.action')
    id = $action.data('id')

    if confirm '确定要删除吗？'
      actions = @state.actions
      actions = actions.filter (x)->
        "#{x.id}" != "#{id}"

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