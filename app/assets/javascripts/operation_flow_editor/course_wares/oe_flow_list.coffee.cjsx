OEFlowModal = React.createClass
  getInitialState: ->
    show_modal: false
    flow: {}
    saving: false

  render: ->
    <BSModal show={@state.show_modal}>
      <BSModal.Header>
        {
          if @state.flow.id?
            <BSModal.Title>修改操作流程</BSModal.Title>
          else
            <BSModal.Title>增加操作流程</BSModal.Title>
        }
        
      </BSModal.Header>
      <BSModal.Body>
        <div className='form-group'>
          <label>编号</label>
          <input className='form-control' type='text' placeholder='编号' ref='number_inputer' value={@state.flow.number} onChange={@number_changed} />
        </div>
        <div className='form-group'>
          <label>名称</label>
          <input className='form-control' type='text' placeholder='名称' ref='name_inputer' value={@state.flow.name} onChange={@name_changed} />
        </div>
        {
          if @state.flow.id?
            <div className='form-group'>
              <label>流程制作状态</label>
              <select className='form-control' ref='gtd_status_inputer' value={@state.flow.gtd_status} onChange={@gtd_status_changed} >
                <option value='init'>才开始</option>
                <option value='half'>做一半了</option>
                <option value='almost'>快做完了</option>
                <option value='done'>做完了</option>
              </select>
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
        <BSButton onClick={@close_modal}>
          <span>关闭</span>
        </BSButton>
      </BSModal.Footer>
    </BSModal>

  close_modal: ->
    @setState 
      show_modal: false

  number_changed: (evt)->
    flow = @state.flow
    flow.number = evt.target.value
    @setState flow: flow

  name_changed: (evt)->
    flow = @state.flow
    flow.name = evt.target.value
    @setState flow: flow

  gtd_status_changed: (evt)->
    flow = @state.flow
    flow.gtd_status = evt.target.value
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

      <table className='flows table table-striped table-bordered'>
        <thead><tr>
          <th>id</th>
          <th>number</th>
          <th>name</th>
          <th>stat</th>
          <th>GTD status</th>
          <th>ops</th>
        </tr></thead>
        <tbody>
          {
            for flow in @state.flows
              gtd_status = flow.gtd_status || 'init'
              status_str = {
                init: '才开始'
                half: '做一半了'
                almost: '快做完了'
                done: '做完了'
              }[gtd_status]

              <tr data-id={flow.id} key={flow.id} className='flow'>
                <td>{flow.id}</td>
                <td>{flow.number}</td>
                <td>{flow.name}</td>
                <td>节点:{flow.actions.total} 柜员:{flow.actions.gy_count} 客户:{flow.actions.kh_count}</td>
                <td>{status_str}</td>
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
      saving: false

  show_update_modal: (evt)->
    $btn = jQuery(evt.target)
    flow_id = $btn.closest('tr').data('id')
    flow = (@state.flows.filter (x)->
      x.id == flow_id)[0]

    console.log flow

    @refs.modal.setState
      show_modal: true
      flow: flow
      saving: false

  submit: ->
    id = @refs.modal.state.flow.id

    number = @refs.modal.state.flow.number || ''
    name = @refs.modal.state.flow.name || ''
    gtd_status = @refs.modal.state.flow.gtd_status || 'init'

    @refs.modal.setState saving: true

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
        @setState flows: flows
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
            gtd_status: gtd_status
      .done (res)=>
        flows = @state.flows
        for flow in flows
          if flow.id == id
            flow.name = name
            flow.number = number
            flow.gtd_status = gtd_status
        @setState flows: flows
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