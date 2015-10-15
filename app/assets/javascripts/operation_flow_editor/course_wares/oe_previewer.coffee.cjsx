###
  FrontEndCourseWare 前端课件
    RoleLane 角色泳道
      ActionNode 操作步骤节点
      ActionNode
    RoleLane 
###

ActionNode = React.createClass
  displayName: 'ActionNode'
  render: ->
    pos = @props.action.css_pos()

    <div className='action-node' style={{left: "#{pos.left}px", top: "#{pos.top}px"}}>
      <div className='name'>{@props.action.name}</div>
    </div>


RoleLane = React.createClass
  displayName: 'RoleLane'
  render: ->
    <div className='role-lane' data-role={@props.role}>
      <div className='lane-header'>角色：{@props.role}</div>
      <div className='lane-nodes' ref='nodes_panel'>
        {
          for action in @props.actions
            @bottom ||= 0
            @right ||= 0
            css_pos = action.css_pos()
            @bottom = Math.max @bottom, css_pos.bottom
            @right = Math.max @right, css_pos.right

            <ActionNode action={action} key={action.id} />
        }
      </div>
    </div>

  componentDidMount: ->
    # 修正 role panel 的宽高
    height = @bottom + 30
    width = @right + 30
    $panel = jQuery React.findDOMNode @refs.nodes_panel
    $panel.css
      width: width
      height: height


@OEPreviewer = React.createClass
  displayName: 'OEPreviewer'
  render: ->
    @dp = new OEDataParser @props.data

    <div className='front-end-course-ware'>
      {
        for role, actions of @dp.roles
          <RoleLane role={role} actions={actions} key={role} />
      }
    </div>

  getInitialState: ->
    roles: []
    actions: []

  componentDidMount: ->
    # 画动态箭头
    role_pos = {}
    for role, actions of @dp.roles
      $lane = jQuery(".role-lane[data-role=#{role}] .lane-nodes")
      role_pos[role] = $lane.position()

    @dp.draw_animate_arrow(role_pos)


class OEDataParser
  constructor: (@data)->
    @roles = {}
    @actions = {}

    # 第一次遍历，提取角色
    for id, _action of @data.actions
      action = new OEAction _action
      role = action.role
      @roles[role] ||= []
      @roles[role].push action
      @actions[id] = action

    # 第二次遍历，提取前置后续操作
    for id, action of @actions
      for post_action_id in action.post_action_ids
        post_action = @actions[post_action_id]
        action.post_actions[post_action.id] = post_action
        post_action.pre_actions[id] = action

    # 第三次遍历，提取起始节点
    @starts = {}
    for id, action of @actions
      if Object.keys(action.pre_actions).length is 0
        @starts[id] = action

    # 第四次遍历，计算深度，计算侧偏移
    @deeps = {}
    for role, actions of @roles
      @deeps[role] = {}
    for id, action of @starts
      @_r_deep action, 0

    console.log @actions
    console.log @deeps

  _r_deep: (action, deep)->
    deep_role = @deeps[action.role]
    deep_role[deep] ||= {}

    # 当前 action 并未设置 deep
    # 直接设置 deep
    if not action.deep?
      deep_role[deep][action.id] = action
      action.deep = deep

    # 当前 action 已经设置 deep
    # 并且当前 deep < action.deep
    # 从 deep_role 中移除，再根据当前 deep 设置
    else if deep < action.deep
      delete deep_role[action.deep][action.id]
      deep_role[deep][action.id] = action
      action.deep = deep

    action.posx = Object.keys(deep_role[action.deep]).length - 1

    for id, post_action of action.post_actions
      @_r_deep post_action, deep + 1

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

    for id, action of @starts
      @_r2 action, role_pos

  _r2: (action, role_pos)->
    # 画箭头
    for id, post_action of action.post_actions
      x0 = action.css_pos().left + 60
      y0 = action.css_pos().top + 25
      x1 = post_action.css_pos().left + 60
      y1 = post_action.css_pos().top + 25

      action_offset = role_pos[action.role]
      post_action_offset = role_pos[post_action.role]

      x0 += action_offset.left
      x1 += post_action_offset.left

      @curve_arrow.draw x0, y0, x1, y1, '#999999', @arrow_offset
      @_r2 post_action, role_pos



class OEAction
  constructor: (_action)->
    @id = _action.id
    @role = _action.role
    @name = _action.name
    @post_action_ids = _action.post_action_ids || []
    @post_actions = {}
    @pre_actions = {}
    
    @deep = null
    @posx = 0

  css_pos: ->
    top = 30 + @deep * (50 + 50)
    bottom = top + 50
    left = 30 + @posx * (120 + 30)
    right = left + 120

    top: top
    left: left
    bottom: bottom
    right: right