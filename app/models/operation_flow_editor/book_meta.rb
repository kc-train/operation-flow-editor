module OperationFlowEditor
  class BookMeta
    include Mongoid::Document
    include Mongoid::Timestamps

    field :book_name # 概念集合名称
    field :catalog_data
    field :tags_data

    default_scope ->{ order(:id.asc) }
  end
end