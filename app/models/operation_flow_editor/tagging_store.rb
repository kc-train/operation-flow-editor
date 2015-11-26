module OperationFlowEditor
  class TaggingStore
    include Mongoid::Document
    include Mongoid::Timestamps

    field :creator_name # 操作者
    field :book_name # 概念集合名称
    field :data # 数据

    default_scope ->{ order(:id.asc) }

    before_save :set_default_value
    def set_default_value
    end

    def simple_json
      {
        id: id.to_s,
        creator_name: creator_name,
        book_name: book_name,
        created_at: created_at.to_s(:db)
      }
    end
  end
end