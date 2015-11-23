module OperationFlowEditor
  class NetController < OperationFlowEditor::ApplicationController
    layout 'operation_flow_editor/net'

    def index
    end

    def show
      name = params[:name]
      path = File.join __dir__, '../../..', "net-data/#{name}.workflowy.xml"
      if File.exist? path
        @data = xml_2_json Nokogiri::XML open(path)
      else
        @data = nil
      end
    end

    private
      def xml_2_json(xmldoc)
        root = xmldoc.at('opml body>outline')
        _r root
      end

      def _r(outline_doc)
        {
          name: outline_doc['text'],
          children: outline_doc.css('>outline').map { |child|
            _r child
          }
        }
      end
  end
end