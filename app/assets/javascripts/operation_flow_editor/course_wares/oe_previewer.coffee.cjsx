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
    action = @props.action
    pos = action.css_pos()
    klass = ['action-node']
    klass.push ['start'] if action.is_start()
    klass.push ['end'] if action.is_end()

    <div className={klass.join(' ')} style={{left: "#{pos.left}px", top: "#{pos.top}px"}}>
      <div className='name'>{@props.action.name}</div>
    </div>


RoleLane = React.createClass
  displayName: 'RoleLane'
  render: ->
    <div className='role-lane' data-role={@props.role}>
      <div className='lane-header'>角色：{@props.role}</div>
      <div className='lane-nodes' ref='nodes_panel'>
        {
          for id, action of @props.actions
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
  getInitialState: ->
    graph: new OEActionsGraph @props.data

  render: ->
    <div className='front-end-course-ware'>
      <canvas></canvas>
      {
        for role, actions of @state.graph.roles
          <RoleLane role={role} actions={actions} key={role} />
      }
    </div>

  componentDidMount: ->
    # 画动态箭头
    role_pos = {}
    for role, actions of @state.graph.roles
      $lane = jQuery(".role-lane[data-role=#{role}] .lane-nodes")
      role_pos[role] = $lane.position()

    @state.graph.draw_animate_arrow(role_pos)



class OEActionsGraph
  constructor: (raw_data)->
    @roles = {}
    @actions = {}

    # 第一次遍历，实例化 action 对象
    # 分角色提取 action 集合
    for id, _action of raw_data.actions
      action = new OEAction _action
      role = action.role
      @roles[role] ||= {}
      @roles[role][action.id] = action
      @actions[id] = action

    # 第二次遍历，给每个 action 对象的前置后续操作赋值
    for id, action of @actions
      for post_action_id in action.post_action_ids
        post_action = @actions[post_action_id]
        action.post_actions[post_action.id] = post_action
        post_action.pre_actions[action.id] = action

    # 第三次遍历，划分子连通图
    @sub_graphs = []
    for id, action of @actions
      sub_graph = new OEActionsSubGraph
      @_r_sub_graph action, sub_graph
      @sub_graphs.push sub_graph if not sub_graph.is_empty()

    # 分别遍历各个子图
    # 计算各个节点深度值 (deep)
    # 和偏移值 (offset)
    offset_deep = 0
    for sub_graph in @sub_graphs
      sub_graph.offset_deep = offset_deep
      sub_graph.compute()
      offset_deep = sub_graph.max_deep + 1

  _r_sub_graph: (action, sub_graph)->
    return if action.sub_graph?
    action.sub_graph = sub_graph
    sub_graph.add(action)
    for id, pre_action of action.pre_actions
      @_r_sub_graph pre_action, action.sub_graph
    for id, post_action of action.post_actions
      @_r_sub_graph post_action, action.sub_graph

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
      $canvas = $cwel.find('canvas')
        .attr 'width', width
        .attr 'height', height
      @curve_arrow = new CurveArrow $canvas[0]

    @curve_arrow.clear()

    for id, action of @actions
      if action.is_start()
        @_r_arrow action, role_pos

  _r_arrow: (action, role_pos)->
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
      @_r_arrow post_action, role_pos



class OEActionsSubGraph
  constructor: ->
    @actions = {}
    @offset_deep = 0
    @max_deep = 0

  add: (action)->
    @actions[action.id] = action

  is_empty: ->
    Object.keys(@actions).length is 0

  compute: ->
    @deeps = {}
    for id, action of @actions
      if action.is_start()
        @_r action, 0

    for role, role_deeps of @deeps
      for deep, actions of role_deeps
        idx = 0
        for id, action of actions
          action.offset = idx
          idx += 1

  _r: (action, deep)->
    deep_role = @deeps[action.role] ||= {}

    if not action.deep?
      action.deep = deep
      deep_role[deep] ||= {}
      deep_role[deep][action.id] = action

    if deep > action.deep
      delete deep_role[action.deep][action.id]
      action.deep = deep
      deep_role[deep] ||= {}
      deep_role[deep][action.id] = action

    @max_deep = action.deep if action.deep > @max_deep
    for id, post_action of action.post_actions
      @_r post_action, deep + 1



class OEAction
  constructor: (_action)->
    @id = _action.id
    @role = _action.role
    @name = _action.name
    @post_action_ids = _action.post_action_ids || []
    @post_actions = {}
    @pre_actions = {}
    
    @deep = null
    @offset = 0

  is_start: ->
    Object.keys(@pre_actions).length is 0

  is_end: ->
    Object.keys(@post_actions).length is 0

  css_pos: ->
    top = 30 + (@deep + @sub_graph.offset_deep) * (50 + 30)
    bottom = top + 50
    left = 30 + @offset * (120 + 30)
    right = left + 120

    top: top
    left: left
    bottom: bottom
    right: right