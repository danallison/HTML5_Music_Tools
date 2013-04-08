class Wave
  constructor: (data, sample_rate) ->
    @wave = new RIFFWAVE()
    @wave.header.sampleRate = sample_rate
    @wave.Make data
    
    @audio = new Audio @wave.dataURI
    
  play: ->
    @audio.play()

class Tone extends Wave
  constructor: (@frequency = 440, milliseconds = 200) ->
    sample_rate = 44100
    denom = sample_rate / @frequency # TODO this is currently incorrect
    data = []
    for i in [0...Math.floor(sample_rate * milliseconds / 1000)]
      data[i] = 128 + Math.round(127 * Math.sin(i / denom))
            
    super data, sample_rate
    
class Noise extends Wave
    constructor: (tone, milliseconds = 40) ->
      sample_rate = 44100
      data = []
      for i in [0...Math.floor(sample_rate * milliseconds / 1000)]
        data[i] = 128 + Math.round(127 * Math.sin(i / (tone * 50 + tone * 50 * Math.random())))

      super data, sample_rate