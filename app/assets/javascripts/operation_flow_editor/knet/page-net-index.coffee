@NetEditorSidebar = React.createClass
  displayName: 'NetEditorSidebar'
  render: ->
    <div className='net-editor-sidebar'>
      {#<NetEditorSidebar.Item name={@props.name} link='overview' text='概览' />}
      <NetEditorSidebar.Item parent={@} link='catalog' text='原始目录' />
      <NetEditorSidebar.Item parent={@} link='tags' text='概念提取' />
      <NetEditorSidebar.Item parent={@} link='tagging' text='概念整理' />
    </div>
  statics:
    Item: React.createClass
      render: ->
        klass = ['item', 'catalog']
        if @props.link == @props.parent.props.action
          klass.push 'active'
        <a className={klass.join(' ')} href="/net/#{@props.parent.props.name}/#{@props.link}">
          <div className='ibox'>{@props.text}</div>
        </a>


# -------------

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
              <a target='_blank' href="/net/#{item.name}/catalog">知识网络组织</a>
            </div>
          </li>
      }
      </ul>
    </div>
