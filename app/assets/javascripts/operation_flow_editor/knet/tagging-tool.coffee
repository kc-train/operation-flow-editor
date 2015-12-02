@NetTaggingTool = React.createClass
  render: ->
    <div className='net-tagging-tool'>
      <NetTaggingWizard ref='wizard' data={@props.data} tool={@} />
    </div>