module OperationFlowEditor
  class Engine < ::Rails::Engine
    isolate_namespace OperationFlowEditor
    config.to_prepare do
      ApplicationController.helper ::ApplicationHelper
    end
  end
end