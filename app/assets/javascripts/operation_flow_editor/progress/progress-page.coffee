@ProgressPage = React.createClass
  render: ->
    <div className='progress-page'>
      <h3>制作进度概览</h3>
      <TotalProgress title='总体' />
      <TotalProgress title='操作' />
      <TotalProgress title='屏幕' />
      <TotalProgress title='说明' />
      <TotalProgress title='语音' />

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
    p = 50

    <div className='total-progress'>
      <h4>{@props.title}</h4>
      <div className='progress'>
        <div className='progress-bar progress-bar-success progress-bar-striped' style={width: "#{p}%"}>{p}%</div>
      </div>
    </div>

Transaction = React.createClass
  render: ->
    p = 40

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