ZJY = React.createClass
  render: ->
    data = @props.data

    <div className='zjy'>
      <div className='order'>{data.xh}</div>
      <div className='name'>子交易：[{data.zjym}] {data.jymc}</div>
    </div>

@JYLDParse = React.createClass
  getInitialState: ->
    zjys: {}

  render: ->
    <div className='jyld-parse'>
      {
        for id, zjy of @state.zjys
          <ZJY key={id} data={zjy} />
      }
    </div>

  componentDidMount: ->
    jQuery.ajax
      url: '/oracle_json'
      data:
        path: @props.json
    .done (res)=>
      zjys = @state.zjys
      res = res.sort (a, b)->
        a.xh - b.xh

      for d in res
        zjys[d.jymc] = d
      @setState zjys: zjys


ZJYWithScreen = React.createClass
  render: ->
    data = @props.data
    arr = [data.srpmh1, data.srpmh2, data.srpmh3, data.srpmh4,
        data.srpmh5, data.srpmh6, data.srpmh7, data.srpmh8,
        data.xypmh, data.fhpmh
      ]

    <div className='zjy'>
      <div className='name'>子交易：[{data.jydm}] {data.jymc}</div>
      <div className='screens'>
        {
          for str in arr
            klass = ['screen']
            klass.push 'exist' if str.match /[0-9]{6}/
            <a href="/screen/#{str}" target='_blank' className={klass.join(' ')}>{str}</a>
        }
      </div>
    </div>

@ZJYList = React.createClass
  getInitialState: ->
    zjys: []

  render: ->
    <div className='zjylist'>
      {
        for zjy in @state.zjys
          <ZJYWithScreen key={zjy.jydm} data={zjy} />
      }
    </div>

  componentDidMount: ->
    jQuery.ajax
      url: '/oracle_json'
      data:
        path: @props.json
    .done (res)=>
      console.log res
      zjys = @state.zjys
      @setState zjys: res


@ScreenRender = React.createClass
  getInitialState: ->
    data = @props.data.sort (a, b)->
      parseInt(a.zdxh) - parseInt(b.zdxh)

    data: data
    xxmxs: @props.xxmxs

  render: ->
    <div className='screen-render'>
      {
        for zd in @state.data
          xxmxs = @state.xxmxs.filter (x)->
            x.xxdm is zd.xxdm

          <ScreenZD key={zd.zdxh} zd={zd} xxmxs={xxmxs} />
      }
    </div>

ScreenZD = React.createClass
  render: ->
    zd = @props.zd
    top = (zd.y - 1) * 30
    left = (zd.x - 1) * 10

    klass = ['screen-zd']
    czfs = ['edit', 'output', 'show', 'hide'][zd.czfs]
    klass.push "czfs-#{czfs}"

    width = zd.w * 10

    <div className={klass.join(' ')} style={top: "#{top}px", left: "#{left}px"}>
      <label data-qsh={zd.qsh} data-qsl={zd.qsl}>{zd.zdbt} {zd.xxdm}</label>
      {
        if zd.zdlx is '2'
          <select style={width: "#{width + 30}px"} >
            {
              for xxmx in @props.xxmxs
                <option key={xxmx.raw_rnum_}>{xxmx.xxqz}- {xxmx.xxmc}</option>
            }
          </select>
        else
          <input type='text' style={width: "#{width}px"} />
      }
    </div>