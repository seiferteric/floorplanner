

saveState = (c) ->
  existingState = JSON.parse(localStorage.getItem("currentState"))
  if !existingState
    existingState = []
  existingState.push c
  localStorage.setItem("currentState", JSON.stringify(existingState))

loadState = (c) ->
  existingState = JSON.parse(localStorage.getItem("currentState"))
  console.log existingState
  if existingState
    c.loadFromJSON existingState[existingState.length - 1]

  
  
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
  $('#save').click (d) ->
    download = (url,name) ->
        $('<a>').attr({href:url,download:name})[0].click()
    download(canvas.toDataURL(),'floorplan.png')



  canvas.on 'object:added', (d) ->
    saveState(canvas)
  canvas.on 'object:removed', (d) ->
    saveState(canvas)
  canvas.on 'object:modified', (d) ->
    saveState(canvas)
