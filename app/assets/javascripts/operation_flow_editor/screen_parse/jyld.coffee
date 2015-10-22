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
            <div className={klass.join(' ')}>{str}</div>
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