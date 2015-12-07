module OperationFlowEditor
  class NetController < OperationFlowEditor::ApplicationController
    layout 'operation_flow_editor/net'

    def index
    end

    def catalog
      name = params[:name]
      catalogs_data = Knet::BookCatalog.get_or_init_data name

      book = Knet::BookMeta.where(name: name).first
      tag_with_catalog_ids = Knet::BookTaggingTask.tag_with_catalog_ids_of(book)

      @data = {
        catalogs_data: catalogs_data,
        tag_with_catalog_ids: tag_with_catalog_ids
      }

      render layout: 'operation_flow_editor/net_editor'
      # render json: @data
    end

    def tags
      name = params[:name]
      tags_data = Knet::BookTag.get_or_init_data name

      book = Knet::BookMeta.where(name: name).first
      arranged_tag_ids_with_times = Knet::BookTaggingTask.arranged_tag_ids_with_times_of(book)

      @data = {
        book_data: book.simple_data,
        tags_data: tags_data,
        arranged_tag_ids_with_times: arranged_tag_ids_with_times
      }

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

      if params[:tag_id]
        @data[:task] = Knet::BookTaggingTask.from_tag_id(params[:tag_id]).simple_data
      end

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