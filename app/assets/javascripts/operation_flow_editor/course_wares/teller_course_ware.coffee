@TellerCourseWare = React.createClass
  render: ->
    window.screens = @props.data.screens

    <div className='teller-course-ware'>
      <TellerCourseWare.Sidebar data={@baseinfo()} />
      <TellerCourseWare.Panel data={@actioninfo()} />
    </div>

  baseinfo: ->
    @props.data.baseinfo || {}

  actioninfo: ->
    @props.data.actioninfo || {}

  statics:
    Sidebar: React.createClass
      render: ->
        data = @props.data

        <div className='sidebar'>
          <div className='item base'>
            <div className='number'>{data.number}</div>
            <div className='name'>{data.name}</div>
          </div>
          <div className='item roles'>
            <label>参与角色</label>
            <div className='role teller'>柜员</div>
            <div className='role customer'>客户</div>
          </div>
          <div className='item complex'>
            <label>复杂度</label>
            <div className='c low'>低</div>
          </div>
          <div className='item desc'>
            <label>交易概述</label>
            {data.desc}
          </div>
          <div className='item qn'>
            <a className='ibtn question-btn' href='javascript:;'>
              <i className='fa fa-question-circle' />
            </a>
            <a className='ibtn note-btn' href='javascript:;'>
              <i className='fa fa-pencil-square' />
            </a>
          </div>
          <div className='item play'>
            <a className='ibtn play-btn' href='javascript:;'>
              <i className='fa fa-play' />
            </a>
            <a className='ibtn pause-btn' href='javascript:;'>
              <i className='fa fa-pause' />
            </a>
          </div>
        </div>

    Panel: React.createClass
      render: ->
        <div className='paper'>
          <OEP data={@props.data} />
        </div>



# ----------------



