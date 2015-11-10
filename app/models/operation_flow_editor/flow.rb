module OperationFlowEditor
  class Flow
    include Mongoid::Document
    include Mongoid::Timestamps

    field :number
    field :name
    field :actions
    field :gtd_status # init half almost done
    field :business_kind

    default_scope ->{ order(:id.desc) }

    before_save :set_default_value
    def set_default_value
      self.number = '000000' if self.number.blank?
      self.name = '未命名流程' if self.name.blank?
    end

    def simple_json
      if actions
        actions_count = actions.count
        p actions
        gy_count = actions.values.select {|x| x['role'] == '柜员'}.length
        kh_count = actions.values.select {|x| x['role'] == '客户'}.length
      else
        actions_count = 0
        gy_count = 0
        kh_count = 0
      end

      {
        id: id.to_s,
        number: number,
        name: name,
        business_kind: business_kind,
        gtd_status: gtd_status,
        actions: {
          total: actions_count,
          gy_count: gy_count,
          kh_count: kh_count
        }
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