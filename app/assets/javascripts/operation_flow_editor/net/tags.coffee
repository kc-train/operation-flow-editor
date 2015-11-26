@PageNetTags = React.createClass
  render: ->
    <div className='page-net-tags'>
    {
      idx = 0
      for tag in @props.data
        <PageNetTags.Tag key={idx++} data={tag} />
    }
    </div>

  statics:
    Tag: React.createClass
      render: ->
        tag = @props.data
        <div className='tag'>
          <div className='name'>{tag.name}</div>
          <div className='desc'>{tag.desc}</div>
          <PageNetTags.Links data={tag.linked_tags} />
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