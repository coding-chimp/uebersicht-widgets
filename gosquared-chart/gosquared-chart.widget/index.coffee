settings:
  bars: 31
  api_key: <api-key>
  site_token: <site-token>

command: ""

refreshFrequency: 10000 * 60

render: (_) -> """
  <div id="chartcontainer"></div>
  <footer>
    <span id="date"></span>
    Today: <span id="today"></span>
    Peak: <span id="peak"></span>
    Average: <span id="average"></span>
  </footer>
"""

afterRender: (domEl) ->
  @domEl = $(domEl)
  @chart = @domEl.find('#chartcontainer')

  @chartHeight = @chart.height() - 35
  @domEl.css width: @settings.bars * 11 + 14

update: (output, domEl) ->
  @getDays()
    .then @getDeviations.bind this
    .then @setFooterValues.bind this
    .then @buildBars.bind this

getDays: ->
  df = new $.Deferred

  @to = new Date
  @from = new Date
  @from.setDate @from.getDate() - @settings.bars + 1

  $.ajax "https://api.gosquared.com/trends/v2/aggregate",
    data:
      api_key: @settings.api_key
      site_token: @settings.site_token
      from: @dateAsString @from, true
      to: @dateAsString @to, true
      interval: "day"
    success: (data) =>
      @days = data.list
      df.resolve @days

  return df.promise()

dateAsString: (date, api) ->
  day = ("0" + date.getDate()).slice(-2)
  month = ("0" + (date.getMonth() + 1)).slice(-2)
  year = date.getFullYear()

  if api
    "#{year}-#{month}-#{day}"
  else
    "#{day}/#{month}"

getDeviations: ->
  visits = (day.metrics.visits || 0 for day in @days)
  @max = Math.max.apply(Math, visits)
  @today = visits[visits.length - 1]
  sum = visits.reduce ((total, item) -> total + item), 0
  @average = parseInt sum/visits.length

setFooterValues: ->
  from = @dateAsString @from, false
  to = @dateAsString @to, false
  @domEl.find("#date").html "#{from} - #{to}"
  @domEl.find("#today").html @today
  @domEl.find("#peak").html @max
  @domEl.find("#average").html @average

buildBars: ->
  bars = ""
  self = @

  @days.forEach (day) ->
    height = self.calculateBarHeight(day.metrics.visits)
    bars += "<div class='bar' style='height:#{height}px'></div>"

  @chart.html bars

calculateBarHeight: (visits) ->
  @chartHeight * visits / @max

style: """
  left 10px
  top 185px
  width 315px
  height 115px
  line-height: @height
  border-radius 5px
  background rgba(0,0,0,.25)

  #chartcontainer
    position absolute
    bottom 25px
    width 100%
    height 100%
    left 10px
    font-size 0
    transform-origin 50% 100%
    overflow hidden

  .bar
    color rgba(255,255,255,.65)
    display inline-block
    vertical-align bottom
    border-left 6px solid rgb(255,255,255)
    width 5px
    padding 0
    height 1px
    transform-origin 50% 100%
    opacity .4

  footer
    font-family Menlo
    font-size 11px
    position absolute
    bottom 0
    left 10px
    color rgba(255,255,255,.57)
    height 25px
    line-height 25px

    span
      margin-right: 15px
"""
