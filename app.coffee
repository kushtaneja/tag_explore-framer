data = JSON.parse Utils.domLoadDataSync "data/data.json"

# Variables
rows = data.buckets.length
gutter = 20
bucketSize = 64
# gutte r = bucketSize*.4
tagWidthRatio = 0.153
padding = 20
scalefactor = 0.78
borderRadius = 8

scroll = new ScrollComponent
	x: Align.right
	width: Screen.width*0.4
	height: Screen.height
	scrollHorizontal: false
	backgroundColor: "transparent"
	parent: screen_1

# scroll.centerX()
scroll.mouseWheelEnabled = true
scroll.directionLock = false
scroll.content.draggable.bounce = true

class Bucket extends Layer
	constructor: (@options={}) ->
		@options.width ?= bucketSize
		@options.height ?= bucketSize
		@options.parent = scroll.content
		@options.borderRadius = borderRadius
		@options.scale ?= 1
		
		
		
		@thumbnail = new Layer
			width: @options.width*0.6
			height: @options.height*0.6
			borderRadius:  borderRadius

		super @options
		
		@thumbnail.parent = @
		@thumbnail.center()
		@thumbnail.backgroundColor = "white"
		
		@onClick ->
			scroll.scrollToPoint(Utils.frameCenterPoint(@.frame))

class bucketDetail extends Layer
	constructor: (@options={}) ->
		@options.width = Screen.width*0.6
		@options.y = scroll.y + 2*padding
		@options.x = Align.left(padding)
		@options.borderRadius = borderRadius
		@options.backgroundColor = "transparent"
		@options.borderWidth = 6
		@options.borderColor = "rgba(0,0,0,0)"
		@options.shadowBlur = 6
		@options.shadowY = 1
		@options.shadowColor = "gray"
		@options.clip = true
		
		@bucket = new Bucket
		
		@tittle = new TextLayer
			fontSize: 24
				
			
		super @options
		
		@bucket.parent = @
		@bucket.x = 0.2*bucketSize
		@bucket.y = 0.2*bucketSize
		
		@tittle.parent = @
		@tittle.x = @bucket.x + @bucket.width + padding
		@tittle.y = @bucket.y + (@bucket.height-@tittle.height)/2
		@tittle.text = ""
		


focusBucketDetailView = new bucketDetail
	parent: screen_1
focusBucketDetailView.height =  bucketSize*1.4

tags = [0...10]
tagLayers = []
tagsContainer = new ScrollComponent
	width: Screen.width*0.6, height: scroll.height
	y: scroll.y + 2*padding + focusBucketDetailView.height
tagsContainer.parent = screen_1
tagsContainer.scrollHorizontal = false
tagsContainer.content.backgroundColor = "transparent"
tagsContainer.backgroundColor = "transparent"
tagsContainer.mouseWheelEnabled = true
tagsContainer.visible = true
tagsContainer.content.clip = false
tagsContainer.contentInset = 
		left: padding
		top: padding
		bottom: padding
	
	
class Tag extends Layer
	constructor: (@options={}) ->
		@options.height = @options.width*tagWidthRatio
		@options.backgroundColor = "#E6E6E6"
		@options.borderRadius = borderRadius
		
		@label = new TextLayer
			autoSize: true
			x: Align.left(padding), y: Align.center
			fontSize: 16
			name: ".label"
		
		@trendLabel = new TextLayer
			fontSize: 12
			autoSize: true
			name: ".trendLabel"
			
		@trendIcon = new Layer
			width: 1.83*0.4*@options.height, height: 0.4*@options.height
			y: Align.center

			
		super @options
		
		
		@label.parent = @
		@label.centerY()
		@label.backgroundColor = "transparent"
		
		@trendLabel.parent = @
		@trendLabel.centerY()
		@trendLabel.x = @options.width - 50
		@trendLabel.backgroundColor = "transparent"
		
		@trendIcon.parent = @
		@trendIcon.centerY()
		@trendIcon.x = @trendLabel.x - 2*padding
		@trendIcon.image = "images/trend.png"
		
		
	
