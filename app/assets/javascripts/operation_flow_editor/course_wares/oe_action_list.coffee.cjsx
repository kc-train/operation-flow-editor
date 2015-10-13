@OEActionModal = React.createClass
  render: ->
    <BSModal show={@props.show} bs_size='default'>
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
        <BSButton onClick={@props.close}>
          <span>关闭</span>
        </BSButton>
      </BSModal.Footer>
    </BSModal>

@OEActionList = React.createClass
  getInitialState: ->
    show_action_modal: false
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
      <OEActionModal ref='action_modal' show={@state.show_action_modal} close={@close_action_modal} save={@create_action} />
    </div>

  show_action_modal: ->
    @setState
      show_action_modal: true

  close_action_modal: ->
    @setState
      show_action_modal: false

  create_action: ->
    $name_inputer = jQuery React.findDOMNode @refs.action_modal.refs.name_inputer
    console.log $name_inputer

    name = $name_inputer.val()
    if jQuery.trim(name).length is 0
      name = '未命名'

    action = {
      id: "id" + new Date().getTime()
      name: name
    }
    actions = @state.actions
    actions.push action
    @setState
      actions: actions

    jQuery.ajax
      url: @props.update_url
      type: 'PUT'
      data:
        actions: actions
    .done (res)=>
      $name_inputer.val('')
      @close_action_modal()
    .fail ->
      console.log 2

  remove_action: (evt, react_id)->
    $btn = jQuery("[data-reactid='#{react_id}']")
    $action = $btn.closest('.action')
    id = $action.data('id')

    if confirm '确定要删除吗？'
      actions = @state.actions
      actions = actions.filter (x)->
        "#{x.id}" != "#{id}"

      $action.fadeOut =>
        @setState
          actions: actions

    jQuery.ajax
      url: @props.update_url
      type: 'PUT'
      data:
        actions: actions
    .done (res)=>
      console.log 1
    .fail ->
      console.log 2