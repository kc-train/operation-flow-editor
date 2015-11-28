class TagFinder
  constructor: (@tags_data)->

  get_current_or_first_tag: (tag_id)->
    return (@tags_data.filter (x)-> x.id == tag_id)[0] if tag_id?
    return @tags_data[0]

  count: ->
    @tags_data.length

  indexOf: (tag)->
    @tags_data.indexOf tag

  get: (idx)->
    @tags_data[idx]

  get_next_or_first: (tag)->
    next_idx = @indexOf(tag) + 1
    next_idx = 0 if next_idx == @count()
    @get next_idx

  is_last: (tag)->
    @indexOf(tag) == @count() - 1


class ChapterFinder
  constructor: (@catalog_data)->
    @chapters_data = @_rgct @catalog_data, []

  _rgct: (chapter, arr)->
    arr.push chapter
    for child in chapter.children
      child.parent = chapter
      @_rgct child, arr
    arr

  get_current_or_first_chapter: (chapter_id)->
    return (@chapters_data.filter (x)-> x.id == chapter_id)[0] if chapter_id?
    return @chapters_data[0]

  count: ->
    @chapters_data.length

  indexOf: (chapter)->
    @chapters_data.indexOf chapter

  get: (idx)->
    @chapters_data[idx]

  get_next: (chapter)->
    @get @indexOf(chapter) + 1

  is_last: (chapter)->
    @indexOf(chapter) == @count() - 1


