module Knet
  class BookTaggingTask
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :book, class_name: 'Knet::BookMeta'
    belongs_to :tag, class_name: 'Knet::BookTag'
    
    field :catalog_ids, default: [] # 相关目录 ID
    field :catalog_stack, default: [] # 待分配目录堆栈
    field :finished, default: false

    default_scope ->{ order(:id.asc) }

    def simple_data
      {
        id: id.to_s,
        tag: tag.simple_data,
        catalog_ids: catalog_ids,
        catalog_stack: catalog_stack,
        finished: finished
      }
    end

    class << self
      # 指定针对一个 tag 进行整理任务
      def from_tag_id(tag_id)
        tag = Knet::BookTag.where(id: tag_id).first
        task = Knet::BookTaggingTask.create(
          book: tag.book,
          tag: tag
        )
      end

      # 调度一个整理任务
      def dispatch(book_name)
        book = Knet::BookMeta.where(name: book_name).first

        all_tag_ids = Knet::BookTag.can_dispatch_ids_of(book)
        arranged_tag_ids = arranged_tag_ids_of(book)

        pool_ids = all_tag_ids - arranged_tag_ids

        if pool_ids.present?
          # 还有备选的概念
          tag_id = pool_ids[rand(pool_ids.length)]
          task = Knet::BookTaggingTask.create(
            book: book,
            tag: Knet::BookTag.find(tag_id)
          )
        else
          tag_id = all_tag_ids[rand(all_tag_ids.length)]
          task = Knet::BookTaggingTask.create(
            book: book,
            tag: Knet::BookTag.find(tag_id)
          )
        end
      end

      # 返回已经被整理过的 tag id 列表
      def arranged_tag_ids_of(book)
        Knet::BookTaggingTask.where(book: book, finished: true).map {|x| x.tag_id.to_s}.uniq
      end

      def arranged_tag_ids_with_times_of(book)
        tag_ids = Knet::BookTaggingTask.where(book: book, finished: true).map {|x| x.tag_id.to_s}
        hash = Hash.new(0)
        tag_ids.each do |tag_id|
          hash[tag_id] = hash[tag_id] + 1
        end
        hash
      end

      def tag_with_catalog_ids_of(book)
        hash = Hash.new([])
        Knet::BookTaggingTask.where(book: book, finished: true).each do |x|
          x.catalog_ids.each { |catalog_id|
            hash[catalog_id] = (hash[catalog_id] + [x.tag_id.to_s]).uniq
          }
        end
        hash
      end
    end
  end
end