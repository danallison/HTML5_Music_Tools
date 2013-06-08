# class Wave
#   constructor: (data, sample_rate) ->
#     @wave = new RIFFWAVE()
#     @wave.header.sampleRate = sample_rate
#     @wave.Make data
#     
#     @audio = new Audio @wave.dataURI
#     
#   play: ->
#     @audio.play()
# 
# class Tone extends Wave
#   constructor: (@frequency = 440, milliseconds = 200) ->
#     sample_rate = 44100
#     denom = sample_rate / @frequency # TODO this is currently incorrect
#     data = []
#     for i in [0...Math.floor(sample_rate * milliseconds / 1000)]
#       data[i] = 128 + Math.round(127 * Math.sin(i / denom))
#             
#     super data, sample_rate
#     
# class Noise extends Wave
#     constructor: (tone, milliseconds = 40) ->
#       sample_rate = 44100
#       data = []
#       for i in [0...Math.floor(sample_rate * milliseconds / 1000)]
#         data[i] = 128 + Math.round(127 * Math.sin(i / (tone * 50 + tone * 50 * Math.random())))
# 
#       super data, sample_rate
class Tone
  constructor: (frequency = 440, type = "sine") ->
    types = {
      sine:     0
      square:   1
      sawtooth: 2
      triangle: 3
    }
    @oscillator = context.createOscillator()
    @oscillator.frequency.value = frequency
    @oscillator.type = type
    @oscillator.connect(context.destination)
  
  change_frequency: (frequency) ->
    @oscillator.frequency.value = frequency
    
  start: ->
    @oscillator.start(0)
    
  stop: ->
    @oscillator.stop(0)
    frequency = @oscillator.frequency.value
    type = @oscillator.type
    
    @oscillator = context.createOscillator()
    @oscillator.frequency.value = frequency
    @oscillator.type = type
    @oscillator.connect(context.destination)
    
  slide_frequency: (new_frequency, duration = 1000) ->
    frequency = @oscillator.frequency.value
    steps = [frequency..new_frequency]
    time = duration / steps.length
    interval = setInterval(=>
      if steps.length
        @oscillator.frequency.value = steps.shift()
      else
        clearInterval interval
    , time)

    # setTimeout(=>
    #       @frequency_flux()
    #     , 400)
    
class ToneInterface extends Tone
  constructor: (frequency, type) ->
    super frequency, type
    
    d3.select("body").append("div")
      .attr("id", "")
    height = window.innerHeight
    d3.select(window).on("mousemove", =>
      @change_frequency height - d3.event.y
    )
    
    @start()