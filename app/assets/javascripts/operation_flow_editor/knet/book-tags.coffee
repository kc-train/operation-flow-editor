@KnetBookTags = React.createClass
  displayName: 'KnetBookTags'
  getInitialState: ->
    tags_data: @props.data.tags_data
    arranged_tag_ids_with_times: @props.data.arranged_tag_ids_with_times

  render: ->
    <div className='knet-book-tags'>
      <h3 className='tags-count'>共 {@state.tags_data.length} 个概念</h3>
      <hr/>
    {
      for tag in @state.tags_data
        arranged = @state.arranged_tag_ids_with_times[tag.id]
        <KnetBookTags.Tag key={tag.id} data={tag} arranged={arranged} />
    }
    </div>

  statics:
    Tag: React.createClass
      render: ->
        tag = @props.data
        klass = ['tag']
        klass.push 'arranged' if @props.arranged
        <div className={klass.join(' ')}>
          <div className='name'>
            <span>{tag.name}</span>
            {
              if @props.arranged
                <label>已整理 {@props.arranged} 次</label>
            }
          </div>
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