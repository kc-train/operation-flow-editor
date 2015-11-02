module OperationFlowEditor
  class EditorController < OperationFlowEditor::ApplicationController
    layout 'operation_flow_editor/editor'

    def actions
      @flow = OperationFlowEditor::Flow.find(params[:flow_id])
      @actions = @flow.actions

      path = File.join __dir__, '../../..', "progress-data/export/#{@flow.number}.json"
      if File.exist? path
        @screen_data = JSON.parse File.read path
      else
        @screen_data = nil
      end
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
      @data = get_screen_data params[:xmdm], params[:hmdm]
    end

    private
      # 根据项目代码和画面代码找到画面数据
      def get_screen_data(xmdm, hmdm)
        path = File.join __dir__, '../../..', "progress-data/export/#{xmdm}.json"

        xm_data = JSON.parse File.read path

        xm_data.map {|zjy|
          screens = zjy['input_screens'] || []
          screens.push zjy['response_screen']
          screens.push zjy['compound_screen']
          screens.compact!
        }.flatten.select { |screen|
          screen['hmdm'] == hmdm
        }.first
      end
  end
end