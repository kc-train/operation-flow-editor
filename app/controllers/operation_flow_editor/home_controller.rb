module OperationFlowEditor
  class HomeController < OperationFlowEditor::ApplicationController
    def index
      redirect_to :actions
    end

    def actions
    end

    def roles
      @sidebar_item = :roles
    end

    def yaml_sample
      @ywid = params[:ywid] || 122100

      if params[:format] == 'json'
        path = File.join __dir__, '../../..', "data-templates/sample/#{@ywid}.yaml"
        str = File.read path
        data = YAML.load str
        render :json => data
        return
      end
    end
  end
end