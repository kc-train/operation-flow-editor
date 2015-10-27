module OperationFlowEditor
  class HomeController < OperationFlowEditor::ApplicationController
    def index
      @flows = OperationFlowEditor::Flow.all
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

    def qcn
      render layout: 'qcn'
    end

    def oracle_json
      path = File.join __dir__, '../../..', "data-templates/oracle-dump-json/#{params[:path]}.json"
      str = File.read path
      render json: JSON.parse(str)
    end

    def screen
      path = File.join __dir__, '../../..', "data-templates/oracle-dump-json/172001/hmzds-#{params[:id]}.json"
      str = File.read path
      @data = JSON.parse(str)

      path = File.join __dir__, '../../..', "data-templates/oracle-dump-json/172001/xxmxs-#{params[:id]}.json"
      str = File.read path
      @xxmxs = JSON.parse(str)
    end

    def xmdm
      path = File.join __dir__, '../../..', "data-templates/oracle-dump-json/#{params[:xmdm]}.json"
      @data = JSON.parse File.read path
    end
  end
end