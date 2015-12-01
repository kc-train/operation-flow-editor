@NetTaggingWizard = React.createClass
  displayName: 'NetTaggingWizard'
  getInitialState: ->
    book_name: @props.data.book_name

    catalog_data: @props.data.catalog_data
    catalog_array: @get_catalog_array()
    
    tags_data: @props.data.tags_data
    
    store_data: null

    loading: false
    selected_buckets: {}
    submiting: false

  show_loading: ->
    @setState loading: true

  set_store_data: (store_data)->
    @setState
      store_data: store_data
      loading: false
      selected_buckets: {}
      submiting: false

  _get_current_tag: ->
    tag_id = @state.store_data.current_tag
    if tag_id?
      return (@state.tags_data.filter (x)->
        x.id == tag_id)[0]
    return @state.tags_data[0]

  _get_current_chapter: ->
    chapter_id = tag_id = @state.store_data.current_chapter
    if chapter_id?
      return (@state.catalog_array.filter (x)->
        x.id == chapter_id)[0]
    return @state.catalog_array[0]

  _get_progress: ->
    tags_total: @state.tags_data.length
    chapter_total: @state.catalog_array.length
    tags_done: Object.keys(@state.store_data?.data?[@state.store_data.current_chapter] || {}).length
    chapter_done: Object.keys(@state.store_data?.data || {}).length

  get_catalog_array: ->
    @_rgct @props.data.catalog_data, []

  _rgct: (chapter, arr)->
    arr.push chapter
    for child in chapter.children
      @_rgct child, arr
    arr

  toggle_select: (chapter_id)->
    selected_buckets = @state.selected_buckets
    chapter = selected_buckets[chapter_id]
    if chapter?
      delete selected_buckets[chapter_id]
    else
      selected_buckets[chapter_id] = chapter_id
    @setState selected_buckets: selected_buckets

  submit: ->
    current_chapter = @_get_current_chapter()
    current_tag = @_get_current_tag()
    selected_buckets = @state.selected_buckets
    
    link_data = @state.store_data?.data || {}
    link_data[current_chapter.id] ||= {}
    link_data[current_chapter.id][current_tag.id] = Object.keys(selected_buckets)

    tag_idx = @state.tags_data.indexOf current_tag
    chapter_idx = @state.catalog_array.indexOf current_chapter

    # 如果这一轮 tag 还没过完，继续下一个 tag
    # 如果这一轮 tag 已经过完了，而 chapter 还没过完，继续下一个 chapter
    # 如果都过完了，结束

    if tag_idx + 1 < @state.tags_data.length
      submit_data = 
        current_tag: @state.tags_data[tag_idx + 1].id
        current_chapter: current_chapter.id
        link_data: link_data
    else if chapter_idx + 1 < @state.catalog_array.length
      submit_data =
        current_tag: @state.tags_data[0].id
        current_chapter: @state.catalog_array[chapter_idx + 1].id
        link_data: link_data
    else
      submit_data =
        current_tag: null
        current_chapter: null
        link_data: link_data

    @setState submiting: true
    jQuery.ajax
      url: "/net/#{@state.book_name}/save_tagging_store/#{@state.store_data?.id}"
      type: 'PUT'
      data: submit_data
    .done (res)=>
      @set_store_data res


  render: ->
    if @state.loading
      <div className='net-tagging-wizard loading'>
        <i className='fa fa-spinner fa-pulse' />
        <div>正在加载整理记录</div>
      </div>

    else if not @state.store_data?
      <div className='net-tagging-wizard blank'>
        <div className='blank-desc'>
          <h4>{@state.book_name}</h4>
          请创建或选择一个整理记录来进行概念整理。<br/>
          每个整理者需要建立自己的整理记录。
        </div>
      </div>

    else
      current_tag = @_get_current_tag()
      current_chapter = @_get_current_chapter()
      progress = @_get_progress()

      can_submit = Object.keys(@state.selected_buckets).length

      <div className='net-tagging-wizard'>
        <NetTaggingWizard.Buckets data={current_chapter} wizard={@} selected_buckets={@state.selected_buckets} />

        <div className='taginfo'>
          <div className='book-name'>教材：{@props.data.book_name}</div>
          <div className='help'>
            说明：下方显示了当前正在整理的概念，而右方列出了一些章节标题。根据个人理解判断，点选与该概念密切相关的章节标题，建立联系后按下确定按钮。
          </div>

          <div className='tagtext' data-id={current_tag.id}>
            <h3 className='tagname'>
              <i className='fa fa-circle-o' />
              <span>{current_tag.name}</span>
            </h3>
            <div className='tagdesc'>
              {
                idx = 0
                for d in current_tag.desc
                  <p key={idx++}>{d}</p>
              }
            </div>
          </div>

          <div className='stat'>
            <div className='text'>
              <span>本轮标签进度</span>
              <span className='number'>{progress.tags_done} / {progress.tags_total}</span>
            </div>
            <div className='progress'>
              <div className='progress-bar progress-bar-success progress-bar-striped' style={width: "#{progress.tags_done * 100.0 / progress.tags_total}%"}></div>
            </div>
            <div className='text'>
              <span>总体章节进度</span>
              <span className='number'>{progress.chapter_done} / {progress.chapter_total}</span>
            </div>
            <div className='progress'>
              <div className='progress-bar progress-bar-success progress-bar-striped' style={width: "#{progress.chapter_done * 100.0 / progress.chapter_total}%"}></div>
            </div>
          </div>

          <a className="submit #{if can_submit then '' else 'disabled'} #{if @state.submiting then 'submiting' else ''}" href='javascript:;' onClick={@submit} >
            <div className='common-text'>
              <i className='fa fa-check' />
              <span>确定</span>
            </div>
            <div className='submiting-text'>
              <i className='fa fa-spinner fa-pulse' />
              <span>保存中</span>
            </div>
          </a>
        </div>
      </div>

  statics:
    Buckets: React.createClass
      getInitialState: ->
        selected_buckets: {}

      render: ->
        current_chapter = @props.data

        <div className='buckets'>
          <div className='current'>
            {current_chapter.name}
          </div>
          {
            for child in current_chapter.children
              selected = @props.selected_buckets[child.id]?
              <NetTaggingWizard.Bucket key={child.id} data={child} parent={@} selected={selected} />
          }
        </div>

      toggle_select: (chapter_id)->
        @props.wizard.toggle_select chapter_id

    Bucket: React.createClass
      render: ->
        chapter = @props.data
        klass = if @props.selected then 'bucket selected' else 'bucket'

        <div key={chapter.id} className={klass} onClick={@select}>
          <i className='fa fa-chevron-right i0' />
          <span>{chapter.name}</span>
          <i className='fa fa-check i1' />
        </div>

      select: ->
        @props.parent.toggle_select @props.data.id
