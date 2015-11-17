class @CurveArrow
  constructor: (@canvas)->
    # nothing

  clear: ->
    ctx = @canvas.getContext '2d'
    ctx.clearRect 0, 0, @canvas.width, @canvas.height

  draw: (x0, y0, x1, y1, color, offset = 0)->
    # console.log '绘制曲线箭头', [x0, y0], [x1, y1]

    ctx = @canvas.getContext '2d'
    ctx.fillStyle = color
    ctx.strokeStyle = color
    ctx.lineWidth = 2
    ctx.lineCap = 'round'

    # ctx.beginPath()
    # ctx.moveTo x0, y0
    # ctx.lineTo x1, y1
    # ctx.stroke()

    # 画 n 个箭头
    # 每隔 20 像素 一个箭头
    sidex = x1 - x0
    sidey = y1 - y0
    len = Math.sqrt Math.pow(sidex, 2) + Math.pow(sidey, 2)

    gap = 10

    for idx in [0..~~(len / gap)]
      # 画箭头尖角

      # # 根据 offset 计算实际起始位置
      offset_idx = idx * gap + offset % (gap * 2)
      offix = sidex * offset_idx / len
      offiy = sidey * offset_idx / len

      xp = x0 + offix
      yp = y0 + offiy

      # ang = Math.atan sidey / sidex
      ang = Math.atan2 sidey, sidex
      # console.log x0, y0, x1, y1
      # console.log y1 - y0, x1 - x0
      # console.log ang / Math.PI * 180

      if idx % 2 is 1
        ctx.fillStyle = '#999999'
      else
        ctx.fillStyle = '#cccccc'

      # 箭头侧翼长度
      hx = 10
      ctx.lineWidth = 2
      ctx.save()
      ctx.translate xp, yp
      ctx.rotate ang
      ctx.beginPath()
      ctx.moveTo 0, 0
      ctx.lineTo -hx, -hx / 2
      ctx.lineTo -hx * 0.6, 0
      ctx.lineTo -hx, hx / 2
      ctx.lineTo 0, 0
      ctx.fill()
      # ctx.stroke()
      ctx.restore()


class @CurveArrowA
  constructor: (@canvas)->
    # nothing

  clear: ->
    ctx = @canvas.getContext '2d'
    ctx.clearRect 0, 0, @canvas.width, @canvas.height

  draw: (x0, y0, x1, y1, color, offset = 0)->
    # console.log '绘制曲线箭头', [x0, y0], [x1, y1]

    ctx = @canvas.getContext '2d'
    ctx.fillStyle = color
    ctx.strokeStyle = color
    ctx.lineWidth = 2
    ctx.lineCap = 'round'

    # ctx.beginPath()
    # ctx.moveTo x0, y0
    # ctx.lineTo x1, y1
    # ctx.stroke()

    # 画 n 个箭头
    # 每隔 20 像素 一个箭头
    sidex = x1 - x0
    sidey = y1 - y0
    len = Math.sqrt Math.pow(sidex, 2) + Math.pow(sidey, 2)

    gap = 10

    for idx in [0..~~(len / gap)]
      # 画箭头尖角

      # # 根据 offset 计算实际起始位置
      offset_idx = idx * gap + offset % (gap * 2)
      offix = sidex * offset_idx / len
      offiy = sidey * offset_idx / len

      xp = x0 + offix
      yp = y0 + offiy

      # ang = Math.atan sidey / sidex
      ang = Math.atan2 sidey, sidex
      # console.log x0, y0, x1, y1
      # console.log y1 - y0, x1 - x0
      # console.log ang / Math.PI * 180

      if idx % 2 is 1
        ctx.fillStyle = '#444444'
      else
        ctx.fillStyle = '#bbbbbb'

      # 箭头侧翼长度
      hx = 10
      ctx.lineWidth = 2
      ctx.save()
      ctx.translate xp, yp
      ctx.rotate ang
      ctx.beginPath()
      ctx.moveTo 0, 0
      ctx.lineTo -hx, -hx / 2
      ctx.lineTo -hx * 0.6, 0
      ctx.lineTo -hx, hx / 2
      ctx.lineTo 0, 0
      ctx.fill()
      # ctx.stroke()
      ctx.restore()
