module OperationFlowEditor
  class EditorController < OperationFlowEditor::ApplicationController
    layout 'operation_flow_editor/editor'

    def actions
      @flow = OperationFlowEditor::Flow.find(params[:flow_id])
      @actions = @flow.actions

      # path = File.join __dir__, '../../..', "progress-data/export/#{@flow.number}.json"
      # if File.exist? path
      #   @screen_data = JSON.parse File.read path
      # else
      #   @screen_data = nil
      # end
      @screen_data = []
    end

    def update_actions
      @flow = OperationFlowEditor::Flow.find(params[:flow_id])
      @flow.actions = params[:actions]
      @flow.save
      render text: 'ok'
    end

    def roles
      @sidebar_item = :roles
    end

    def screen
      path = File.join __dir__, '../../..', "progress-data/export/#{params[:xmdm]}.json"
      @screen_data = JSON.parse File.read path
    end
  end
end