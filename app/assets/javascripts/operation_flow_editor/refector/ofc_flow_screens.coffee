ZJY = React.createClass
  displayName: 'ZJY'
  getInitialState: ->
    show: false
  render: ->
    klass = if @state.show then 'zjy' else 'zjy hide'

    <div className={klass}>
      {
        if @props.data.input_screens?
          <div className='input_screens'>
            <h5>输入屏</h5>
            {
              for screen_data in @props.data.input_screens
                <OFCTellerScreen key={screen_data.hmdm} data={screen_data} />
            }
          </div>
      }
      {
        if @props.data.response_screen?
          s = @props.data.response_screen
          <div className='response_screen'>
            <h5>响应屏</h5>
            <OFCTellerScreen key={s.hmdm} data={s} />
          </div>
      }
      {
        if @props.data.compound_screen?
          s = @props.data.compound_screen
          <div className='compound_screen'>
            <h5>复核屏</h5>
            <OFCTellerScreen key={s.hmdm} data={s} />
          </div>
      }
    </div>

  show: ->
    @setState show: true



ZJYTabs = React.createClass
  getInitialState: ->
    active: 0

  render: ->
    <ul className='zjy-tabs nav nav-tabs'>
      {
        idx = 0
        for zjydata in @props.data
          <li ref="li#{idx}" data-idx={idx} key={idx} className={if idx++ == @state.active then 'active' else ''}>
            <a href='javascript:;' onClick={@props.tab_click}>{zjydata.jydm}-{zjydata.jymc}</a>
          </li>
      }
    </ul>

  active: (idx)->
    @setState active: idx

@OFCFlowScreens = React.createClass
  displayName: 'OFCFlowScreens'
  render: ->
    <div className='ofc-flow-screens'>
      <h3>项目代码： #{@props.xmdm}</h3>
      <ZJYTabs ref='tabs' data={@props.data} tab_click={@tab_click} />
      <div className='zjys'>
        {
          idx = 0
          for zjydata in @props.data
            <ZJY ref="zjy#{idx}" key={idx++} data={zjydata} />
        }
      </div>
    </div>

  componentDidMount: ->
    @show(0)

  show: (idx)->
    @refs["zjy#{idx}"].show()
    @refs.tabs.active(idx)

  tab_click: (evt)->
    idx = jQuery(evt.target).closest('li').data('idx')
    @show idx