@ProgressPage = React.createClass
  getInitialState: ->
    orderby: 'default'

  render: ->
    total = 0
    for d in @props.data
      total += d.progress
    p0 = ~~(total / @props.data.length)
    p1 = 50
    p2 = 0
    p3 = 0

    total = ~~(p0 * 0.4 + p1 * 0.3 + p2 * 0.2 + p3 * 0.1)

    <div className='progress-page'>
      <h2>课件制作进度统计汇总页</h2>
      <p>
        此页面用来统计 kc 金融培训项目的柜员操作课件制作进度<br/>
        根据后续推进和制作过程变化情况，统计方式会陆续有所修改。
      </p>

      <h3>总体概览</h3>
      <TotalProgress title='总体' progress={total} />
      <TotalProgress title='操作 (占 40%)' progress={p0} />
      <TotalProgress title='屏幕 (占 30%)' progress={p1} />
      <TotalProgress title='说明 (占 20%)' progress={p2} />
      <TotalProgress title='语音 (占 10%)' progress={p3} />

      <h3>交易分项制作进度 (共 {@props.data.length} 项)</h3>
      <div className='transactions'>
        <div className='btn-group' style={'marginBottom': '30px', 'display': 'block', 'overflow': 'hidden'}>
          <a className='btn btn-default' onClick={@orderby_default}>按序号排序</a>
          <a className='btn btn-default' onClick={@orderby_screen_count}>按屏幕数排序</a>
          <a className='btn btn-default' onClick={@orderby_ldjy_count}>按联动交易数排序</a>
        </div>
        {
          if @state.orderby is 'default'
            data = @props.data.sort (a, b)->
              sa = parseInt(a.id) || '99999999'
              sb = parseInt(b.id) || '99999999'
              sa - sb

          if @state.orderby is 'screen_count'
            data = @props.data.sort (a, b)->
              sb = if b.screen_data? then b.screen_data?.total else -100
              sa = if a.screen_data? then a.screen_data?.total else -100
              o = sb - sa
              return o if o != 0
              o = parseInt a.id - parseInt b.id

          if @state.orderby is 'ldjy_count'
            data = @props.data.sort (a, b)->
              sb = if b.screen_data? then b.screen_data?.ldjy_count else -100
              sa = if a.screen_data? then a.screen_data?.ldjy_count else -100
              o = sb - sa
              return o if o != 0
              o = parseInt a.id - parseInt b.id

          for tdata in data
            <Transaction key={tdata.id} data={tdata} />
        }
      </div>
    </div>

  orderby_default: ->
    @setState orderby: 'default'

  orderby_screen_count: ->
    @setState orderby: 'screen_count'

  orderby_ldjy_count: ->
    @setState orderby: 'ldjy_count'

TotalProgress = React.createClass
  render: ->
    p = @props.progress || 0

    <div className='total-progress'>
      <h4>{@props.title}</h4>
      <div className='progress'>
        <div className='progress-bar progress-bar-success progress-bar-striped' style={width: "#{p}%"}>{p}%</div>
      </div>
    </div>

Transaction = React.createClass
  render: ->
    p = @props.data.progress

    <div className='transaction'>
      <div className='id'>
        <a href="/xmdm/#{@props.data.id}" target='_blank'>#{@props.data.id}</a>
      </div>
      <div className='name'>{@props.data.name}</div>
      <div className='status'>
        {
          if not @props.data.exist_in_oracle
            <div className='tip danger'>数据库里找不到</div>
        }
        {
          <ScreenCount data={@props.data.screen_data} />
        }
      </div>
      <div className='transaction-progress'>
        <div className='progress'>
          <div className='progress-bar progress-bar-success progress-bar-striped' style={width: "#{p}%"}>{p}%</div>
        </div>
      </div>
    </div>

ScreenCount = React.createClass
  render: ->
    data = @props.data || {}

    <div className='screen-count'>
      <div className='tip'>联动交易数:{data.ldjy_count}</div>
      <div className='tip'>屏幕数:{data.total}</div>
      <div className='tip'>输入:{data.sr?.length} 响应:{data.xy?.length} 复核:{data.fh?.length}</div>
    </div>