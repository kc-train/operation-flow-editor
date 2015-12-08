module OperationFlowEditor
  class NetTagController < OperationFlowEditor::ApplicationController
    def update
      tag = Knet::BookTag.find params[:id]

      tag.name = params[:name]
      tag.desc = params[:desc]
      tag.linked_tag_names = params[:linked_tag_names]
      tag.disabled = params[:disabled]
      tag.save
      
      render json: tag.simple_data
    end

    def get_tags
      ids = params[:ids]
      tags = Knet::BookTag.where(:id.in => ids).map(&:simple_data)
      render json: tags
    end
  end
end