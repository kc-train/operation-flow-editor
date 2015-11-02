ZJY = React.createClass
  displayName: 'ZJY'
  render: ->
    <div className='zjy'>
      <h4>子交易： #{@props.data.jydm} - {@props.data.jymc}</h4>
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

@OFCFlowScreens = React.createClass
  displayName: 'OFCFlowScreens'
  render: ->
    <div className='ofc-flow-screens'>
      <h3>项目代码： #{@props.xmdm}</h3>
      <div className='zjys'>
        {
          idx = 0
          for zjydata in @props.data
            <ZJY key={idx++} data={zjydata} />
        }
      </div>
    </div>
