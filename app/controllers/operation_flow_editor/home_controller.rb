module OperationFlowEditor
  class HomeController < OperationFlowEditor::ApplicationController
    def index
      redirect_to :actions
    end

    def actions
    end

    def roles
      @sidebar_item = :roles
    end
  end
end