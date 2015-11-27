module OperationFlowEditor
  class NetController < OperationFlowEditor::ApplicationController
    layout 'operation_flow_editor/net'

    def index
    end

    def catalog
      name = params[:name]
      meta = find_or_create_meta name
      @data = meta.catalog_data
      render layout: 'operation_flow_editor/net_editor'
    end

    def tags
      name = params[:name]
      meta = find_or_create_meta name
      @data = meta.tags_data
      render layout: 'operation_flow_editor/net_editor'
    end

    def tagging
      name = params[:name]
      meta = find_or_create_meta name

      @data = {
        book_name: name,
        tagging_stores: OperationFlowEditor::TaggingStore.where(book_name: name).map(&:simple_json),
        catalog_data: meta.catalog_data,
        tags_data: meta.tags_data
      }
      render layout: 'operation_flow_editor/net_editor'
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

    private
      def find_or_create_meta(book_name)
        meta = OperationFlowEditor::BookMeta.where(book_name: book_name).first
        if meta.blank?
          meta = OperationFlowEditor::BookMeta.new(
            book_name: book_name,
            catalog_data: get_workflowy_data(book_name),
            tags_data: get_tags_data(book_name)
          )
          meta.save
        end
        meta
      end

      def get_workflowy_data(name)
        path = File.join __dir__, '../../..', "net-data/#{name}.workflowy.xml"
        
        if File.exist? path
          return xml_2_json Nokogiri::XML open(path)
        end

        return nil
      end

      def xml_2_json(xmldoc)
        root = xmldoc.at('opml body>outline')
        _r root, 0
      end

      def _r(outline_doc, depth)
        {
          id: randstr,
          name: outline_doc['text'],
          depth: depth,
          children: outline_doc.css('>outline').map { |child|
            _r child, depth + 1
          }
        }
      end

      def get_tags_data(name)
        path = File.join __dir__, '../../..', "net-data/#{name}.tags"
        
        if File.exist? path
          return parse_tags File.read(path)
        end

        return nil
      end

      def parse_tags(text)
        text.split(/\-+/).map(&:strip).select {|x|
          x.present?
        }.map {|x|
          arr = x.split(/\n/).map(&:strip)
          {
            id: randstr,
            name: arr[0].sub('#', ''),
            desc: arr[1..-2],
            linked_tags: arr[-1].split('#').map(&:strip).select {|s|
              s.present?
            }
          }
        }
      end

      def randstr(length=8)
        base = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        size = base.size
        re = '' << base[rand(size-10)]
        (length - 1).times {
          re << base[rand(size)]
        }
        re
      end
  end
end