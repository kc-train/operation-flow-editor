module OperationFlowEditor
  class ApplicationController < ActionController::Base
    layout "operation_flow_editor/application"

    if defined? PlayAuth
      helper PlayAuth::SessionsHelper
    end
  end
end