@OEActionList = React.createClass
  getInitialState: ->
    actions: @props.actions || []

  render: ->
    <div className='OEActionList'>
      <div className='toolbar'>
        <a className='add-action' href='javascript:;'>
          <i className='fa fa-plus'></i>
        </a>
      </div>
      <div className='actions-list'>
        {
          for action in @state.actions
            <div key={action.id} className='action'>
              <div className='name'>{action.name}</div>
            </div>
        }
      </div>
    </div>