OEP = React.createClass
  displayName: 'OEPreviewer'
  getInitialState: ->
    graph: new OEActionsGraph @props.data

  render: ->
    <div className='flow-course-ware'>
      <OEP.Header data={@state.graph} />
      <OEP.Nodes oep={@} data={@state.graph} />
      <OEP.TeachingDialog oep={@} ref='dialog' data={@state.graph} />
      <OEP.ScreenShower oep={@} ref='screen_shower' />
    </div>

  componentDidMount: ->
    @change_arrows()

    for id, action of @state.graph.actions
      if action.is_start()
        @focus_action action
        break

    for id, action of @state.graph.actions
      if action.is_start()
        @_r action, 0
        break

  _r: (action, idx)->
    action.idx = idx
    # console.log @props.data
    action.desc = @props.data.action_desc[idx]

    idx += 1
    for id, post_action of action.post_actions
      @_r post_action, idx

  change_arrows: ->
    # 画动态箭头
    role_pos = {}
    for role, actions of @state.graph.roles
      $lane = jQuery(".role-actions[data-role=#{role}]")
      role_pos[role] = $lane.position()

    @state.graph.draw_animate_arrow(role_pos)

  focus_action: (action)->
    @refs.dialog.show action

    jQuery('.action-node').removeClass('focus')
    jQuery(".action-node[data-id=#{action.id}]").addClass('focus')

  show_screen: (action)->
    @refs.screen_shower.show action

  statics:
    Header: React.createClass
      displayName: 'OEP.Header'
      render: ->
        <div className='header'>
          {
            for role in ['客户', '柜员']
              if @props.data.roles[role]?
                <div key={role} className='role'>角色：{role}</div>
                
          }
        </div>

    Nodes: React.createClass
      displayName: 'OEP.Nodes'
      render: ->
        <div className='nodes'>
          <div className='nbox'>
          <canvas className='ncanvas' />
          {
            for role in ['客户', '柜员']
              if (role_actions = @props.data.roles[role])?
                <OEP.RoleActions oep={@props.oep} key={role} role={role} data={role_actions} />
          }
          </div>
        </div>

    RoleActions: React.createClass
      displayName: 'OEP.RoleActions'
      render: ->
        @bottom = 0
        @right = 0

        <div ref='panel' data-role={@props.role} className='role-actions'>
          {
            for id, action of @props.data
              pos = action.css_pos()
              @bottom = Math.max @bottom, pos.bottom
              @right = Math.max @right, pos.right

              <OEP.Action oep={@props.oep} key={id} data={action} />
          }
        </div>

      componentDidMount: ->
        @update_size()

      componentDidUpdate: ->
        @update_size()

      update_size: ->
        # 设置宽高
        $panel = jQuery React.findDOMNode @refs.panel
        $panel.css
          width: @right + OEAction.CSS_GAP
          height: @bottom + OEAction.CSS_GAP


    Action: React.createClass
      displayName: 'OEP.Action'
      render: ->
        action = @props.data
        pos = action.css_pos()
        style = 
          left: "#{pos.left}px"
          top: "#{pos.top}px"
          width: "#{OEAction.CSS_WIDTH}px"
          height: "#{OEAction.CSS_HEIGHT}px"
        klass = ['action-node']

        <div className={klass.join(' ')} data-role={action.role} data-deep={action.deep} style={style} data-id={action.id} onClick={@do_click}>
          <div className='box'>
            <div className='name'>{action.name}</div>
            {
              if action.screen_ids.length
                <div className='has-screen'>
                  <i className='fa fa-desktop' />
                  <span className='count'>{action.screen_ids.length}</span>
                </div>
            }
          </div>
        </div>

      do_click: (evt)->
        @props.oep.focus_action @props.data


    TeachingDialog: React.createClass
      getInitialState: ->
        action: {}

      render: ->
        action = @state.action

        if Object.keys(action).length
          @prev_keys = Object.keys(action.pre_actions)
          @next_keys = Object.keys(action.post_actions)

          @has_prev = @prev_keys.length
          @has_next = @next_keys.length

          @has_screen = action.screen_ids?.length

        klass = ['teaching-dialog']
        klass.push 'has-screen' if @has_screen

        <div className={klass.join(' ')}>
          <div ref='box'>
            <div className='action-name'>
              <span className='ct'>{action.name}</span>
            </div>
            {
              if @has_screen
                <div className='has-screen ct'>
                  <div className='desc'>这个步骤需要通过柜员机屏幕进行操作</div>
                  <a className='btn btn-success btn-sm' href='javascript:;' onClick={@open_screen}>
                    <i className='fa fa-desktop' />
                    <span>学习屏幕操作</span>
                  </a>
                </div>
            }
            <pre className='action-desc ct'>{action.desc}</pre>

            <div className='nav'>
              <a href='javascript:;' onClick={@focus_prev}><i className='fa fa-chevron-left'/>上一步</a>
              <a href='javascript:;' onClick={@focus_next}>下一步<i className='fa fa-chevron-right'/></a>
            </div>
          </div>
        </div>

      show: (action)->
        $box = jQuery React.findDOMNode @refs.box
        $box.find('.ct').fadeOut 100, =>
          @setState action: action

      componentDidUpdate: ->
        $box = jQuery React.findDOMNode @refs.box
        $box.find('.ct').fadeIn(100)

      focus_prev: ->
        if @has_prev
          @props.oep.focus_action @state.action.pre_actions[@prev_keys[0]]

      focus_next: ->
        if @has_next
          @props.oep.focus_action @state.action.post_actions[@next_keys[0]]

      open_screen: ->
        @props.oep.show_screen @state.action


    ScreenShower: React.createClass
      getInitialState: ->
        screen_data: null
      render: ->
        <div className='screen-shower'>
        <BSModal.FormModal ref='modal' title='操作说明' bs_size='lg' >
        <pre className='screen-desc'>{@state.screen_desc}</pre>
        {
          if @state.screen_data?
            <OFCTellerScreen data={@state.screen_data} />
        }
        </BSModal.FormModal>
        </div>

      show: (action)->
        screen_id = action.screen_ids[0]
        screen_data = (@props.oep.props.data.screens.filter (x)->
          x.hmdm == screen_id)[0]

        screen_desc = @props.oep.props.data.screens_desc[action.idx]

        if screen_data?
          @setState 
            screen_data: screen_data
            screen_desc: screen_desc

        @refs.modal.show()