@NetTaggingWizard = React.createClass
  displayName: 'NetTaggingWizard'
  getInitialState: ->
    # 值不变的
    book_name: @props.data.book_name
    chapter_finder: new ChapterFinder @props.data.catalog_data
    
    # 值一直改变的
    store_data: null
    loading: false
    selected_buckets: {}
    submiting: false
    complete: false

  show_loading: ->
    @setState loading: true

  set_store_data: (store_data)->
    if store_data.current_chapter == 'COMPLETE'
      @setState
        store_data: store_data
        loading: false
        selected_buckets: {}
        submiting: false

        current_chapter: null
        current_tag: null
        tag_scope: null
        complete: true

      return

    current_chapter = @state.chapter_finder.get_current_or_first_chapter store_data.current_chapter
    parent_chapter = current_chapter.parent

    if parent_chapter
      finder0 = new TagFinder @props.data.tags_data

      chapter_tagging_data = store_data.data[parent_chapter.id]
      tags = []
      for tag_id, chapter_ids of chapter_tagging_data
        if chapter_ids.indexOf(current_chapter.id) >= 0
          tags.push finder0.get_current_or_first_tag tag_id

      tag_scope = new TagFinder tags
      current_tag = tag_scope.get_current_or_first_tag store_data.current_tag
      current_tag = tag_scope.get(0) if not current_tag?

    else
      tag_scope = new TagFinder @props.data.tags_data
      current_tag = tag_scope.get_current_or_first_tag store_data.current_tag


    @setState
      store_data: store_data
      loading: false
      selected_buckets: {}
      submiting: false

      current_chapter: current_chapter
      current_tag: current_tag
      tag_scope: tag_scope
      complete: false

    # 如果满足一定条件，直接提交
    setTimeout =>
      # 情况一，当前章节只有一个子章节
      if @state.current_chapter.children.length is 1
        @toggle_select @state.current_chapter.children[0].id
        @submit()

      # 情况二，当前章节是叶子章节
      if @state.current_chapter.children.length is 0
        @submit()

      # 情况三，章节没有分配任何 TAG
      if @state.tag_scope.count() is 0
        @submit()

    , 1


  _get_progress: ->
    tags_total = @state.tag_scope.count()
    chapter_total = @state.chapter_finder.count()

    tagging_data = @state.store_data?.data || {}
    current_chapter_tagging_data = tagging_data[@state.current_chapter.id] || {}

    tags_done = Object.keys(current_chapter_tagging_data).length
    if tags_done == 0
      chapter_done = Object.keys(tagging_data).length
    else
      chapter_done = Object.keys(tagging_data).length - 1

    tags_total: tags_total
    chapter_total: chapter_total
    tags_done: tags_done
    chapter_done: chapter_done

  toggle_select: (chapter_id)->
    selected_buckets = @state.selected_buckets
    chapter = selected_buckets[chapter_id]
    if chapter?
      delete selected_buckets[chapter_id]
    else
      selected_buckets[chapter_id] = chapter_id
    @setState selected_buckets: selected_buckets

  submit: ->
    current_chapter = @state.current_chapter
    current_tag = @state.current_tag
    selected_buckets = @state.selected_buckets
    
    link_data = @state.store_data?.data || {}
    link_data[current_chapter.id] ||= {}

    if current_chapter.children.length is 0
      link_data[current_chapter.id] = null

    else if @state.tag_scope.count() > 0
      link_data[current_chapter.id][current_tag.id] = Object.keys(selected_buckets)

    else
      link_data[current_chapter.id] = null

    # 规则：
    # 如果 chapter 过完了，全部结束
    # 否则如果 tag 过完了，下一个 chapter，第一个 tag
    # 否则还是这个 chapter 下一个 tag

    tag_round_complete = @state.tag_scope.is_last current_tag
    chapter_round_complete = @state.chapter_finder.is_last current_chapter

    if tag_round_complete
      next_tag = @state.tag_scope.get_next_or_first current_tag
      next_chapter = @state.chapter_finder.get_next current_chapter

    else
      next_tag = @state.tag_scope.get_next_or_first current_tag
      next_chapter = current_chapter

    submit_data =
      current_tag: if next_tag? then next_tag.id else 'COMPLETE'
      current_chapter: if next_chapter? then next_chapter.id else 'COMPLETE'
      link_data: link_data

    @do_submit submit_data

  do_submit: (submit_data)->
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

    else if @state.complete
      <div className='net-tagging-wizard loading'>
        <i className='fa fa-check' />
        <div>已经全部整理完毕</div>
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
      current_tag = @state.current_tag
      current_chapter = @state.current_chapter
      progress = @_get_progress()

      can_submit = Object.keys(@state.selected_buckets).length

      <div className='net-tagging-wizard'>
        <NetTaggingWizard.Buckets data={current_chapter} wizard={@} selected_buckets={@state.selected_buckets} />

        <div className='taginfo'>
          <div className='book-name'>教材：{@props.data.book_name}</div>

          <div className='info-content'>
            <div className='help'>
              说明：下方显示了当前正在整理的概念，而右方列出了一些章节标题。根据个人理解判断，点选与该概念密切相关的章节标题，建立联系后按下确定按钮。
            </div>
            <NetTaggingWizard.TagText data={current_tag} />
          </div>

          <div className='bottom-box'>
            <NetTaggingWizard.Stat text='本轮标签进度' done={progress.tags_done} total={progress.tags_total} />
            <NetTaggingWizard.Stat text='总体章节进度' done={progress.chapter_done} total={progress.chapter_total} />
            <NetTaggingWizard.SubmitBtn can_submit={can_submit} submiting={@state.submiting} click={@submit} />
          </div>

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
            当前章节：{current_chapter.name}
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

    Stat: React.createClass
      render: ->
        done = @props.done
        total = @props.total
        progress = done * 100.0 / total

        <div className='stat'>
          <div className='text'>
            <span>{@props.text}</span>
            <span className='number'>{done} / {total}</span>
          </div>
          <div className='pb'>
            <div className='progress'>
              <div className='progress-bar progress-bar-success progress-bar-striped' style={width: "#{progress}%"} />
            </div>
          </div>
        </div>

    SubmitBtn: React.createClass
      render: ->
        klass = ['submit']
        klass.push 'disabled' if not @props.can_submit
        klass.push 'submiting' if @props.submiting

        <a className={klass.join(' ')} href='javascript:;' onClick={@props.click} >
          <div className='common-text'>
            <i className='fa fa-check' />
            <span>确定</span>
          </div>
          <div className='submiting-text'>
            <i className='fa fa-spinner fa-pulse' />
            <span>保存中</span>
          </div>
        </a>

    TagText: React.createClass
      render: ->
        tag = @props.data

        if tag?
          <div className='tagtext' data-id={tag.id}>
            <h3 className='tagname'>
              <i className='fa fa-circle-o' />
              <span>{tag.name}</span>
            </h3>
            <div className='tagdesc'>
              {
                idx = 0
                for d in tag.desc
                  <p key={idx++}>{d}</p>
              }
            </div>
          </div>
        else
          <div className='tagtext'>
            没有分配任何概念
          </div>

