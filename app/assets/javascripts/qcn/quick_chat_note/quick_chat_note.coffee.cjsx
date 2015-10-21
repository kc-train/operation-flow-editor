AddMemberModal = React.createClass
  displayName: 'AddMemberModal'
  getInitialState: ->
    show: false
    name: ''

  render: ->
    <BSModal show={@state.show} bs_size='sm'>
      <BSModal.Header>
        <BSModal.Title>新增参与者</BSModal.Title>
      </BSModal.Header>
      <BSModal.Body>
        <div className='form-group'>
          <input ref='name_inputer' name='name' className='form-control' type='text' placeholder='参与者名字' value={@state.name} onChange={@on_name_change} />
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


Member = React.createClass
  displayName: 'Member'
  render: ->
    name = @props.name[0]
    <div className='member'>
      <a href='javascript:;' className='name'>{name}</a>
      <a href='javascript:;' className='remove' onClick={@props.remove}>
        <i className='fa fa-times'></i>
      </a>
    </div>


MemberGroup = React.createClass
  displayName: 'MemberGroup'
  getInitialState: ->
    members: {}

  render: ->
    klass = ['member-group', "group-#{@props.group}"]
    <div className={klass.join(' ')}>
      {
        for name, data of @state.members
          <Member key={name} name={name} />
      }

      <a className='add-btn' href='javascript:;' onClick={@new_member}>
        <i className='fa fa-plus'></i>
      </a>
      <AddMemberModal ref='modal' submit={@save_member} />
    </div>

  new_member: ->
    @refs.modal.setState 
      show: true
      name: ''

  save_member: ->
    name = @refs.modal.get_name()
    if name.length > 0
      members = @state.members
      members[name] = {}
      @setState members: members

      @refs.modal.hide()
      jQuery('.quick-chat-note').trigger 'qcn:save'


ChatArea = React.createClass
  displayName: 'ChatArea'
  render: ->
    <div className='chat-area'></div>


@QuickChatNote = React.createClass
  displayName: 'QuickChatNote'
  render: ->
    <div className='quick-chat-note'>
      <MemberGroup group='interviewer' ref='interviewer' />
      <ChatArea />
      <MemberGroup group='interviewee' ref='interviewee' />
    </div>

  componentDidMount: ->
    try
      if localStorage['qcn']?
        if data = JSON.parse localStorage['qcn']
          @refs.interviewer.setState
            members: data.interviewer_members
          @refs.interviewee.setState
            members: data.interviewee_members
    catch
      # ...

    jQuery('.quick-chat-note').on 'qcn:save', =>
      interviewer_members = @refs.interviewer.state.members
      interviewee_members = @refs.interviewee.state.members

      localStorage['qcn'] = JSON.stringify
        interviewer_members: interviewer_members
        interviewee_members: interviewee_members