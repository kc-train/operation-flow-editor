@ExampleCourseWares = React.createClass
  render: ->
    data = @props.data
    <div className='example-course-wares'>
    {
      for cdata in data
        <CourseWareItem key={cdata.number} data={cdata} />
    }
    </div>

CourseWareItem = React.createClass
  render: ->
    data = @props.data
    <div className='course-ware' data-url="/cw/#{data.number}">
      <div className='cbox' onClick={@open_course_ware}>
        <div className='icon'>
          <div className='ic'>
            <i className='fa fa-cny' />
            <i className='fa fa-dollar' />
          </div>
        </div>
        <div className='number'>#{data.number}</div>
        <div className='name'>{data.name}</div>
        <div className='prog'>0% 已学</div>
        {
          if data.is_published
            <div className='is-published'>
              已发布
            </div>
        }
        <div className='btnc'>
          <a className='btn btn-default' href='javascript:;'>开始学习</a>
        </div>
      </div>
    </div>

  open_course_ware: (evt)->
    url = jQuery(evt.target).closest('.course-ware').data('url')
    location.href = url