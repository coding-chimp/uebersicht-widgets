command: "curl --silent 'http://status-board-widgets.herokuapp.com/github/streak/number'"

refreshFrequency: 60000

render: (output) -> """
  <div class="streak">#{output}</div>
"""

style: """
  bottom 80px
  right 0
  width 200px
  height 100px

  font-family "Avenir Next"
  font-weight 300
  font-size 96px
  line-height 96px
  color rgba(255, 255, 255, 0.57)

  .streak::after
    content ""
    background url(github-streak.widget/GitHub-Mark.png) no-repeat
    background-size 64px 64px
    opacity 0.3
    position absolute
    top 16px
    left 100px
    bottom 0
    right 0
"""
