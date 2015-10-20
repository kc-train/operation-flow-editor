AddChaterModal = React.createClass
  getInitialState: ->
    show: false
    name: ''

  render: ->
    <BSModal show={@state.show} bs_size='sm'>
      <BSModal.Header>
        <BSModal.Title>新增谈话者</BSModal.Title>
      </BSModal.Header>
      <BSModal.Body>
        <div className='form-group'>
          <input ref='name_inputer' name='name' className='form-control' type='text' placeholder='访谈者名字' value={@state.name} onChange={@on_name_change} />
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

  hide: ->
    @setState show: false

  on_name_change: (evt)->
    @setState name: evt.target.value

  get_name: ->
    jQuery.trim(@state.name)


Chater = React.createClass
  render: ->
    name = @props.name[0]
    <a href='javascript:;' className='chater'>{name}</a>


ChaterGroup = React.createClass
  displayName: 'ChaterGroup'
  getInitialState: ->
    chaters: {}

  render: ->
    klass = ['chater-group', "team-#{@props.team}"]
    <div className={klass.join(' ')}>
      {
        for name, data of @state.chaters
          <Chater key={name} name={name} />
      }

      <a className='add-btn' href='javascript:;' onClick={@new_chater}>
        <i className='fa fa-plus'></i>
      </a>
      <AddChaterModal ref='modal' submit={@save_chater} />
    </div>

  new_chater: ->
    @refs.modal.setState 
      show: true
      name: ''

  save_chater: ->
    name = @refs.modal.get_name()

    if name.length > 0
      chaters = @state.chaters
      chaters[name] = {}
      @setState chaters: chaters

      @refs.modal.hide()

ChatArea = React.createClass
  displayName: 'ChatArea'
  render: ->
    <div className='chat-area'></div>


@QuickChatNote = React.createClass
  displayName: 'QuickChatNote'
  render: ->
    <div className='quick-chat-note'>
      <ChaterGroup team='interviewer' />
      <ChatArea />
      <ChaterGroup team='interviewee' />
    </div>