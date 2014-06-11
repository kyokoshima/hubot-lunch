cron = require('cron').CronJob
room = process.env.HUBOT_IRC_ROOMS


module.exports = (robot) ->
	robot.enter ->
	new cron
		cronTime: "0 2 13 * * *"
		start: true
		timeZone: "Asia/Tokyo"
		onTick: ->
			robot.send {room: room}, "昼飯時です！"
			shops = robot.brain.data.shop
			for k,v of shops
	   		jd = "#{v.date.getMonth()+1}月#{v.date.getDate()}日"
  	  	robot.send {room: room}, "#{k} #{jd}"

	robot.hear /^(.+)行った店/, (msg) ->
		line = msg.message.text
		
		cmds = line.split(/\s/)		
		console.log cmds
		day = msg.match[1]
		shopName = cmds[1]
		console.log robot.brain.data
	
		console.log "#{day} #{shopName}"
	
		date = new Date()
		switch true
			# when /今日/.test(day)
			when /昨日/.test(day)
				date = new Date(date.getYear(), date.getMonth(), date.getDate()-1)	
		
		# console.log date
		# console.log msg.message
		# robot.brain.data.shop = {}
		unless robot.brain.data.shop
			robot.brain.data.shop = {}
		robot.brain.data.shop[shopName] = {date: date}
		
		robot.brain.save
		shops = robot.brain.data.shop
		for k, v of shops
			jd = "#{v.date.getMonth()+1}月#{v.date.getDate()}日"
			robot.send {room: room}, "#{k} #{jd}"

	robot.hear /lunch test/, (msg) ->
		robot.send {room: room}, "#{room}"
		shops = robot.brain.data.shop
		showRecommend()

	robot.hear /lunch add\s+(\S+)\s*(.*)/, (msg) ->
		s = msg.match[1]
		params = msg.match[2].split(/\s/)

		po = {}
		for p in params
			kv = p.split(':')
			po[kv[0]] = kv[1] if kv[0] and kv[1]

		now = new Date()
		if po.date
			goDay = new Date(po.date)
			goDay.setYear now.getFullYear()
		else
			goDay = new Date()
			goDay.setHours(0,0,0,0)
	

		console.log goDay
		
		robot.brain.data.shop ||= []
		unless robot.brain.data.shop[s]
			robot.brain.data.shop[s] = {date: [goDay]}
		else
			# console.log "hhhhh"
			dates = robot.brain.data.shop[s].date
			exist = false
			for date in dates
				# console.log "#{date.getTime()}:#{today.getTime()}"
				if date.getTime() == today.getTime()
					exist = true
			robot.brain.data.shop[s].date.push goDay unless exist

		robot.brain.save
		
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
		delete robot.brain.data.shop
		robot.brain.save

	showRecommend = () ->
		# console.log robot.brain.data.shop
		for name, attr of robot.brain.data.shop
			console.log name, attr
			for date in attr.date
				console.log name, date
