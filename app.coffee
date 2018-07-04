data = JSON.parse Utils.domLoadDataSync "data/data.json"

# Variables
rows = data.buckets.length
gutter = 20
bucketSize = 64
padding = 20
scalefactor = 0.78

scroll = new ScrollComponent
	width: Screen.width*0.4
	height: Screen.height
	scrollHorizontal: false
	backgroundColor: "transparent"
	parent: screen_1

scroll.centerX()
scroll.mouseWheelEnabled = true
scroll.directionLock = false
scroll.content.draggable.bounce = true

focusedFrame = new Layer
	backgroundColor: "transparent"
	borderWidth: 6, borderRadius: 8, borderColor: "rgba(0,0,0,0.7)"
	width: bucketSize*1.4, height: bucketSize*1.4
	shadowBlur: 10, shadowY: 1, shadowColor: "rgba(0,0,0,0.8)"
	x: Align.center, y: Align.center
	parent: screen_1

buckets = []
activeIndex = null
numberOfVisibleBuckets = Screen.height/rows
middleObjectIndex = Math.round(rows / 2) - 1

scaleForIndex = (index) ->
	if index != middleObjectIndex
		return Math.pow scalefactor, Math.abs(middleObjectIndex - index)
	else
		return 1

middleBucket = data.buckets[middleObjectIndex]
middleBucket = new Layer
		width: bucketSize, height: bucketSize
		parent: scroll.content
		backgroundColor: middleBucket.backgroundColor
middleBucket.center(focusedFrame)
buckets[middleObjectIndex] = middleBucket

for bucket, index in data.buckets
	if index != middleObjectIndex
		sumOfHeights = 0
		if index < middleObjectIndex
			for i in [index...middleObjectIndex]
				sumOfHeights = sumOfHeights + bucketSize*scaleForIndex(i)
			yPosition = middleBucket.y - Math.abs(middleObjectIndex - index)*gutter -
			sumOfHeights
		else
			for i in [middleObjectIndex...index]
				sumOfHeights = sumOfHeights + bucketSize*scaleForIndex(i)
			yPosition = middleBucket.y + Math.abs(middleObjectIndex - index)*gutter +
			sumOfHeights

		cell = new Layer
			width: bucketSize*scaleForIndex(index) 
			height: bucketSize*scaleForIndex(index)
			y: yPosition
			parent: scroll.content
			backgroundColor: bucket.backgroundColor, opacity: scaleForIndex(index)
		
# 		cell.image = new Layer
# 			name: ".image"
# 			x: Align.center, y: Align.center
# 			width: cell.width*0.5, height: cell.height*0.5
# 			parent: cell
# 			image: Utils.randomImage()
		
		cell.centerX()
		buckets[index] = cell

scroll.onScroll() ->
	f = _.first(buckets)
	l = _.last(buckets)
	
	# Last item move to top
	if Utils.frameInFrame(f.screenFrame, screen_1.screenFrame)
		contents.content.removeChild l
		contents.content.addChild l
		
		# Update contents data
		l.update l.custom = f.custom - 1
		
		# Set y position
		l.maxY = f.y - gutter
		# Reorder list item
		buckets.unshift(buckets.pop())
		
	# First item move to bottom
	else if !Utils.frameInFrame(buckets[1].screenFrame, screen_1.screenFrame)
		contents.content.removeChild f
		contents.content.addChild f
		
		# Update contents data
		f.update f.custom = l.custom + 1
		
		# Set y position
		f.y = l.maxY + gutter
		# Reorder list item
		buckets.push(buckets.shift())
		
	