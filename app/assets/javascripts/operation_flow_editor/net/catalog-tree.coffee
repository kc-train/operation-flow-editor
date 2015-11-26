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
        ep = @get_expand_local_storage() 
        if ep?
          expand: ep == 'true'
        else if @props.data.depth > 0
          expand: false
        else
          expand: true

      render: ->
        data = @props.data
        has_children = data.children.length
        klass = []
        klass.push if @state.expand then 'expand' else ''
        klass.push if has_children then '' else 'leafnode'

        @set_expand_local_storage()

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

      set_expand_local_storage: ->
        key = "net-catalog-tree-expand-#{@props.data.name}"
        localStorage[key] = @state.expand

      get_expand_local_storage: ->
        key = "net-catalog-tree-expand-#{@props.data.name}"
        localStorage[key]