@BSButton = React.createClass
  getDefaultProps: ->
    bsstyle: 'default'
    href: 'javascript:;'
    target: ''

  render: ->
    klass = ["btn", "btn-#{@props.bsstyle}"]
    if @props.bssize?
      klass.push "btn-#{@props.bssize}"

    <a className={klass.join(' ')} href={@props.href} target={@props.target} onClick={@props.onClick}>
      {@props.children}
    </a>

@BSModal = React.createClass
  getDefaultProps: ->
    bs_size: 'sm' # xs sm md lg

  render: ->
    <div className='modal fade' ref='modal'>
      <div className="modal-dialog modal-#{@props.bs_size}">
        <div className='modal-content'>
          {@props.children}
        </div>
      </div>
    </div>

  componentDidUpdate: ->
    dom = React.findDOMNode @refs.modal
    if @props.show
      jQuery(dom).modal('show')
    else
      jQuery(dom).modal('hide')

  show: ->
    @setState show: true

  hide: ->
    @setState show: false

  statics: 
    Header: React.createClass
      render: ->
        <div className='modal-header'>{@props.children}</div>

    Title: React.createClass
      render: ->
        <div className='modal-title'><h4>{@props.children}</h4></div>

    Body: React.createClass
      render: ->
        <div className='modal-body'>{@props.children}</div>

    Footer: React.createClass
      render: ->
        <div className='modal-footer'>{@props.children}</div>

    InfoModal: React.createClass
      getInitialState: ->
        show: false
        loading: false
      render: ->
        <BSModal show={@state.show} bs_size={@props.bs_size}>
          <BSModal.Header>
            <BSModal.Title>{@props.title}</BSModal.Title>
          </BSModal.Header>
          <BSModal.Body>
          {
            if @state.loading
              <div className='loading'>
                <i className='fa fa-spinner fa-pulse' />
                <span>正在载入</span>
              </div>
            else
              @props.children
          }
          </BSModal.Body>
          <BSModal.Footer>
            <BSButton onClick={@hide}>
              <span>关闭</span>
            </BSButton>
          </BSModal.Footer>
        </BSModal>
      show: ->
        @setState show: true
      hide: ->
        @setState show: false
      loading: ->
        @setState loading: true
      loaded: ->
        @setState loading: false


    FormModal: React.createClass
      getInitialState: ->
        show: false
        saving: false
      render: ->
        <BSModal show={@state.show} bs_size={@props.bs_size}>
          <BSModal.Header>
            <BSModal.Title>{@props.title}</BSModal.Title>
          </BSModal.Header>
          <BSModal.Body>
            {@props.children}
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
        @setState show: true
      hide: ->
        @setState show: false
