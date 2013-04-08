class BeatMatrix
  constructor: (@channels, @beats) ->
    @matrix = []
    for [0...@channels]
      channel = []
      for [0...@beats]
        channel.push 0
      @matrix.push channel
  
  add_hit: (channel, beat) ->
    @matrix[channel][beat] = 1
    
  remove_hit: (channel, beat) ->
    @matrix[channel][beat] = 0
    
  add_hits: (channel, beats) ->
    for beat in beats
      @add_hit channel, beat
    
  remove_hits: (channel, beats) ->
    for beat in beats
      @remove_hit channel, beat
  
  add_beats: (how_many_beats) ->
    
  add_channels: (new_sounds) ->
    
class DrumMachine extends BeatMatrix
  constructor: (@sounds = DrumMachine.default_sounds, @beats = 16, @bpm = 260) ->
    super @sounds.length, @beats
    @beat_duration = 60000 / @bpm
    @playing = false
    @current_beat = 0
    
  change_tempo: (new_bpm) ->
    @bpm = new_bpm
    @beat_duration = 60000 / new_bpm
    
  change_sound: (index, sound) ->
    if typeof sound is "string" then sound = new Sound(sound)
    @sounds[index] = sound
    
  next_beat: ->
    for channel in [0...@channels]
      if @matrix[channel][@current_beat] then  @sounds[channel].play()
      
    @current_beat = (@current_beat + 1) % @beats
    if @playing
      now = new Date().getTime()
      @expected = @expected or now
      difference = now - @expected

      @expected += @beat_duration
      next = Math.max 0, @beat_duration - difference
      @timeout = setTimeout(=> 
        @next_beat()
      , next)
    else
      @expected = null
  
  play: ->
    @playing = true
    @next_beat()
    
  stop: ->
    @playing = false
    clearTimeout(@timeout)
    @expected = null
    
class DrumMachineInterface extends DrumMachine
  constructor: (sounds, beats, bpm) ->
    super sounds, beats, bpm
    
    cell_height = 45
    screen_height = window.innerHeight
    screen_width = window.innerWidth
    matrix_height = cell_height * @channels
    matrix_width = cell_height * @beats
    
    @view = d3.select("body").append("div")
          .attr("id", "drum_machine_view")
          .style("top", "#{screen_height / 2 - matrix_height / 2}px")
          .style("left", "#{screen_width / 2 - matrix_width / 2}px")
          
    d3.select(window)
      .on("keypress", =>
        if d3.event.which is 32
          @toggle_play()
      )
      .on("resize", @resize)
    
    @play_button = @view.append("div")
      .attr("id", "play_button")
      .attr("class", "stopped")
      .style("position", "absolute")
      .style("top", "-25px")
      .style("left", "0px")
      .on("click", @toggle_play)
    
    @render_matrix_view()
      
  toggle_hit: (channel_number, beat_number) =>
    matrix_cell = @matrix[channel_number][beat_number]
    matrix_view_cell = @matrix_view[channel_number][beat_number]
    if matrix_cell
      @remove_hit channel_number, beat_number
      matrix_view_cell.style("background-color", "#EEE")
    else
      @add_hit channel_number, beat_number
      matrix_view_cell.style("background-color", "#333")
      
  toggle_play: =>
    if @playing
      @stop()
      @play_button.attr("class", "stopped")
    else
      @play()
      @play_button.attr("class", "playing")
      
  change_sound: (index, url) ->
    super index, url
    
  next_beat: ->
    for channel_view in @matrix_view
      channel_view[@current_beat].style("opacity", "1")
      channel_view[((@current_beat - 1) + @beats) % @beats]
        .style("opacity", "0.5")
        .transition().duration(@beat_duration*2).style("opacity", "0.3")
    super
  
  render_matrix_view: (matrix) ->
    if matrix
      @matrix = matrix
      
    @channels = @matrix.length
    @beats = @matrix[0].length
    if @matrix_view
      for channel_view in @matrix_view
        for cell in channel_view
          cell.remove()
        
    @matrix_view = []
    for channel_number in [0...@channels]
      channel_view = []
      for beat_number in [0...@beats]
        click_func = ((c, b)=>
          return =>
            @toggle_hit c, b
          )(channel_number, beat_number)
        hit = @matrix[channel_number][beat_number]
        color = if hit then "#333" else "#EEE"
        channel_view.push @view.append("div")
            .attr("class", "matrix_view_cell")
            .style("left", "#{beat_number * 45}px")
            .style("top", "#{channel_number * 45}px")
            .style("background-color", color)
            .style("opacity", "0.3")
            .on("click", click_func)

      @matrix_view.push channel_view
      
  resize: =>
    cell_height = 45
    screen_height = window.innerHeight
    screen_width = window.innerWidth
    matrix_height = cell_height * @channels
    matrix_width = cell_height * @beats
    
    @view.style("top", "#{screen_height / 2 - matrix_height / 2}px")
         .style("left", "#{screen_width / 2 - matrix_width / 2}px")
  
  clear_hits: ->
    for channel, channel_number in @matrix
      for beat, beat_number in channel
        if beat
          @toggle_hit channel_number, beat_number
          
  save: ->
    localStorage["beat#{localStorage.length}"] = JSON.stringify @matrix
