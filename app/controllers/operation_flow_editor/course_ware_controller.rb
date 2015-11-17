module OperationFlowEditor
  class CourseWareController < OperationFlowEditor::ApplicationController
    layout 'operation_flow_editor/course_ware'

    def show
      number = params[:xmdm]

      flow = OperationFlowEditor::Flow.where(number: number).first

      path = File.join __dir__, '../../..', "progress-data/export/#{number}.json"

      xm_data = JSON.parse File.read path

      screens = xm_data.map {|zjy|
        screens = zjy['input_screens'] || []
        screens.push zjy['response_screen']
        screens.push zjy['compound_screen']
        screens.compact!
      }.flatten

      @data = {
        baseinfo: {
          number: number,
          name: flow.name,
          desc: '本交易实现对柜员信息进行维护的功能'
        },
        actioninfo: {
          actions: flow.actions,
          action_desc: [
"客户向柜员提出垫款还款的要求，等待柜员做后续处理。  ",
"如果客户在银行已有存款账户，就使用客户己有的存款户。（此存款户不能是集团二级账户、协定存款 B 户或临时户）",
"客户向柜员提供贷款相关账号",
"柜员输入机构号和贷款账号",
"柜员向客户询问贷款还款的形式，是部分偿还，还是全部偿还。",
"客户向柜员说明还款的要求",
"柜员逐项录入贷款还款信息。",
"柜员输入批次号和凭证号。",
"柜员逐项录入贷款还款信息

手工收回社团贷款本息时，各成员社（除主办社外）应通过扣款账号扣收。

按揭贷款在提前归还时，可先通过“利息试算”交易测算出需归还的本息。应该提前向经办行提出申请，征得经办行同意后办理提前还款手续，并按提前归还贷款本金的一定比例（由前台人员依据合同约定输入）收取违约金。提前部分还款的，必须先结清拖欠的本金和利息。",
"请仔细确认贷款还款信息是否正确。",
"柜员确认贷款还款信息无误后，点击提交按钮，即可打印三联收回贷款凭证",
"客户在单据上签字并返还给柜员",
"柜员收回签字单据，并把需要客户留存的凭证递交给客户。",
          ],
          screens: screens,
          screens_desc: [
"",
"",
"",
"机构号是柜员所在行、所的代码。",
"",
"",
"产品名称、住址、账号、币种、户名、还款方式本金金额、剩余期数、当期本金、当期利息、均为自动回显，还款金额为手工输入项，提前还款收费标志，可以根据实际情况选择，0-否，1-是。",
"批次为必输项，输入与支取凭证相符的批次号码。

凭证号码为必输项，输入与支取凭证相符的号码，系统自动判断凭证信息是否与付款人信息匹配及凭证状态是否为“空白”，输入正确，系统自动更改该凭证状态为“销号”；输入错误，则不通过。",
"还款方式选择项包括 1-本金 2-本利和 3-利息 三种。对于本利和还款，只能跳入还款总额字段，回显还本金额，还息金额；对于本金还款，只能跳入“还本金额”字段，回显还款总额和还息金额。系统自动根据还款顺序确定相应的利息

还本金额需手工输入（提前还款时自动回显），其金额不能超过上面计算出来的金额

还息金额将按输入的还本金额自动回显

还款总额将根据输入的“还本金额”“还息金额”回显

支付方式选择项 1 现金 2 转账

支取凭证种类有四种 002-转帐支票 100-储蓄存折（只有对私） 201-一卡通 607-特种转帐凭证

摘要码将自动回显，默认显示为“支取”",
"画面上各字段都是自动回显内容",
"画面上没有需要填充的字段",
"",
""
          ]
        },
      }
    end
  end
end