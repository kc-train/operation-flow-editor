module OperationFlowEditor
  class EditorController < OperationFlowEditor::ApplicationController
    layout 'operation_flow_editor/editor'

    def actions
      @flow = OperationFlowEditor::Flow.find(params[:flow_id])
      @actions = @flow.actions

      # @actions = {
      #   'id0' => {
      #     id: 'id0',
      #     name: 'id0',
      #     role: '柜员',
      #     post_action_ids: ['id2', 'id1']
      #   },
      #   'id01' => {
      #     id: 'id01',
      #     name: 'id01',
      #     role: '客户',
      #     post_action_ids: ['id1', 'id11']
      #   },
      #   'id1' => {
      #     id: 'id1',
      #     name: 'id1',
      #     role: '客户',
      #     post_action_ids: ['id2']
      #   },
      #   'id11' => {
      #     id: 'id11',
      #     name: 'id11',
      #     role: '客户',
      #     post_action_ids: ['id2']
      #   },
      #   'id2' => {
      #     id: 'id2',
      #     name: 'id2',
      #     role: '客户',
      #     post_action_ids: ['id3']
      #   },
      #   'id3' => {
      #     id: 'id3',
      #     name: 'id3',
      #     role: '柜员',
      #     post_action_ids: ['id4']
      #   },
      #   'id4' => {
      #     id: 'id4',
      #     name: 'id4',
      #     role: '客户'
      #   }
      # }

      # @actions = {
      #   'id0' => {
      #     id: 'id0',
      #     name: 'hahaha',
      #     role: '柜员',
      #     post_action_ids: ['id1']
      #   },
      #   'id1' => {
      #     id: 'id1',
      #     name: 'hehehe',
      #     role: '柜员',
      #     post_action_ids: ['id2']
      #   },
      #   'id2' => {
      #     id: 'id2',
      #     role: '客户',
      #     name: 'xixixi',
      #     post_action_ids: ['id3', 'id4']
      #   },
      #   'id3' => {
      #     id: 'id3',
      #     role: '柜员',
      #     name: 'ooo'
      #   },
      #   'id4' => {
      #     id: 'id4',
      #     role: '客户',
      #     name: 'kkk',
      #     post_action_ids: ['id5', 'id6']
      #   },
      #   'id5' => {
      #     id: 'id5',
      #     role: '客户',
      #     name: 'www'
      #   },
      #   'id6' => {
      #     id: 'id6',
      #     role: '柜员',
      #     name: 'rrr'
      #   }          
      # }
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
  end
end