@NetTaggingWizard = React.createClass
  displayName: 'NetTaggingWizard'
  getInitialState: ->
    # 值不变的
    book_name: @props.data.book_name
    catalog_tree: new CatalogTree @props.data.catalogs_data
    
    # 值一直改变的
    status: 'ready' # loading, tagging, complete
    submiting: false
    current_task: null
    selected_catalogs: null

    # complete: false

  show_loading: ->
    @setState status: 'loading'

  start: ->
    @show_loading()
    jQuery.ajax
      url: "/net/#{@state.book_name}/start_tagging"
      type: 'POST'
    .done (res)=>
      @set_task res

  set_task: (res)->
    if res.finished
      @setState
        status: 'complete'
    else
      @setState
        status: 'tagging'
        submiting: false
        current_task: res
        selected_catalogs: new IDSet()

  get_current_catalog: ->
    current_catalog_id = @state.current_task.catalog_stack[0]
    if current_catalog_id?
      @state.catalog_tree.get current_catalog_id
    else
      @state.catalog_tree.roots()[0]

  toggle_select: (catalog_item)->
    set = @state.selected_catalogs
    if set.get(catalog_item.id)?
      set.remove catalog_item.id
    else
      set.add catalog_item
    @setState selected_catalogs: set

  # 获取因为目前的关联操作而新增关联，包括连带新增关联的目录项列表
  get_added_catalog_ids: ->
    stack = @state.selected_catalogs.ids().sort()
    added_ids = []
    while stack.length > 0
      id = stack.shift()
      citem = @state.catalog_tree.get(id)
      added_ids.push id
      # 如果某个已选目录项只有一个子项，那就直接把子项也加进来
      # 因为备选项只有一项，所以不用选
      if citem.children().length is 1
        stack.push citem.children_ids[0]

    return added_ids

  submit: ->
    task_id = @state.current_task.id
    added_catalog_ids = @get_added_catalog_ids()
    new_stack = (id for id in @state.current_task.catalog_stack)
    # 已经处理完的，移出堆栈
    new_stack.shift()
    # 本次操作分配的目录项，子节点数 > 1 的，加入堆栈
    for _id in added_catalog_ids
      citem = @state.catalog_tree.get _id
      new_stack.push _id if citem.children().length > 1

    submit_data = {
      task_id: task_id
      added_catalog_ids: added_catalog_ids
      new_stack: new_stack
    }

    @do_submit submit_data

  do_submit: (submit_data)->
    @setState submiting: true
    jQuery.ajax
      url: "/net/#{@state.book_name}/save_tagging_task"
      type: 'PUT'
      data: submit_data
    .done (res)=>
      @set_task res

  get_progress: ->
    catalogs_total = @state.catalog_tree.count()
    current_catalog_item = @get_current_catalog()

    # 计算已整理的目录项数目
    # 特殊情况：如果堆栈是空的，说明所有目录项都未整理
    # 所有待整理堆栈里的目录（以及其子孙目录）都是待整理的
    # 其他目录都可认为是已整理的
    
    if @state.current_task.catalog_stack.length > 0
      catalogs_not_done = 0
      for id in @state.current_task.catalog_stack
        catalogs_not_done += 1 + @state.catalog_tree.get(id).descendants().length
    else
      catalogs_not_done = catalogs_total

    return {
      catalogs_total: catalogs_total
      catalogs_done: catalogs_total - catalogs_not_done
    }

  render: ->
    if @state.status is 'ready'
      <div className='net-tagging-wizard ready'>
        <div className='desc'>
          点击“开始整理”后，后台会根据一定规则分配给任务执行者需要整理的概念，执行者不断执行对应到目录项的关联操作，直到提示执行完毕。
        </div>
        <a className='btn btn-success btn-lg' onClick={@start}>
          <i className='fa fa-play-circle' />
          <span>开始整理任务</span>
        </a>
      </div>

    else if @state.status is 'loading'
      <div className='net-tagging-wizard loading'>
        <i className='fa fa-spinner fa-pulse' />
        <div>正在加载</div>
      </div>

    else if @state.status is 'complete'
      <div className='net-tagging-wizard ready'>
        <div className='desc'>
          <i className='fa fa-check' />
          <span>概念整理任务执行完毕</span>
        </div>
        <a className='btn btn-success btn-lg' onClick={@start}>
          <i className='fa fa-play-circle' />
          <span>开始下一个任务</span>
        </a>
      </div>

    else if @state.status is 'tagging'
      progress = @get_progress()
      can_submit = not @state.selected_catalogs.blank()
      current_catalog_item = @get_current_catalog()

      <div className='net-tagging-wizard'>
        <NetTaggingWizard.Buckets data={current_catalog_item} wizard={@} selected_catalogs={@state.selected_catalogs} />

        <div className='taginfo'>
          <div className='book-name'>教材：{@props.data.book_name}</div>

          <div className='info-content'>
            <div className='help'>
              说明：下方显示了当前正在整理的概念，而右方列出了一些章节标题。根据个人理解判断，点选与该概念密切相关的章节标题，建立联系后按下确定按钮。
            </div>
            <NetTaggingWizard.TagText data={@state.current_task.tag} />
          </div>

          <div className='bottom-box'>
            <NetTaggingWizard.Stat text='当前任务进度' done={progress.catalogs_done} total={progress.catalogs_total} />
            <NetTaggingWizard.SubmitBtn can_submit={can_submit} submiting={@state.submiting} click={@submit} />
          </div>

        </div>
      </div>

  statics:
    Buckets: React.createClass
      getInitialState: ->
        selected_buckets: {}

      render: ->
        catalog_item = @props.data

        <div className='buckets'>
          <div className='current'>
            当前章节：{catalog_item.name}
          </div>
          {
            for child in catalog_item.children()
              selected = @props.selected_catalogs.get(child.id)?
              <NetTaggingWizard.Bucket key={child.id} data={child} parent={@} selected={selected} />
          }
        </div>

      toggle_select: (catalog_item)->
        @props.wizard.toggle_select catalog_item

    Bucket: React.createClass
      render: ->
        catalog_item = @props.data
        klass = if @props.selected then 'bucket selected' else 'bucket'

        <div key={catalog_item.id} className={klass} onClick={@select}>
          <i className='fa fa-chevron-right i0' />
          <span>{catalog_item.name}</span>
          <i className='fa fa-check i1' />
        </div>

      select: ->
        @props.parent.toggle_select @props.data

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

