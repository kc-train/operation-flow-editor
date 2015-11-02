@OFCTellerScreen = React.createClass
  displayName: 'OFCTellerScreen'
  render: ->
    data = @props.data

    <div className='ofc-teller-screen'>
      <h5>画面代码: {data.hmdm}</h5>
      <div className='zds'>
        {
          for zd_data in data.zds
            <OFCTellerScreen.ZD key={zd_data.zdxh} data={zd_data} />
        }
      </div>
    </div>

  statics:
    ZD: React.createClass
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