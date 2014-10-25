apiKey = "<api-key>"
location = "52.388297,9.740349"

exclude  = "minutely,hourly,daily,alerts,flags"

command: "curl -s 'https://api.forecast.io/forecast/#{apiKey}/#{location}?units=auto&exclude=#{exclude}'"

refreshFrequency: 600000

render: (_) -> """
  <div class="weather-icon">
    <div class="time"></div>
    <div class="date"></div>
    <div class="weather"></div>
  </div>
"""

update: (output, domEl) ->
  data = JSON.parse(output).currently

  $(domEl).find(".time").text @time()
  $(domEl).find(".date").text @date()
  $(domEl).find(".weather").text @weather data
  $(domEl).find(".weather-icon").addClass @getIcon data

style: """
  bottom 7%
  left 1%

  font-family "Avenir Next"
  font-weight 300
  color rgba(#fff, 0.57)

  .time
    font-size 36px

  .date
    font-size 48px

  .weather
    font-size 64px

  .weather-icon::after
    content ""
    opacity 0.25
    top -100px
    left 50px
    bottom 0
    right 0
    position absolute

  background-image(image)
    background url(image) no-repeat
    background-size 337px 300px

  .weather-icon.clear-day::after
    background-image('weather.widget/icons/clear-day.png')

  .weather-icon.clear-night::after
    background-image('weather.widget/icons/clear-night.png')

  .weather-icon.cloudy::after
    background-image('weather.widget/icons/cloudy.png')

  .weather-icon.mostly-clear-day::after
    background-image('weather.widget/icons/mostly-clear-day.png')

  .weather-icon.partly-cloudy-day::after
    background-image('weather.widget/icons/partly-cloudy-day.png')

  .weather-icon.partly-cloudy-night::after
    background-image('weather.widget/icons/partly-cloudy-night.png')

  .weather-icon.rain::after
    background-image('weather.widget/icons/rain.png')

  .weather-icon.sleet::after
    background-image('weather.widget/icons/rain.png')

  .weather-icon.snow::after
    background-image('weather.widget/icons/snow.png')

  .weather-icon.thunderstorm::after
    background-image('weather.widget/icons/thunderstorm.png')
"""

time: ->
  today = new Date

  hour = today.getHours()
  minute = ("0" + today.getMinutes()).slice -2

  a_p = if hour < 12 then "am" else "pm"

  hour = 12 if hour is 0
  hour = hour - 12 if hour > 12

  "#{hour}:#{minute} #{a_p}"

monthMapping:
  0: "Jan"
  1: "Feb"
  2: "Mar"
  3: "Apr"
  4: "May"
  5: "Jun"
  6: "Jul"
  7: "Aug"
  8: "Sep"
  9: "Oct"
  10: "Nov"
  11: "Dec"

dayMapping:
  0: "Sunday"
  1: "Monday"
  2: "Tuesday"
  3: "Wednesday"
  4: "Thursday"
  5: "Friday"
  6: "Saturday"

date: ->
  today = new Date

  date = today.getDate()
  month = @monthMapping[today.getMonth()]
  day = @dayMapping[today.getDay()]

  "#{day}, #{month} #{date}"

weather: (data) ->
  temperature = Math.round(data.temperature)

  "#{data.summary}, #{temperature}° C"

getIcon: (data) ->
  return "unknown" unless data

  if data.icon.indexOf("cloudy") > -1
    if data.cloudCover < 0.25
      "clear-day"
    else if data.cloudCover < 0.5
      "mostly-clear-day"
    else if data.cloudCover < 0.75
      "partly-cloudy-day"
    else
      "cloudy"
  else
    data.icon
