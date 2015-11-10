module OperationFlowEditor
  class FlowsController < OperationFlowEditor::ApplicationController
    def create
      post_params = params.require(:flow).permit(:number, :name, :gtd_status, :business_kind)
      flow = OperationFlowEditor::Flow.create post_params
      render :json => flow.simple_json
    end

    def update
      post_params = params.require(:flow).permit(:number, :name, :gtd_status, :business_kind)
      flow = OperationFlowEditor::Flow.find params[:id]

      flow.number = params[:flow][:number]
      flow.name = params[:flow][:name]
      flow.business_kind = params[:flow][:business_kind]
      flow.gtd_status = params[:flow][:gtd_status]
      
      flow.save
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