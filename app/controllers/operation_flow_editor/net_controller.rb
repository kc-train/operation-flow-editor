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
        # tagging_stores: OperationFlowEditor::TaggingStore.where(book: name).book(&:simple_json),
      }
      # render layout: 'operation_flow_editor/net_editor'
      render json: @data
    end

    # 创建整理记录
    def create_tagging_store
      ts = OperationFlowEditor::TaggingStore.new
      ts.creator_name = params[:creator_name]
      ts.book_name = params[:name]
      ts.save

      render json: ts.simple_json
    end

    def get_tagging_store
      id = params[:id]
      ts = OperationFlowEditor::TaggingStore.find(id)
      render json: ts.complex_json
    end

    def save_tagging_store
      id = params[:id]
      ts = OperationFlowEditor::TaggingStore.find(id)
      ts.current_tag = params[:current_tag]
      ts.current_chapter = params[:current_chapter]
      ts.data = params[:link_data]
      ts.save
      render json: ts.complex_json
    end
  end
end