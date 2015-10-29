module OperationFlowEditor
  class Flow
    include Mongoid::Document
    include Mongoid::Timestamps

    field :number
    field :name
    field :actions
    field :gtd_status # init half almost done

    default_scope ->{ order(:id.desc) }

    before_save :set_default_value
    def set_default_value
      self.number = '000000' if self.number.blank?
      self.name = '未命名流程' if self.name.blank?
    end

    def simple_json
      {
        id: id.to_s,
        number: number,
        name: name,
        gtd_status: gtd_status
      }
    end

    def progress
      h = {
        'init' => 25,
        'half' => 50,
        'almost' => 75,
        'done' => 100
      }

      unless (pr = h[gtd_status]).nil?
        return pr
      else
        return 25
      end
    end
  end
end