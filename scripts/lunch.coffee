cron = require('cron').CronJob
room = process.env.HUBOT_IRC_ROOMS
prefix = 'lunch'

module.exports = (robot) ->
	robot.enter ->
	new cron
		cronTime: "0 2 13 * * *"
		start: true
		timeZone: "Asia/Tokyo"
		onTick: ->
			robot.send {room: room}, "昼飯時です！"
			showRecommend()
			#shops = robot.brain.data.shop
			#for k,v of shops
		 #		jd = "#{v.date.getMonth()+1}月#{v.date.getDate()}日"
		 # 	robot.send {room: room}, "#{k} #{jd}"

	robot.hear /lunch test/, (msg) ->
		robot.send {room: room}, "#{room}"
		shops = robot.brain.data.shop
		showRecommend()

	robot.hear /lunch add\s+(\S+)\s*(.*)/, (msg) ->
		shopName = msg.match[1]
		params = msg.match[2].split(/\s/)

		po = {}
		for p in params
			kv = p.split(':')
			po[kv[0]] = kv[1] if kv[0] and kv[1]

		now = new Date()
		now.setHours(0,0,0,0)
		if po.date
			goDay = new Date(po.date)
			goDay.setYear now.getFullYear()
		else
			goDay = new Date()
			goDay.setHours(0,0,0,0)
	

		console.log goDay
		
		# robot.brain.data.shop ||= []
		shops = getShopData() ? []
		#console.log shops, shopName
		#console.log shops[shopName]
		unless shops[shopName]
			console.log "went to #{shopName} for the first time. "
			setShopData shopName, {date: [goDay]}
		else
			# console.log shops
			shop = shops[shopName]
			exist = false
			wentTimes = 0
			for date in shop.date
				#console.log "visited #{date}"
				date = new Date(date)
				#console.log date
				console.log "#{date.getTime()}:#{goDay.getTime()}"
				if date.getTime() == goDay.getTime()
					exist = true
				wentTimes++
				console.log exist, wentTimes
			console.log "you went to #{shopName} #{wentTimes} times."
			shop.date.push goDay unless exist
			console.log shop
			setShopData shopName, shop
		#robot.brain.set('shops', shops)

		#console.log robot.brain.get('shops')
		#robot.brain.save()
		#setShopData shopName, shops[shopName]

		showRecommend()

	robot.hear /\+1\s+(\S+)/, (msg) ->
		shopName = msg.match[1]
		console.log shopName
		console.log robot.brain.data.shop[shopName]
		if robot.brain.data.shop[shopName]
			user = msg.message.user.name
			robot.brain.data.shop[shopName].rating = {user: user, rate: +1}
		robot.brain.save
		console.log robot.brain.data

	robot.hear /lunch recommend/, (msg) ->
		showRecommend()

	robot.hear /lunch history/, (msg) ->
		showRecommend()

	robot.hear /lunch truncate/, (msg) ->
		console.log robot.brain.data
		delete robot.brain.data.shops
		robot.brain.save()

	robot.hear /lunch data/, (msg) ->
	
		robot.send {room: room} , JSON.stringify(getShopData(), null, " ")

	robot.hear /lunch remove (\S+)\s*(\S*)/, (msg) ->
		name = msg.match[1]
		date = msg.match[2]

		# console.log name, date

		shop = getShopData name

		console.log shop
		if date
			date = new Date(date)
			date.setYear(new Date().getFullYear())
			newDates = []
			for went in shop.date
				went = new Date(went)
				console.log went, date
				newDates.push went unless went.getTime() == date.getTime()
			
			console.log newDates
			shop.date = newDates
			setShopData name, shop

		console.log getShopData(name)		


	showRecommend = () ->

		#console.log getShopData()
		for name, attr of getShopData() 
		  #console.log name, attr
			for date in attr.date
				date = new Date(date)
				#console.log formatDate(date)
				robot.send {room:room}, "日付:#{formatDate(date)} 名前:#{name}"
	
	getShopData = (key) ->
		if key
			robot.brain.data.shops[key] 
		else
			robot.brain.data.shops

	setShopData = (name, attr) ->
		console.log name,attr
		robot.brain.data['shops'] = {} unless robot.brain.data['shops']
		robot.brain.data.shops[name] = attr
		robot.brain.save()

	formatDate = (date) ->
		# console.log date.getFullYear()
		"#{date.getFullYear()}年#{date.getMonth()+1}月#{date.getDate()}日"
