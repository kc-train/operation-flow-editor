@KnetBookTags = React.createClass
  displayName: 'KnetBookTags'
  getInitialState: ->
    idset = new IDSet
    for tag_data in @props.data.tags_data
      idset.add tag_data

    tags_set: idset 
    arranged_tag_ids_with_times: @props.data.arranged_tag_ids_with_times
    query_keyword: ''

  render: ->
    disabled_count = (@state.tags_set.filter (x)-> x.disabled).length

    all_tags = (@state.tags_set.filter -> true)
    not_disabled_tags = all_tags.filter (tag)-> !tag.disabled
    disabled_tags = all_tags.filter (tag)-> tag.disabled
    not_arranged_tags = all_tags.filter (tag)=> !tag.disabled and !@state.arranged_tag_ids_with_times[tag.id]

    <div className='knet-book-tags'>
      <h3 className='tags-count'>
        <span>{@props.data.book_data.name}：</span>
        <span>共 {@state.tags_set.count()} 个概念</span>
        <span>，已关闭 {disabled_count} 个</span>
      </h3>
      <KnetBookTags.KeywordFilter parent={@} />
      <hr/>

      <div>
        <ul className='nav nav-tabs'>
          <li className='active'><a data-toggle='tab' href='.all-tags'>全部 {all_tags.length}</a></li>
          <li><a data-toggle='tab' href='.not-disabled-tags'>未关闭 {not_disabled_tags.length}</a></li>
          <li><a data-toggle='tab' href='.disabled-tags'>已关闭 {disabled_tags.length}</a></li>
          <li><a data-toggle='tab' href='.not-arranged-tags'>未整理 {not_arranged_tags.length}</a></li>
        </ul>

        <div className='tab-content'>
          <div className='tab-pane active all-tags'>
          {
            for tag in all_tags
              if tag.name.indexOf(@state.query_keyword) > -1
                arranged = @state.arranged_tag_ids_with_times[tag.id]
                <KnetBookTags.Tag parent={@} key={tag.id} data={tag} arranged={arranged} />
          }
          </div>
          <div className='tab-pane not-disabled-tags'>
          {
            for tag in not_disabled_tags
              if tag.name.indexOf(@state.query_keyword) > -1
                arranged = @state.arranged_tag_ids_with_times[tag.id]
                <KnetBookTags.Tag parent={@} key={tag.id} data={tag} arranged={arranged} />
          }
          </div>
          <div className='tab-pane disabled-tags'>
          {
            for tag in disabled_tags
              if tag.name.indexOf(@state.query_keyword) > -1
                arranged = @state.arranged_tag_ids_with_times[tag.id]
                <KnetBookTags.Tag parent={@} key={tag.id} data={tag} arranged={arranged} />
          }
          </div>
          <div className='tab-pane not-arranged-tags'>
          {
            for tag in not_arranged_tags
              if tag.name.indexOf(@state.query_keyword) > -1
                arranged = @state.arranged_tag_ids_with_times[tag.id]
                <KnetBookTags.Tag parent={@} key={tag.id} data={tag} arranged={arranged} />
          }
          </div>
        </div>

      </div>
      <KnetBookTags.Form ref='form' parent={@} />
    </div>

  query: (keyword)->
    @setState query_keyword: keyword

  do_edit: (tag_data)->
    @refs.form.edit tag_data

  do_update: (tag_data)->
    tags_set = @state.tags_set
    tags_set.add tag_data
    @setState tags_set: tags_set

  do_arrange: (tag_data)->
    location.href = "/net/#{@props.data.book_data.name}/tagging?tag_id=#{tag_data.id}"

  statics:
    Tag: React.createClass
      render: ->
        tag = @props.data
        klass = ['tag']
        klass.push 'arranged' if @props.arranged
        klass.push 'disabled' if tag.disabled

        <div className={klass.join(' ')}>
          <div className='name'>
            <span>{tag.name}</span>
            {
              if @props.arranged
                <label>已整理 {@props.arranged} 次</label>
            }
            {
              if tag.disabled
                <label className='disabled'>已关闭</label>
            }
            <a className='edit' href='javascript:;' onClick={@do_edit}>
              <i className='fa fa-edit' /> 编辑
            </a>
            {
              if not tag.disabled
                <a className='arrange' href='javascript:;' onClick={@do_arrange}>
                  <i className='fa fa-play-circle-o' /> 整理
                </a>
            }
          </div>
          <pre className='desc'>{tag.desc.join("\n")}</pre>
          <KnetBookTags.Links data={tag.linked_tag_names || []} />
        </div>

      do_edit: ->
        @props.parent.do_edit @props.data

      do_arrange: ->
        @props.parent.do_arrange @props.data

    Links: React.createClass
      render: ->
        <div className='linked-tags'>
        {
          idx = 0
          for tag_name in @props.data
            <span key={idx++} className='l-tag'>#{tag_name}</span>
        }
        </div>

    KeywordFilter: React.createClass
      render: ->
        <div className='keyword-filter'>
          <input className='form-control' type='text' placeholder='查找……' onChange={@query} />
        </div>

      query: (evt)->
        keyword = jQuery.trim evt.target.value
        @props.parent.query keyword

    Form: React.createClass
      getInitialState: ->
        name_value: ''
        desc_value: ''
        linked_tag_names_value: ''
        enabled: true

      render: ->
        <BSModal.FormModal ref='modal' title='编辑概念信息' bs_size='md' submit={@submit}>
          <div className='form-group'>
            <input className='form-control' type='text' placeholder='概念名称' value={@state.name_value} onChange={@name_value_changed} />
          </div>
          <div className='form-group'>
            <label>
              <input type='checkbox' checked={@state.enabled} onChange={@enabled_changed} /> 是否启用
            </label>
          </div>
          <div className='form-group'>
            <textarea className='form-control' placeholder='概念描述' rows='6' value={@state.desc_value} onChange={@desc_value_changed} />
          </div>
          <div className='form-group'>
            <input className='form-control' type='text' placeholder='相关概念' value={@state.linked_tag_names_value} onChange={@linked_tag_names_value_changed} />
          </div>
        </BSModal.FormModal>

      edit: (tag_data)->
        @setState
          id: tag_data.id
          name_value: tag_data.name
          desc_value: tag_data.desc.join("\n")
          linked_tag_names_value: tag_data.linked_tag_names.join(' ')
          enabled: !tag_data.disabled

        @refs.modal.show()

      name_value_changed: (evt)->
        @setState name_value: evt.target.value

      enabled_changed: (evt)->
        @setState enabled: evt.target.checked

      desc_value_changed: (evt)->
        @setState desc_value: evt.target.value

      linked_tag_names_value_changed: (evt)->
        @setState linked_tag_names_value: evt.target.value

      submit: ->
        @refs.modal.setState saving: true

        data = 
          name: @state.name_value
          desc: [@state.desc_value]
          linked_tag_names: @state.linked_tag_names_value.split(' ')
            .filter (x)-> x.length > 0
            .map (x)-> jQuery.trim(x)
          disabled: !@state.enabled

        jQuery.ajax
          url: "/net/tag/#{@state.id}/update"
          type: 'PUT'
          data: data
        .done (res)=>
          @refs.modal.setState 
            saving: false
            show: false
          @props.parent.do_update res