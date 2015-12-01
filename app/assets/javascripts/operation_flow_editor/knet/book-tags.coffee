@KnetBookTags = React.createClass
  displayName: 'KnetBookTags'
  render: ->
    <div className='knet-book-tags'>
      <h3 className='tags-count'>共 {@props.data.length} 个概念</h3>
      <hr/>
    {
      for tag in @props.data
        <KnetBookTags.Tag key={tag.id} data={tag} />
    }
    </div>

  statics:
    Tag: React.createClass
      render: ->
        tag = @props.data
        <div className='tag'>
          <div className='name'>{tag.name}</div>
          <div className='desc'>{tag.desc}</div>
          <KnetBookTags.Links data={tag.linked_tag_names} />
        </div>

    Links: React.createClass
      render: ->
        <div className='linked-tags'>
        {
          idx = 0
          for tag_name in @props.data
            <span key={idx++} className='l-tag'>#{tag_name}</span>
        }
        </div>