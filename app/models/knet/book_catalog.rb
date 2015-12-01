module Knet
  class BookCatalog
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :book, class_name: 'Knet::BookMeta'

    field :parent_id
    field :children_ids    
    field :name # 目录项名称
    field :depth # 深度

    default_scope ->{ order(:id.asc) }

    def simple_data
      {
        id: id.to_s,
        name: name,
        depth: depth,
        parent_id: parent_id,
        children_ids: children_ids
      }
    end

    class << self
      def get_or_init_data(book_name)
        book = Knet::BookMeta.find_or_create_by name: book_name

        if book.catalogs.blank?
          build_tree_from_file(book)
        end

        book.catalogs.map(&:simple_data)
      end

      def build_tree_from_file(book)
        path = Rails.root.join '..', 'net-data', "#{book.name}.workflowy.xml"

        if File.exist? path
          xml_doc = Nokogiri::XML open(path)
          root_doc = xml_doc.at('opml body>outline')
          _build_item book, root_doc, 0, nil
        end
      end

      def _build_item(book, outline_doc, depth, parent_id)
        bc = BookCatalog.new(
          book: book,
          name: outline_doc['text'],
          depth: depth,
          parent_id: parent_id
        )

        bc.children_ids = outline_doc.css('>outline').map { |child_doc|
          _build_item(book, child_doc, depth + 1, bc.id.to_s).id.to_s
        }

        bc.save
        bc
      end
    end
  end
end