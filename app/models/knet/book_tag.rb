module Knet
  class BookTag
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :book, class_name: 'Knet::BookMeta'

    field :name # 概念名
    field :desc
    field :linked_tag_names

    field :disabled, type: Boolean # 使之不生效

    default_scope ->{ order(:id.asc) }

    def simple_data
      {
        id: id.to_s,
        name: name,
        desc: desc,
        linked_tag_names: linked_tag_names,
        disabled: disabled
      }
    end

    class << self
      def get_or_init_data(book_name)
        book = Knet::BookMeta.find_or_create_by name: book_name

        if book.tags.blank?
          build_tags_from_file(book)
        end

        book.tags.map(&:simple_data)
      end

      def build_tags_from_file(book)
        path = Rails.root.join '..', 'net-data', "#{book.name}.tags"

        if File.exist? path
          return parse_tags book, File.read(path)
        end
      end

      def parse_tags(book, text)
        text.split(/\-+/).map(&:strip).select {|x|
          x.present?
        }.each {|x|
          arr = x.split(/\n/).map(&:strip)

          name = arr[0].sub('#', '')
          if arr[-1][0] == '#'
            desc = arr[1..-2]
            linked_tag_names = arr[-1].split('#').map(&:strip).select {|s|
              s.present?
            }
          else
            desc = arr[1..-1]
            linked_tag_names = []
          end

          BookTag.create(
            book: book,
            name: name,
            desc: desc,
            linked_tag_names: linked_tag_names
          )
        }
      end

      def can_dispatch_ids_of(book)
        Knet::BookTag.where(book: book, :disabled.ne => true).map {|x| x.id.to_s}
      end

    end
  end
end