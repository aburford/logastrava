namespace :daily_sync do
  task :midnight, [:days] => [:environment] do |t, args|
    (0..args[:days].to_i).each do |i|
			save_runs(Date.today - i)
      puts "Synced day #{i} of #{args[:days].to_i}"
		end
  end

  def find_attr(body, name, eov = nil)
		s = body.index(name)
		return unless s
		body.slice!(0..s + name.length - 1)
		if eov
			e = body.index(eov)
			return body[0..e - 1] if e
		end
		body # eov was not found so return rest of the body
	end

	def save_runs(date)
		i = date.cwday
		@doc = Nokogiri::HTML(HTTP.cookies(:sqlAuthCookie => ENV['SQL_AUTH_ID']).get("http://www.logarun.com/TeamCalendar.aspx?teamid=1820&date=#{date.strftime('%m-%d-%Y')}").to_s) if @doc && date.sunday? || @doc.nil?
		@doc.css(".monthDay:nth-of-type(#{i})").each do |post|
			title = post.at_css('.dayTitle').content
			body = post.at_css('p')
			if body
				body = body.content
				dist = find_attr(body, 'Run: ', ' ')
				dist = find_attr(body, '(', ' ') if dist && body[dist.length + 5] == ',' # multiple dists were logged
				dur = find_attr(body, 'Run Time: ', 'R')
				dur = find_attr(body, '(', ')') if dur && dur.length > 8 # multiple durs were logged
				# find duration in seconds
				dur &&= ActiveSupport::Duration.parse("P0Y0M0DT0#{[dur.split(':'), %w(H M S)].transpose.flatten.join}").to_i
				note = find_attr(body, 'Note: ')
			end
			u = User.find_by(username: post.at_css('.dayNum')['href'].split('/')[1])
			if u && (!title.empty? || dur)
        # check if run has already been posted
        run_check = {before: (date + 1).to_time.to_i, after: date.to_time.to_i - 1}
        if JSON.parse(HTTP.get("https://www.strava.com/api/v3/activities?access_token=#{u.access_token}", :form => run_check).to_s).size == 0
          # post run to strava
          run = {name: title, type: 'Run', start_date_local: date.iso8601 + 'T00:00:00Z', elapsed_time: dur || '0', description: note || '', distance: dist.to_f*1609.34}
          HTTP.post("https://www.strava.com/api/v3/activities?access_token=#{u.access_token}", :form => run)
        end
			end
		end
	end

end
