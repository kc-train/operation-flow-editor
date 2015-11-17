module OperationFlowEditor
  class CourseWareController < OperationFlowEditor::ApplicationController
    layout 'operation_flow_editor/course_ware'

    def show
      number = params[:xmdm]

      flow = OperationFlowEditor::Flow.where(number: number).first

      path = File.join __dir__, '../../..', "progress-data/export/#{number}.json"

      xm_data = JSON.parse File.read path

      screens = xm_data.map {|zjy|
        screens = zjy['input_screens'] || []
        screens.push zjy['response_screen']
        screens.push zjy['compound_screen']
        screens.compact!
      }.flatten

      @data = {
        baseinfo: {
          number: number,
          name: flow.name,
          desc: '本交易实现对柜员信息进行维护的功能'
        },
        actioninfo: {
          actions: flow.actions
        },
        screens: screens
      }
    end
  end
end