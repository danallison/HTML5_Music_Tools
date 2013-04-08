class Sound
  constructor: (@src) ->
    @audio = new Audio(@src)
    
  play: (->
    if window.chrome
      return ->
        @audio.load()
        @audio.play()
    return ->
      @audio.play()
  )()