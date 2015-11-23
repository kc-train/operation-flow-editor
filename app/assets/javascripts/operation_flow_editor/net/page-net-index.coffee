@PageNetIndex = React.createClass
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
  render: ->
    data = @props.data
    <div className='page-net-workflowy-xml-show'>
      <ul>
        <PageNetWorkflowyXmlShow.Item data={data} />
      </ul>
    </div>

  statics:
    Item: React.createClass
      render: ->
        data = @props.data
        <li>
          <div className='name'>{data.name}</div>
          {
            if data.children.length
              <ul>
              {
                for child in data.children
                  <PageNetWorkflowyXmlShow.Item key={child.name} data={child} />
              }
              </ul>
          }
        </li>