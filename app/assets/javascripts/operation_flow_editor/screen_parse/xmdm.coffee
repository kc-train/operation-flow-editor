ScreenZD = React.createClass
  render: ->
    data = @props.data
    lh = 480 / 20

    top = (data.qsh - 0) * lh
    left = (data.qsl - 0) * lh * 0.3
    width = data.zdcd * lh * 0.3

    klass = ['zd']
    czfs = ['edit', 'output', 'show', 'hide'][data.czfs]
    klass.push "czfs-#{czfs}"

    <div className={klass.join(' ')} data-qsh={data.qsh} data-qsl={data.qsl} data-xxdm={data.xxdm} data-sjbm={data.sjbm} data-zdlx={data.zdlx} style={top: "#{top}px", left: "#{left}px"}>
      <label>{data.zdbt}</label>
      {
        if data.zdlx is '2'
          <select style={width: "#{width + 30}px"} >
            {
              for xxmx in []
                <option key={xxmx.raw_rnum_}>{xxmx.xxqz}- {xxmx.xxmc}</option>
            }
          </select>
        else
          <input type='text' style={width: "#{width}px"} />
      }
    </div>


Screen = React.createClass
  # getInitialState: ->
  #   data = @props.data.sort (a, b)->
  #     parseInt(a.zdxh) - parseInt(b.zdxh)

  #   data: data
  #   xxmxs: @props.xxmxs
  displayName: 'Screen'
  render: ->
    <div className='screen'>
      <h5>画面代码: {@props.data.hmdm}</h5>
      <div className='zds'>
        {
          for zd_data in @props.data.zds
            <ScreenZD key={zd_data.zdxh} data={zd_data} />
        }
      </div>
    </div>

ZJY = React.createClass
  displayName: 'ZJY'
  render: ->
    <div className='zjy'>
      <h4>子交易： #{@props.data.jydm} - {@props.data.jymc}</h4>
      {
        if @props.data.input_screens?
          <div className='input_screens'>
            {
              for screen_data in @props.data.input_screens
                <Screen key={screen_data.hmdm} data={screen_data} />
            }
          </div>
      }
      {
        if @props.data.response_screen?
          <div className='response_screen'></div>
      }
      {
        if @props.data.compound_screen?
          <div className='compound_screen'></div>
      }
    </div>

@XmdmRender = React.createClass
  displayName: 'XmdmRender'
  render: ->
    <div className='xmdm'>
      <h3>项目代码： #{@props.xmdm}</h3>
      <div className='zjys'>
        {
          for zjydata in @props.data
            <ZJY key={zjydata.jydm} data={zjydata} />
        }
      </div>
    </div>