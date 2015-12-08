@IDSet = class
  constructor: ->
    @hash = {}

  add: (item)->
    @hash[item.id] = item

  remove: (id)->
    delete @hash[id]

  get: (id)->
    @hash[id]

  blank: ->
    Object.keys(@hash).length is 0

  filter: (func)->
    Object.keys(@hash)
      .map (id)=> @hash[id]
      .filter func

  ids: ->
    Object.keys(@hash)

  count: ->
    Object.keys(@hash).length

  each: (func)->
    for id, value of @hash
      func value

@CatalogTree = class
  constructor: (@array_data)->
    @set = new IDSet()
    for item in @array_data
      catalog_item = new CatalogItem item, @
      @set.add catalog_item

  blank: ->
    @set.blank()

  roots: ->
    @set.filter (x)-> x.depth is 0

  get: (id)->
    @set.get(id)

  get_index: (id)->
    (@array_data.map (x)-> x.id).indexOf id

  count: ->
    @set.count()


class CatalogItem
  constructor: (data, @tree)->
    @id = data.id
    @depth = data.depth
    @name = data.name
    @children_ids = data.children_ids

  has_children: ->
    @children_ids.length > 0

  children: ->
    @children_ids.map (id)=> @tree.set.get(id)

  descendants: ->
    re = []
    for child in @children()
      re = re.concat child.descendants()
    re


@KnetBookCatalog = React.createClass
  displayName: 'KnetBookCatalog'
  getInitialState: ->
    tree: new CatalogTree @props.data.catalogs_data
    tag_with_catalog_ids: @props.data.tag_with_catalog_ids

  render: ->
    tree = @state.tree
    <div className='knet-book-catalog'>
    {
      if tree.blank()
        <div className='blank'>没有获取到数据</div>
      else
        <div>
          <KnetBookCatalog.List host={@} data={tree.roots()} />
          <KnetBookCatalog.TagsModal host={@} ref='tags_modal' />
        </div>
    }
    </div>

  show_tags: (item_data, tag_ids)->
    @refs.tags_modal.show(item_data, tag_ids)


  statics:
    List: React.createClass
      displayName: 'List'
      render: ->
        catalogs = @props.data
        <ul>
        {
          for catalog in catalogs
            <KnetBookCatalog.Item key={catalog.id} host={@props.host} data={catalog} />
        }
        </ul>

    Item: React.createClass
      displayName: 'Item'
      getInitialState: ->
        ep = @get_expand_local_storage() 
        if ep?
          expand: ep == 'true'
        else if @props.data.depth > 0
          expand: false
        else
          expand: true

      render: ->
        data = @props.data
        klass = []
        klass.push 'expand' if @state.expand
        klass.push 'leafnode' if not data.has_children()

        @set_expand_local_storage()

        tag_with_catalog_ids = @props.host.state.tag_with_catalog_ids
        tag_ids = tag_with_catalog_ids[data.id] || []

        <li className={klass.join(' ')}>
          <div className='info'>
            {
              if data.has_children()
                <a className='expand-btn' href='javascript:;' onClick={@toggle_expand}>
                  <i className='fa fa-minus' />
                  <i className='fa fa-plus' />
                </a>
            }
            <div className='name'>
              <span>{data.name}</span>
              {
                if tag_ids.length
                  <KnetBookCatalog.TagLabel host={@props.host} item_data={data} tag_ids={tag_ids} />
              }
            </div>
          </div>
          {
            if data.has_children()
              <KnetBookCatalog.List host={@props.host} data={data.children()} />
          }
        </li>

      toggle_expand: ->
        @setState expand: !@state.expand

      set_expand_local_storage: ->
        key = "net-catalog-tree-expand-#{@props.data.id}"
        localStorage[key] = @state.expand

      get_expand_local_storage: ->
        key = "net-catalog-tree-expand-#{@props.data.id}"
        localStorage[key]

    TagLabel: React.createClass
      render: ->
        tag_ids = @props.tag_ids
        <label onClick={@show_tags}>{tag_ids.length} 个概念</label>

      show_tags: ->
        @props.host.show_tags @props.item_data, @props.tag_ids

    TagsModal: React.createClass
      getInitialState: ->
        title: ''
        tags: []
      render: ->
        <BSModal.InfoModal ref='modal' bs_size='md' title={@state.title}>
        {
          for tag in @state.tags
            <span className='tag' key={tag.id}>
              <i className='fa fa-tag' />
              <span>{tag.name}</span>
              <a href="/net/#{@props.host.props.data.book_data.name}/tagging?tag_id=#{tag.id}"><i className='fa fa-play-circle-o' /> 整理</a>
            </span>
        }
        </BSModal.InfoModal>
      show: (item_data, tag_ids)->
        @refs.modal.show()
        @refs.modal.loading()
        @setState
          title: item_data.name
        jQuery.ajax
          url: '/net/tag/get_tags'
          data:
            ids: tag_ids
        .done (res)=>
          @refs.modal.loaded()
          @setState tags: res