@ProgressPage = React.createClass
  render: ->
    total = 0
    for d in @props.data
      total += d.progress
    p0 = ~~(total / @props.data.length)
    p1 = 0
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
        {
          for tdata in @props.data
            <Transaction key={tdata.id} data={tdata} />
        }
      </div>
    </div>

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
      <div className='id'>#{@props.data.id}</div>
      <div className='name'>{@props.data.name}</div>
      <div className='status'>
        {
          if not @props.data.exist_in_oracle
            <div className='tip danger'>数据库里找不到</div>
        }
      </div>
      <div className='transaction-progress'>
        <div className='progress'>
          <div className='progress-bar progress-bar-success progress-bar-striped' style={width: "#{p}%"}>{p}%</div>
        </div>
      </div>
    </div>