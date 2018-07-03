data = JSON.parse Utils.domLoadDataSync "data/data.json"

# Variables
rows = data.buckets.length
gutter = 10
bucketSize = 64
padding = 20
scalefactor = 0.8

scroll = new ScrollComponent
	width: Screen.width*0.4
	height: Screen.height
	scrollHorizontal: false
	backgroundColor: "rgba(255,255,255,0)"
	parent: screen_1
# 	contentInset: 
# 		top: padding

scroll.centerX()
scroll.mouseWheelEnabled = true

focusedFrame = new Layer
	backgroundColor: "rgba(255,255,255,0)"
	borderColor: "rgba(0,0,0,0.7)"
	borderWidth: 6
	borderRadius: 8
	width: bucketSize*1.4
	height: bucketSize*1.4
	shadowBlur: 10
	shadowY: 1
	shadowColor: "rgba(0,0,0,0.8)"

focusedFrame.center()
focusedFrame.parent = screen_1


cells = []
activeIndex = null
numberOfVisibleBuckets = Screen.height/rows
middleObjectIndex = Math.round(rows / 2) - 1

scaleForIndex = (index) ->
	if index < middleObjectIndex
		scale =  Math.pow scalefactor, middleObjectIndex - index
	else if index > middleObjectIndex
		scale =  Math.pow scalefactor, index - middleObjectIndex
	else
		scale = 1
	return scale	

previousYPosition = gutter

middleBucket = data.buckets[middleObjectIndex]
middleBucket = new Layer
		width:  bucketSize
		height: bucketSize
		parent: scroll.content
		backgroundColor: middleBucket.backgroundColor
middleBucket.center(focusedFrame)

for bucket, index in data.buckets
	previousBucketSize = if index > 0 then bucketSize*scaleForIndex(index-1) else 0
	cell = new Layer
		width:  bucketSize*scaleForIndex(index)
		height: bucketSize*scaleForIndex(index)
		y: if index > 0 then previousYPosition + previousBucketSize + gutter else gutter
		parent: scroll.content
		backgroundColor: bucket.backgroundColor
		opacity: scaleForIndex(index)
	
	cell.centerX()
	cells.push(cell)
	
	previousYPosition = cell.y