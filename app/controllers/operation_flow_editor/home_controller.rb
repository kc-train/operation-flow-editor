module OperationFlowEditor
  class HomeController < OperationFlowEditor::ApplicationController
    # 流程清单
    def index
      @flows = OperationFlowEditor::Flow.all
    end

    # 内容展示
    def show
    end

    def actions
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

    def oracle_json
      path = File.join __dir__, '../../..', "data-templates/oracle-dump-json/#{params[:path]}.json"
      str = File.read path
      render json: JSON.parse(str)
    end

  end
end