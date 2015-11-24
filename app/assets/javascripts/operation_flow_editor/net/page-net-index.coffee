@PageNetArranger = React.createClass
  displayName: 'PageNetArranger'
  render: ->
    <div className='page-net-arrange'>
      <PageNetWorkflowyXmlShow data={@props.data.workflowy_data} />
      <ArrangeWizard data={@props.data} />
    </div>



@ArrangeWizard = React.createClass
  displayName: 'ArrangeWizard'
  getInitialState: ->
    current_chapter: @props.data.workflowy_data
    current_tag: @props.data.tags_data[0]
    progress_done: 20
    progress_total: @props.data.tags_data.length

  render: ->
    current_chapter = @state.current_chapter
    current_tag = @state.current_tag
    progress = @state.progress_done * 100.0 / @state.progress_total

    <div className='arrange-wizard'>
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



@PageNetIndex = React.createClass
  displayName: 'PageNetIndex'
  render: ->
    data = @props.data

    <div className='page-net-index'>
      <ul>
      {
        for item in data
          <li key={item.name}>
            <div className='name'>{item.name}</div>
            <div className='catalog-link'>
              <label>workflowy 目录：</label>
              <a target='_blank' href={item.catalog_link}>{item.catalog_link}</a>
            </div>
            <div className='tag-editor-link'>
              <a target='_blank' href="/net/#{item.name}">打标签</a>
            </div>
          </li>
      }
      </ul>
    </div>



@PageNetWorkflowyXmlShow = React.createClass
  displayName: 'PageNetWorkflowyXmlShow'
  render: ->
    data = @props.data
    if data is null
      <div>没有获取到数据</div>
    else
      <div className='page-net-workflowy-xml-show'>
        <PageNetWorkflowyXmlShow.List data={[data]} />
      </div>

  statics:
    List: React.createClass
      displayName: 'List'
      render: ->
        chapters = @props.data
        <ul>
        {
          for chapter in chapters
            <PageNetWorkflowyXmlShow.Item key={chapter.name} data={chapter} />
        }
        </ul>

    Item: React.createClass
      displayName: 'Item'
      getInitialState: ->
        if @props.data.depth > 0
          expand: false
        else
          expand: true

      render: ->
        data = @props.data
        has_children = data.children.length
        klass = []
        klass.push if @state.expand then 'expand' else ''
        klass.push if has_children then '' else 'leafnode'

        <li className={klass.join(' ')}>
          <div className='info'>
            {
              if has_children
                <a className='expand-btn' href='javascript:;' onClick={@toggle_expand}>
                  <i className='fa fa-minus' />
                  <i className='fa fa-plus' />
                </a>
            }
            <div className='name'>{data.name}</div>
            {
              if false and has_children
                <a className='arrange' href='javascript:;'>整理</a>
            }
          </div>
          {
            if has_children
              <PageNetWorkflowyXmlShow.List data={data.children} />
          }
        </li>

      toggle_expand: ->
        @setState
          expand: !@state.expand


@PageNetTags = React.createClass
  render: ->
    <div className='page-net-tags'>
    {
      for tag in @props.data
        <PageNetTags.Tag data={tag} />
    }
    </div>

  statics:
    Tag: React.createClass
      render: ->
        tag = @props.data
        <div className='tag'>
          <div className='name'>{tag.name}</div>
          <div className='desc'>{tag.desc}</div>
        </div>