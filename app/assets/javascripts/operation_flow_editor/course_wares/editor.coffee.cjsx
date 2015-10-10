@OEFlowList = React.createClass
  getInitialState: ->
    show_modal: false
    flows: @props.flows || []

  render: ->
    <div className='OEFlowList'>
      <div className='toolbar'>
        <BSButton onClick={@show_modal}>
          <i className='fa fa-plus'></i>
          <span>增加操作流程</span>
        </BSButton>
      </div>

      <BSModal show={@state.show_modal}>
        <BSModal.Header>
          <BSModal.Title>增加操作流程</BSModal.Title>
        </BSModal.Header>
        <BSModal.Body>
          <div className='form-group'>
            <input className='form-control' type='text' placeholder='编号' ref='number_inputer' />
          </div>
          <div className='form-group'>
            <input className='form-control' type='text' placeholder='名称' ref='name_inputer' />
          </div>
        </BSModal.Body>
        <BSModal.Footer>
          <BSButton onClick={@submit} bsstyle='primary'>
            <i className='fa fa-ok'></i>
            <span>确定保存</span>
          </BSButton>
          <BSButton onClick={@close_modal}>
            <span>关闭</span>
          </BSButton>
        </BSModal.Footer>
      </BSModal>

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
                    <BSButton bssize='xs'>
                      <i className='fa fa-pencil'></i>
                      <span>修改</span>
                    </BSButton>
                    <BSButton bssize='xs'>
                      <i className='fa fa-pencil'></i>
                      <span>设计</span>
                    </BSButton>
                    <BSButton bssize='xs' onClick={@remove}>
                      <i className='fa fa-trash'></i>
                      <span>删除</span>
                    </BSButton>
                  </div>
                </td>
              </tr>
          }
        </tbody>
      </table>
    </div>

  show_modal: ->
    @setState
      show_modal: true

  close_modal: ->
    @setState
      show_modal: false

  submit: ->
    number = jQuery(React.findDOMNode @refs.number_inputer).val()
    name = jQuery(React.findDOMNode @refs.name_inputer).val()
    
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
      @close_modal()
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



@OEActionList = React.createClass
  render: ->
    <div className='OEActionList'>
      <div className='toolbar'>
        <a className='add-action' href='javascript:;'>
          <i className='fa fa-plus'></i>
        </a>
      </div>
      <div className='actions-list'>
        <div className='action'>
          <div className='name'>填写递交并审核开户申请</div>
        </div>
      </div>
    </div>