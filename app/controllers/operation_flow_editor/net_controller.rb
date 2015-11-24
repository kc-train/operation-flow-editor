module OperationFlowEditor
  class NetController < OperationFlowEditor::ApplicationController
    layout 'operation_flow_editor/net'

    def index
    end

    def show
      name = params[:name]
      @data = get_workflowy_data name
      @tags_data = get_tags_data name
    end

    private
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
            name: arr[0].sub('#', ''),
            desc: arr[1..-2],
            linked_tags: arr[-1].split('#').map(&:strip).select {|s|
              s.present?
            }
          }
        }
      end
  end
end