module OperationFlowEditor
  class EditorController < OperationFlowEditor::ApplicationController
    layout 'operation_flow_editor/editor'

    def actions
      @flow = OperationFlowEditor::Flow.find(params[:flow_id])

      path = File.join __dir__, '../../..', "data-templates/sample/#{122100}.yaml"
      str = File.read path
      @data = YAML.load str

      @actions = [
        {
          id: 0,
          name: 'hahaha',
          post_actions: [1]
        },
        {
          id: 1,
          name: 'hehehe',
          post_actions: [2]
        },
        {
          id: 2,
          name: 'xixixi'
        }      
      ]
    end

    def roles
      @sidebar_item = :roles
    end
  end
end