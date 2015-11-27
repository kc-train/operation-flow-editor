module OperationFlowEditor
  class TaggingStore
    include Mongoid::Document
    include Mongoid::Timestamps

    field :creator_name # 操作者
    field :book_name # 概念集合名称
    field :data
    field :current_tag # 当前正处理的概念
    field :current_chapter # 当前正处理的目录章节

    default_scope ->{ order(:id.asc) }

    # data format
    # {
    #   chapter_1: {
    #     tag_0: [c1, c2]
    #     tag_1: [c3, c4]
    #     ...
    #   },
    #   chapter_2: {
    #     ...
    #   }
    # }

    def simple_json
      {
        id: id.to_s,
        creator_name: creator_name,
        book_name: book_name,
        created_at: created_at.to_s(:db)
      }
    end

    def complex_json
      {
        id: id.to_s,
        creator_name: creator_name,
        book_name: book_name,
        created_at: created_at.to_s(:db),
        data: data,
        current_tag: current_tag,
        current_chapter: current_chapter
      }
    end
  end
end