# -------------------------------------
# 以下是非 ReactJS 的类，用于数据解析
# 和课程编辑器中的类应该复用，将来重构



class OEActionsGraph
  constructor: (raw_data)->
    @roles = {}
    @actions = {}

    # 第一次遍历，实例化 action 对象
    # 分角色提取 action 集合
    for id, _action of raw_data.actions
      action = new OEAction _action, @
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
      offset_deep = offset_deep + sub_graph.max_deep + 1

    # 课件绘制的补充需求
    # 再次遍历所有子图，计算节点视觉深度值（vdeep）
    # 以达到更美观紧凑的显示
    for sub_graph in @sub_graphs
      sub_graph.compute_vdeep()


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
      # console.log @arrow_offset
      @draw_animate_arrow role_pos

  draw_arrow: (role_pos)->
    $ncanvas = jQuery('canvas.ncanvas')
    $nbox = jQuery('.nbox')

    if not @curve_arrow?
      $ncanvas
        .attr 'width', $nbox.width()
        .attr 'height', $nbox.height()

      @curve_arrow = new CurveArrowA $ncanvas[0]

    @curve_arrow.clear()

    for id, action of @actions
      if action.is_start()
        @_r_arrow action, role_pos

  _r_arrow: (action, role_pos)->
    # 画箭头
    for id, post_action of action.post_actions
      x0 = action.css_pos().left + OEAction.CSS_WIDTH / 2
      y0 = action.css_pos().top + OEAction.CSS_HEIGHT / 2
      x1 = post_action.css_pos().left + OEAction.CSS_WIDTH / 2
      y1 = post_action.css_pos().top + OEAction.CSS_HEIGHT / 2

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

  compute_vdeep: ->
    for id, action of @actions
      if action.is_start()
        @_rv action

  _rv: (action)->
    @_adjust_vdeep action

    for id, post_action of action.post_actions
      @_rv post_action

  _adjust_vdeep: (action)->
    action.vdeep = action.deep
    same_role_deep_actions = @deeps[action.role][action.deep]
    
    # 没有同角色的同深度节点时才需要调整
    return if Object.keys(same_role_deep_actions).length > 1

    # 有父节点时才需要调整
    return if Object.keys(action.pre_actions).length == 0
    
    # 获取所有父节点的最大深度
    max_pre_vdeep = 0
    for id, pre_action of action.pre_actions
      max_pre_vdeep = Math.max max_pre_vdeep, pre_action.vdeep

    # 获取同角色节点的小于当前节点的最大深度
    _actions = (_action for id, _action of @actions).filter (x)->
      x.vdeep < action.deep and x.role == action.role
    max_same_role_vdeep = -1
    for _action in _actions
      max_same_role_vdeep = Math.max max_same_role_vdeep, _action.vdeep

    # console.log action.name, max_pre_vdeep, max_same_role_vdeep
    action.vdeep = Math.max max_pre_vdeep, max_same_role_vdeep + 1


class OEAction
  @CSS_WIDTH: 180
  @CSS_HEIGHT: 70
  @CSS_GAP: 30

  constructor: (_action, @graph)->
    @id = _action.id
    @role = _action.role
    @name = _action.name
    @post_action_ids = _action.post_action_ids || []
    @post_actions = {}
    @pre_actions = {}
    @screen_ids = _action.linked_screen_ids || []

    @deep = null
    @offset = 0

  is_start: ->
    Object.keys(@pre_actions).length is 0

  is_end: ->
    Object.keys(@post_actions).length is 0

  css_pos: ->
    top = 
      OEAction.CSS_GAP + 
      # (@deep + @sub_graph.offset_deep) * 
      (@vdeep + @sub_graph.offset_deep) * 
      (OEAction.CSS_HEIGHT + OEAction.CSS_GAP)
    
    bottom = top + OEAction.CSS_HEIGHT
    left = OEAction.CSS_GAP + @offset * (OEAction.CSS_WIDTH + OEAction.CSS_GAP)
    right = left + OEAction.CSS_WIDTH

    top: top
    left: left
    bottom: bottom
    right: right