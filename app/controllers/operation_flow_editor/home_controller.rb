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
      path = File.join __dir__, '../../..', "progress-data/export/#{params[:xmdm]}.json"
      @data = JSON.parse File.read path
    end

    def progress
      @screen_count_data = JSON.parse File.read File.join __dir__, '../../..', "progress-data/screens_count.json"

      @all_transactions_data = JSON.parse File.read File.join __dir__, '../../..', "progress-data/all-transactions.json"

      flows_hash = {}
      OperationFlowEditor::Flow.all.each do |flow|
        flows_hash[flow.number] = {
          mongodb_id: flow.id.to_s,
          progress: flow.progress
        }
      end
      
      @all_transactions_data.each do |x|
        id = x['id']
        if not (flow = flows_hash[id]).nil?
          x['mongodb_id'] = flow[:mongodb_id]
          x['progress'] = flow[:progress]
        else
          x['progress'] = 0
        end

        if (sd = @screen_count_data[id]).present?
          x['screen_data'] = sd
        end
      end
    end
  end
end