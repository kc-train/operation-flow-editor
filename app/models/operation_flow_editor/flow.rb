module OperationFlowEditor
  class Flow
    include Mongoid::Document
    include Mongoid::Timestamps

    field :number
    field :name
    field :data

    default_scope ->{ order(:id.desc) }

    def simple_json
      {
        id: id.to_s,
        number: number,
        name: name,
      }
    end
  end
end