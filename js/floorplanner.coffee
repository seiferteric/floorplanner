
oldStates = []
skipSave = false


object_types = {
  'Circle': [{ radius: 30, fill: 'black', top: 100, left: 100, fill: 'lightblue', stroke: 'black', strokeWidth: 5 }], 
  'Line': [[10, 0, 10, 100], { fill: 'black', stroke: 'black', strokeWidth: 10 }], 
  'Rect': [{ left: 100, top: 100, width: 100, height: 100, fill: 'lightblue', stroke: 'black', strokeWidth: 5 }], 
  'Triangle': [{fill: 'lightblue', stroke: 'black', strokeWidth: 5}], 
  'Ellipse': [{top: 100, left: 100, rx: 100, ry: 75, fill: 'lightblue', stroke: 'black', strokeWidth: 5 }], 
  # 'Polyline': [{}], 
  # 'Polygon': [{}], 
  # 'Text': [{}], 
  # 'Image': [{}], 
  # 'Path': [{}]
}

saveState = (c) ->
  existingState = JSON.parse(localStorage.getItem("existingState"))
  if !existingState
    existingState = []
  if !skipSave && JSON.stringify(c) != existingState[existingState.length - 1]
    existingState.push JSON.stringify(c)
    localStorage.setItem("existingState", JSON.stringify(existingState))
    oldStates = []

loadState = (c) ->
  existingState = JSON.parse(localStorage.getItem("existingState"))
  if existingState && existingState.length > 0
    skipSave = true
    c.loadFromJSON JSON.parse(existingState[existingState.length - 1]), -> skipSave = false

undoState = (c) ->
  existingState = JSON.parse(localStorage.getItem("existingState"))
  
  if existingState && existingState.length > 0
    oldStates.push existingState.pop()
    if existingState.length > 0
      skipSave = true
      c.loadFromJSON JSON.parse(existingState[existingState.length - 1]), -> skipSave = false
    else
      c.clear()
    localStorage.setItem("existingState", JSON.stringify(existingState))

redoState = (c) ->
  existingState = JSON.parse(localStorage.getItem("existingState"))

  if !existingState
    existingState = []
  if oldStates.length > 0
    existingState.push oldStates.pop()
    localStorage.setItem("existingState", JSON.stringify(existingState))
    loadState(c)

clearState = (c) ->
  localStorage.removeItem("existingState")
  c.clear()
  oldStates = []

removeItem = (c) ->
  obj = c.getActiveObject()
  grp = c.getActiveGroup()
  c.remove obj
  grp.forEachObject (o) ->
    c.remove o
    c.discardActiveGroup().renderAll()
  saveState(c)
  
zupItem = (c) ->
  obj = c.getActiveObject()
  obj.bringForward()
zdownItem = (c) ->
  obj = c.getActiveObject()
  obj.sendBackwards()

initTools = (c) ->
  for tn,defo of object_types
    $('#tools #shapes').append "<button class='btn btn-warning' id='#{tn}'>#{tn}</button>"

    $("##{tn}").click [tn, defo], (t) -> 
      nobj = new fabric[t.data[0]](t.data[1]...)
      c.add nobj

loadProperties = (c) ->
  obj = c.getActiveObject()
  if !obj
    unloadProperties(c)
    return
  $('#tools #properties').append("<label for='fill'>Fill</label><input id='fill' type='text' class='colorPicker' value='#{obj.fill}' />")
  $('#fill').colorpicker().on 'changeColor', (e) ->
    obj.setFill($(e.currentTarget).val())
    c.renderAll()
  $('#tools #properties').append("<label for='stroke'>Stroke</label><input id='stroke' type='text' class='colorPicker' value='#{obj.stroke}' />")
  $('#stroke').colorpicker().on 'changeColor', (e) ->
    obj.setStroke($(e.currentTarget).val())
    c.renderAll()
  $('#tools #properties').append("<label for='strokewidth'>Stroke Width</label><input id='strokewidth' type='number' value='#{obj.strokeWidth}' />")
  $('#strokewidth').on 'change', (e) ->
    obj.setStrokeWidth(parseInt($(e.currentTarget).val()))
    c.renderAll()

unloadProperties = (c) ->
  saveState(c)
  $('#tools #properties').html("")
jQuery ->
    
  
  canvas = new fabric.Canvas('c', {
   backgroundColor: 'rgb(255, 255, 255)',
  })
  initTools(canvas)

  canvas.setWidth($(window).width())
  canvas.setHeight($(window).height() - $('#tools').outerHeight())

  loadState(canvas)

  $("#clear").click (d) ->
    canvas.clear()
    saveState(canvas)
  $('#clearall').click (d) ->
    clearState(canvas)
  $('#save').click (d) ->
    download = (url,name) ->
        $('<a>').attr({href:url,download:name})[0].click()
    download(canvas.toDataURL(),'floorplan.png')

  $('#undo').click (d) ->
    undoState(canvas)
  $('#redo').click (d) ->
    redoState(canvas)


  canvas.on 'object:added', (d) ->
    saveState(canvas)
  canvas.on 'object:modified', (d) ->
    saveState(canvas)
  canvas.on 'object:selected', (d) ->
    loadProperties(canvas)
  canvas.on 'before:selection:cleared', (d) ->
    unloadProperties(canvas)
  canvas.on 'selection:cleared', (d) ->
    unloadProperties(canvas)


  $(document).keydown (e) ->
    if e.which == 90 && e.ctrlKey && e.shiftKey
       redoState(canvas)
    else if e.which == 90 && e.ctrlKey
       undoState(canvas)
    else if e.which == 46
      removeItem(canvas)
    else if e.which == 33
      zupItem(canvas)
    else if e.which == 34
      zdownItem(canvas)

