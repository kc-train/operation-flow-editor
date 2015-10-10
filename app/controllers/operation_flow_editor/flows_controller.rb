module OperationFlowEditor
  class FlowsController < OperationFlowEditor::ApplicationController
    def create
      post_params = params.require(:flow).permit(:number, :name)
      flow = OperationFlowEditor::Flow.create post_params
      render :json => flow.simple_json
    end

    def index
      render :json => OperationFlowEditor::Flow.all.map(&:simple_json)
    end

    def destroy
      OperationFlowEditor::Flow.find(params[:id]).destroy
      render text: 'ok'
    end
  end
end