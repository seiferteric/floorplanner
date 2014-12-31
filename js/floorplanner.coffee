
oldStates = []
skipSave = false
saveState = (c) ->
  existingState = JSON.parse(localStorage.getItem("existingState"))
  if !existingState
    existingState = []
  if !skipSave
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
  
jQuery ->
    
  canvas = new fabric.Canvas('c', {
   backgroundColor: 'rgb(255, 255, 255)',
  })

  canvas.setWidth($(window).width()*.9)
  canvas.setHeight($(window).height())

  loadState(canvas)

  $('#line').click (d) ->
    canvas.add(new fabric.Line([10, 0, 10, 100], { fill: 'red', stroke: 'red', strokeWidth: 10 }))
    
  $('#circle').click (d) ->
    canvas.add(new fabric.Circle({ radius: 30, fill: '#f55', top: 100, left: 100 }))

  $('#rectangle').click (d) ->
    canvas.add(new fabric.Rect({ left: 100, top: 100, width: 100, height: 100, fill: '#f55' }))

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
  canvas.on 'object:removed', (d) ->
    saveState(canvas)
  canvas.on 'object:modified', (d) ->
    saveState(canvas)

  $(document).keydown (e) ->
    if e.which == 90 && e.ctrlKey && e.shiftKey
       redoState(canvas)
    else if e.which == 90 && e.ctrlKey
       undoState(canvas)

