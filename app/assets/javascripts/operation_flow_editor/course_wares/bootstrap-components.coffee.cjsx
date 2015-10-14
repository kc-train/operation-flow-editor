@BSButton = React.createClass
  getDefaultProps: ->
    bsstyle: 'default'
    href: 'javascript:;'

  render: ->
    klass = ["btn", "btn-#{@props.bsstyle}"]
    if @props.bssize?
      klass.push "btn-#{@props.bssize}"

    <a className={klass.join(' ')} href={@props.href} onClick={@props.onClick}>
      {@props.children}
    </a>

@BSModal = React.createClass
  getDefaultProps: ->
    bs_size: 'sm'

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