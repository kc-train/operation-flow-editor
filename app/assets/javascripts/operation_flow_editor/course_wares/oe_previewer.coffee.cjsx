###
  FrontEndCourseWare 前端课件
    RoleLane 角色泳道
      ActionNode 操作步骤节点
      ActionNode
    RoleLane 
###

ActionNode = React.createClass
  render: ->
    pos = @props.action.pos()

    <div className='action-node' style={{left: "#{pos.left}px", top: "#{pos.top}px"}}>
      <div className='name'>{@props.action.name()}</div>
    </div>


RoleLane = React.createClass
  render: ->
    <div className='role-lane' data-role={@props.role}>
      <div className='lane-header'>角色：{@props.role}</div>
      <div className='lane-nodes' ref='nodes_panel'>
        {
          for action in @props.actions
            @maxtop ||= 0
            @maxleft ||= 0
            pos = action.pos()
            @maxtop = Math.max @maxtop, pos.top
            @maxleft = Math.max @maxleft, pos.left

            <ActionNode action={action} key={action.name()} />
        }
      </div>
    </div>

  componentDidMount: ->
    # 修正 role panel 的宽高
    height = @maxtop + 50 + 30
    width = @maxleft + 120 + 30
    $panel = jQuery @refs.nodes_panel.getDOMNode()
    $panel.css
      width: width
      height: height


@OEPreviewer = React.createClass
  render: ->
    @dp = new DataParser @props.data
    @roles = @dp.get_roles()

    <div className='front-end-course-ware'>
      {
        for role, actions of @roles
          <RoleLane role={role} actions={actions} key={role} />
      }
    </div>

  getInitialState: ->
    roles: []
    actions: []

  componentDidMount: ->
    # 画箭头
    role_pos = {}

    for role, actions of @roles
      $lane = jQuery(".role-lane[data-role=#{role}] .lane-nodes")
      role_pos[role] = $lane.position()

    # 第二次遍历，画箭头
    # @dp.draw_arrow(role_pos)
    # TODO 改为动态箭头
    @dp.draw_animate_arrow(role_pos)


class DataParser
  constructor: (@data)->
    # 整理数据
    @tidy_data()

  tidy_data: ->
    @roles = {}
    @actions = for _action in @data.actions || []
      action = new Action _action
      role = action.role()
      @roles[role] ||= []
      @roles[role].push action
      action

    # 递归遍历，计算深度
    @deeps = {}
    for role, actions of @roles
      @deeps[role] = {}

    if @start_action()?
      @_r1_deep @start_action(), 0

  _r1_deep: (action, deep)->
    deep_role = @deeps[action.role()]

    deep_role[deep] ||= []

    # 当前 action 并未设置 deep
    # 直接设置 deep
    if not action.deep?
      deep_role[deep].push action
      action.deep = deep

    # 当前 action 已经设置 deep
    # 并且当前 deep < action.deep
    # 从 deep_role 中移除，再根据当前 deep 设置
    else if deep < action.deep
      deep_role[action.deep] = deep_role[action.deep].filter (x)->
        x.name() != action.name()

      deep_role[deep].push action
      action.deep = deep

    action.posx = deep_role[action.deep].length - 1
    action.posy = action.deep

    action.children = for id in action.children_ids()
      child = (@actions.filter (x)-> x.id_eq id)[0]
      @_r1_deep child, action.deep + 1
      child

  draw_animate_arrow: (role_pos)->
    @arrow_offset = 0 if not @arrow_offset?
    requestAnimationFrame =>
      @draw_arrow role_pos
      @arrow_offset += 0.5
      @draw_animate_arrow role_pos

  draw_arrow: (role_pos)->
    $cwel = jQuery('.front-end-course-ware')
    height = $cwel.height() - 50
    width = $cwel.width()

    if not @curve_arrow?
      $canvas = jQuery('<canvas>')
        .attr 'width', width
        .attr 'height', height
        .prependTo $cwel

      @curve_arrow = new CurveArrow $canvas[0]

    @curve_arrow.clear()
    @_r2 @start_action(), role_pos

  _r2: (action, role_pos)->
    # 画箭头
    for child in action.children
      x0 = action.pos().left + 60
      y0 = action.pos().top + 25
      x1 = child.pos().left + 60
      y1 = child.pos().top + 25

      action_offset = role_pos[action.role()]
      child_offset = role_pos[child.role()]

      x0 += action_offset.left
      x1 += child_offset.left

      @curve_arrow.draw x0, y0, x1, y1, '#999999', @arrow_offset
      @_r2 child, role_pos

  get_actions: ->
    @actions

  get_roles: ->
    @roles

  start_action: ->
    @actions[0]


class Action
  constructor: (@data)->

  children_ids: ->
    @data.post_actions || []

  id_eq: (id)->
    @data.id is id

  name: ->
    @data.name

  role: ->
    @data.role

  pos: ->
    @offx = 30
    @offy = 30

    {
      left: @posx * 150 + @offx
      top: @posy * 80 + @offy
    }