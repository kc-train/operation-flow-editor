module Knet
  class BookMeta
    include Mongoid::Document
    include Mongoid::Timestamps

    has_many :catalogs, class_name: 'Knet::BookCatalog'
    has_many :tags, class_name: 'Knet::BookTag'

    field :name # 教材名称

    def simple_data
      {
        name: name
      }
    end
  end
end