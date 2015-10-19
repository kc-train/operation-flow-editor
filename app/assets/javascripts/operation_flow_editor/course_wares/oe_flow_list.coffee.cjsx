OEFlowModal = React.createClass
  getInitialState: ->
    show_modal: false
    flow: {}

  render: ->
    <BSModal show={@state.show_modal}>
      <BSModal.Header>
        <BSModal.Title>增加操作流程</BSModal.Title>
      </BSModal.Header>
      <BSModal.Body>
        <div className='form-group'>
          <input className='form-control' type='text' placeholder='编号' ref='number_inputer' value={@state.flow.number} onChange={@number_changed} />
        </div>
        <div className='form-group'>
          <input className='form-control' type='text' placeholder='名称' ref='name_inputer' value={@state.flow.name} onChange={@name_changed} />
        </div>
      </BSModal.Body>
      <BSModal.Footer>
        <BSButton onClick={@props.submit} bsstyle='primary'>
          <i className='fa fa-ok'></i>
          <span>确定保存</span>
        </BSButton>
        <BSButton onClick={@close_modal}>
          <span>关闭</span>
        </BSButton>
      </BSModal.Footer>
    </BSModal>

  close_modal: ->
    @setState show_modal: false

  number_changed: (evt)->
    flow = @state.flow
    flow.number = evt.target.value
    @setState flow: flow

  name_changed: (evt)->
    flow = @state.flow
    flow.name = evt.target.value
    @setState flow: flow

@OEFlowList = React.createClass
  # props
  #   show
  #   close

  getInitialState: ->
    show_modal: false
    flows: @props.flows || []

  render: ->
    <div className='OEFlowList'>
      <div className='toolbar'>
        <BSButton onClick={@show_create_modal}>
          <i className='fa fa-plus'></i>
          <span>增加操作流程</span>
        </BSButton>
      </div>

      <OEFlowModal ref='modal' submit={@submit} />

      <table className='flows table table-striped table-borderd'>
        <thead><tr>
          <th>id</th>
          <th>number</th>
          <th>name</th>
          <th>ops</th>
        </tr></thead>
        <tbody>
          {
            for flow in @state.flows
              <tr data-id={flow.id} key={flow.id} className='flow'>
                <td>{flow.id}</td>
                <td>{flow.number}</td>
                <td>{flow.name}</td>
                <td>
                  <div className='btn-group'>
                    <BSButton bssize='xs' onClick={@show_update_modal}>
                      <i className='fa fa-pencil'></i>
                      <span>修改</span>
                    </BSButton>
                    <BSButton bssize='xs' href="./editor/#{flow.id}/actions" target='_blank'>
                      <i className='fa fa-pencil'></i>
                      <span>设计</span>
                    </BSButton>

                  </div>
                </td>
              </tr>
          }
        </tbody>
      </table>
    </div>

  show_create_modal: ->
    @refs.modal.setState
      show_modal: true
      flow: {}

  show_update_modal: (evt)->
    $btn = jQuery(evt.target)
    flow_id = $btn.closest('tr').data('id')
    flow = (@state.flows.filter (x)->
      x.id == flow_id)[0]

    console.log flow

    @refs.modal.setState
      show_modal: true
      flow: flow

  submit: ->
    number = @refs.modal.state.flow.number
    name = @refs.modal.state.flow.name
    id = @refs.modal.state.flow.id

    if not id?
      jQuery.ajax
        url: './flows'
        type: 'POST'
        data:
          flow:
            number: number
            name: name
      .done (res)=>
        flows = @state.flows
        flows = [res].concat flows
        @setState
          flows: flows
        @refs.modal.close_modal()
      .fail ->
        console.log 2

    else
      jQuery.ajax
        url: "./flows/#{id}"
        type: 'PUT'
        data:
          flow:
            number: number
            name: name
      .done (res)=>
        flows = @state.flows
        for flow in flows
          if flow.id == id
            flow.name = name
            flow.number = number
        @setState
          flows: flows
        @refs.modal.close_modal()
      .fail ->
        console.log 2

  remove: (evt, react_id)->
    $btn = jQuery("[data-reactid='#{react_id}']")
    $tr = $btn.closest('tr')
    id = $tr.data('id')
    if confirm '确定要删除吗？'
      jQuery.ajax
        url: "./flows/#{id}"
        type: 'DELETE'
      .done (res)=>
        $tr.fadeOut =>
          @setState
            flows: @state.flows.filter (x)-> x.id != id