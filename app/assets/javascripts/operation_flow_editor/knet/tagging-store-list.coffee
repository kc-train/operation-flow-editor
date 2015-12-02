@NetTaggingStoreList = React.createClass
  getInitialState: ->
    tagging_stores: @props.data
  render: ->
    <div className='net-tagging-store-list'>
      <h3>整理记录清单</h3>
      <a className='add-btn' href='javascript:;' onClick={@_new}>
        <i className='fa fa-plus' />
      </a>
      <NetTaggingStoreList.Form parent={@} ref='form' show={false} book_name={@props.book_name} />
      {
        for ts in @state.tagging_stores
          active = @props.active_store_id == ts.id
          <NetTaggingStoreList.Item active={active} key={ts.id} data={ts} tool={@props.tool} />
      }
    </div>

  _new: ->
    @refs.form.show()

  create_done: (res)->
    tagging_stores = @state.tagging_stores
    tagging_stores.push res
    @setState tagging_stores: tagging_stores

  statics:
    Item: React.createClass
      render: ->
        klass = if @props.active then 'item active' else 'item'
        <div className={klass} onClick={@load_store_data}>
          <div className='creator'>{@props.data.creator_name}</div>
          <div className='created-at'>{@props.data.created_at}</div>
        </div>

      load_store_data: ->
        @props.tool.load_store_data @props.data.id

    Form: React.createClass
      getInitialState: ->
        show: @props.show
        creator_name: ''
      render: ->
        style =
          display: if @state.show then 'block' else 'none'

        can_submit = @state.creator_name.length

        <div className='store-form' style={style}>
          <input type='text' placeholder='输入整理者姓名' className='form-control' onChange={@do_input} value={@state.creator_name}/>
          <div className='ops'>
            <a className="btn btn-success btn-sm #{if can_submit then '' else 'disabled'}" onClick={@submit}>确定</a>
            <a className='btn btn-default btn-sm' onClick={@hide}>取消</a>
          </div>
        </div>

      show: ->
        @setState show: true

      hide: ->
        @setState show: false

      do_input: (evt)->
        @setState creator_name: jQuery.trim(evt.target.value)

      submit: ->
        jQuery.ajax
          type: 'post'
          url: "/net/#{@props.book_name}/create_tagging_store"
          data:
            creator_name: @state.creator_name
        .done (res)=>
          @props.parent.create_done res
          @hide()
          @setState creator_name: ''