for tagObject, tagIndex in tags
	tagLayer = new Tag
		width: tagsContainer.content.width*0.84
	tagLayer.parent = tagsContainer.content
	tagLayer.centerX() 
	tagLayer.y = tagIndex*(tagLayer.height + padding)
	tagLayer.label.text = ""
	tagLayer.trendLabel.text = ""	
	tagLayer.visible = false
	tagLayers.push(tagLayer)	

focusedFrame = new Layer
	backgroundColor: "transparent"
	borderWidth: 6, borderRadius: borderRadius, borderColor: "rgba(0,0,0,0)"
	width: bucketSize*1.4, height: bucketSize*1.4
	shadowBlur: 6, shadowY: 1, shadowColor: "gray"
	x: Align.center, y: Align.center
	parent: scroll

focusedFrame.center()	
centerFrame = focusedFrame.screenFrame
centerPoint = Utils.frameCenterPoint(centerFrame)

buckets = []
activeIndex = null
numberOfVisibleBuckets = Screen.height/rows
middleObjectIndex = Math.round(rows / 2) - 1
scaleForIndex = (index) ->
	if index != middleObjectIndex
		return Math.pow scalefactor, Math.abs(middleObjectIndex - index)
	else
		return 1

middleBucketData = data.buckets[middleObjectIndex]
middleBucket = new Bucket
	backgroundColor: middleBucketData.backgroundColor
middleBucket.center(focusedFrame)
middleBucket.name = middleBucketData.name
middleBucket.tags = middleBucketData.tags
buckets[middleObjectIndex] = middleBucket
focusedBuckett = middleBucket

for bucket, index in data.buckets
	if index != middleObjectIndex
		sumOfHeights = 0
		if index < middleObjectIndex
			for i in [index...middleObjectIndex]
				sumOfHeights = sumOfHeights + bucketSize
			yPosition = middleBucket.y - Math.abs(middleObjectIndex - index)*gutter -
			sumOfHeights
		else
			for i in [middleObjectIndex...index]
				sumOfHeights = sumOfHeights + bucketSize
			yPosition = middleBucket.y + Math.abs(middleObjectIndex - index)*gutter +
			sumOfHeights
		
		scale = Math.pow scalefactor, Math.abs(middleObjectIndex - index)
		cell = new Bucket
			name: "bucket #{index+1}"
			y: yPosition
			backgroundColor: bucket.backgroundColor, opacity: scaleForIndex(index)
			scale: if index != middleObjectIndex then scale else 1
		cell.gutter = scale*gutter
		
		cell.centerX()
		cell.tags = bucket.tags
		buckets[index] = cell
		
		scroll.contentInset =
			top: focusedFrame.screenFrame.y - 0.4*bucketSize
			bottom: focusedFrame.screenFrame.y - 0.4*bucketSize


scroll.scrollToPoint(centerPoint)

scroll.onMove ->
	if focusedBucket = (bucket for bucket in buckets when Utils.frameInFrame(bucket.screenFrame, focusedFrame.screenFrame))[0]
		focusedBuckett = focusedBucket
		focusedBucketIndex = buckets.indexOf(focusedBucket)
		focusBucketDetailView.bucket.backgroundColor = focusedBucket.backgroundColor
		focusBucketDetailView.bucket.thumbnail.backgroundColor = focusedBucket.thumbnail.backgroundColor
		focusBucketDetailView.tittle.text = focusedBuckett.name
		for tagLay in tagLayers
			tagLay.visible = false 
		
		for tagObject, tagIndex in focusedBucket.tags when tagIndex < tags.length
			tagLayer = tagLayers[tagIndex]
			tagLayer.label.text = tagObject.name
			tagLayer.trendLabel.text = tagObject.trend	
			tagLayer.visible = true	

		for bucket, index in buckets 
			scale = Math.pow scalefactor, Math.abs(focusedBucketIndex - index)
			
# 			if scale < 1
# 				diffY = ((1 - scale)*bucket.height)/2
# 				
# 				bucket.y = if focusedBucketIndex > index then bucket.screenFrame.y - diffY else if focusedBucketIndex < index then bucket.screenFrame.y + diffY 
				
			bucket.scale = if index != focusedBucketIndex then scale else 1				
			bucket.opacity = if index != focusedBucketIndex then scale else 1

scroll.onScrollEnd ->	
# 		scroll.scrollToPoint(centerPoint)



