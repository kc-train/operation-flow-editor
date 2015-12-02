module OperationFlowEditor
  class NetController < OperationFlowEditor::ApplicationController
    layout 'operation_flow_editor/net'

    def index
    end

    def catalog
      name = params[:name]
      @data = Knet::BookCatalog.get_or_init_data name
      render layout: 'operation_flow_editor/net_editor'
      # render json: @data
    end

    def tags
      name = params[:name]
      @data = Knet::BookTag.get_or_init_data name
      render layout: 'operation_flow_editor/net_editor'
      # render json: @data
    end

    def tagging
      name = params[:name]

      @data = {
        book_name: name,
        catalogs_data: Knet::BookCatalog.get_or_init_data(name),
        tags_data: Knet::BookTag.get_or_init_data(name)
      }
      render layout: 'operation_flow_editor/net_editor'
      # render json: @data
    end

    def start_tagging
      name = params[:name]
      task = Knet::BookTaggingTask.dispatch(name)
      render json: task.simple_data
    end

    def save_tagging_task
      task = Knet::BookTaggingTask.find params[:task_id]
      task.catalog_ids += params[:added_catalog_ids]
      task.catalog_stack = params[:new_stack]
      if task.catalog_stack.blank?
        task.finished = true 
      end
      task.save
      render json: task.simple_data
    end
  end
end