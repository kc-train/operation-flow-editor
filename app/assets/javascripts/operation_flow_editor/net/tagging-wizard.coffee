@NetTaggingWizard = React.createClass
  displayName: 'NetTaggingWizard'
  getInitialState: ->
    current_chapter: @props.data.workflowy
    current_tag: @props.data.tags[0]
    progress_done: 20
    progress_total: @props.data.tags.length

  render: ->
    current_chapter = @state.current_chapter
    current_tag = @state.current_tag
    progress = @state.progress_done * 100.0 / @state.progress_total

    <div className='net-tagging-wizard'>
      <div className='buckets'>
        <div className='current'>
          {current_chapter.name}
        </div>
        {
          idx = 0
          for child in current_chapter.children
            <div key={idx++} className='bucket'>{child.name}</div>
        }
      </div>
      <div className='taginfo'>
        <div className='help'>请在左侧勾选教材目录章节，把当前显示的标签归类对应到相应位置</div>
        <h3 className='tagname'>{current_tag.name}</h3>
        <div className='tagdesc'>
          {
            idx = 0
            for d in current_tag.desc
              <p key={idx++}>{d}</p>
          }
        </div>
        <div className='stat'>
          <div className='text'>
            <span>本轮整理已完成</span>
            <span className='number'>{@state.progress_done} / {@state.progress_total}</span>
            <span>总共</span>
          </div>
          <div className='progress'>
            <div className='progress-bar progress-bar-success progress-bar-striped' style={width: "#{progress}%"}></div>
          </div>
        </div>
        <a className='submit' href='javascript:;'>
          <i className='fa fa-check' />
        </a>
      </div>
    </div>