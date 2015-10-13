module OperationFlowEditor
  class EditorController < OperationFlowEditor::ApplicationController
    layout 'operation_flow_editor/editor'

    def actions
      @flow = OperationFlowEditor::Flow.find(params[:flow_id])
      @actions = @flow.actions || []

      # @actions = [
      #   {
      #     id: 0,
      #     name: 'hahaha',
      #     role: '柜员',
      #     post_actions: [1]
      #   },
      #   {
      #     id: 1,
      #     name: 'hehehe',
      #     role: '柜员',
      #     post_actions: [2]
      #   },
      #   {
      #     id: 2,
      #     role: '客户',
      #     name: 'xixixi'
      #   }      
      # ]

      # @data = { actions: @actions }
    end

    def update_actions
      @flow = OperationFlowEditor::Flow.find(params[:flow_id])
      @flow.actions = params[:actions].values
      @flow.save
      render text: 'ok'
    end

    def roles
      @sidebar_item = :roles
    end
  end
end