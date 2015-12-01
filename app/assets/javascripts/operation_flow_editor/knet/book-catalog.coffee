class IDSet
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


class CatalogTree
  constructor: (array_data)->
    @set = new IDSet()
    for item in array_data
      catalog_item = new CatalogItem item, @
      @set.add catalog_item

  blank: ->
    @set.blank()

  roots: ->
    @set.filter (x)-> x.depth is 0

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

@KnetBookCatalog = React.createClass
  displayName: 'KnetBookCatalog'
  getInitialState: ->
    tree: new CatalogTree @props.data

  render: ->
    tree = @state.tree
    <div className='knet-book-catalog'>
    {
      if tree.blank()
        <div className='blank'>没有获取到数据</div>
      else
        <KnetBookCatalog.List data={tree.roots()} />
    }
    </div>

  statics:
    List: React.createClass
      displayName: 'List'
      render: ->
        catalogs = @props.data
        <ul>
        {
          for catalog in catalogs
            <KnetBookCatalog.Item key={catalog.id} data={catalog} />
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

        <li className={klass.join(' ')}>
          <div className='info'>
            {
              if data.has_children()
                <a className='expand-btn' href='javascript:;' onClick={@toggle_expand}>
                  <i className='fa fa-minus' />
                  <i className='fa fa-plus' />
                </a>
            }
            <div className='name'>{data.name}</div>
          </div>
          {
            if data.has_children()
              <KnetBookCatalog.List data={data.children()} />
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