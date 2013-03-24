class @Util
  
  constructor: ->
    @page_init          = true
    @$feedback          = $ '#feedback'
    @$app_data          = $ '#app_data'
    @$download_modal    = $ '#download_modal'
    @$album_timeout     = $ '#album_timeout'
    @$album_url         = $ '#album_url'
  
  feedback: (feedback) ->
    if feedback.type == 'alert'
      css = 'feedback_alert'
      icon = 'icon-exclamation-sign'
    else
      css = 'feedback_notice'
      icon = 'icon-ok'
    id = this._uniqueID()
    @$feedback.append "<p class=\"#{css}\" id=\"#{id}\"><i class=\"#{icon}\"></i> #{feedback.msg}</p>"
    setTimeout( ->
      $("##{id}").hide 'slide'
    , 3000)

  followLink: ($el) ->
    this.navigateTo $el.attr('href')

  navigateTo: (href) ->
    # alert "adding #{href}"
    @page_init = false
    History.pushState {href: href}, @$app_data.data('app-name'), href
    window.scrollTo 0, 0
  
  navigateToRefreshMap: ->
    url = "/map?term=#{$('#map_search_term').val().replace(/\s/g, '+')}"
    url += "&distance=#{$('#map_search_distance').val()}"
    url += "&date_start=#{$('#map_date_start').val()}"
    url += "&date_stop=#{$('#map_date_stop').val()}"
    this.navigateTo(url)

  requestAlbum: (request_url, first_call) ->
    that = this
    $.ajax({
      url: '/user-signed-in',
      success: (r) ->
        if r.success
          $.ajax({
            url: request_url,
            dataType: 'json',
            success: (r) ->
              that._requestAlbumResponse(r, request_url, first_call)
          })
        else
          that.feedback { 'type': 'alert', 'msg': 'You must sign in to download MP3s' }
    })
  
  updateCurrentPlaylist: (success_msg) ->
    that = this
    track_ids = []
    duration = 0
    $('#current_playlist > li').each( ->
      track_ids.push $(this).data('id')
      duration += parseInt($(this).data('track-duration'))
    )
    $.ajax({
      url: '/update-current-playlist',
      type: 'post',
      data: { 'track_ids': track_ids },
      success: (r) ->
        that.feedback { 'msg': success_msg }
        $('#current_playlist_tracks_label').html("#{track_ids.length} Tracks")
        $('#current_playlist_duration_label').html(that.readableDuration(duration, 'letters'))
    })
  
  _requestAlbumResponse: (r, request_url, first_call) ->
    if r.status == 'Ready'
      clearTimeout @download_poller
      @$download_modal.modal 'hide'
      location.href = r.url
    else if r.status == 'Error'
      clearTimeout @download_poller
      @$download_modal.modal 'hide'
      that.feedback { 'type': 'alert', 'msg': 'An error occurred while processing your request' }
    else
      if first_call
        clearTimeout @download_poller
        @$album_timeout.hide()
        @$download_modal.modal 'show'
      else if r.status == 'Timeout'
        @$album_url.html "#{@$app_data.data('base-url')}#{r.url}"
        @$album_timeout.show 'slide'
      that = this
      @download_poller = setTimeout( ->
        that.requestAlbum(request_url, false)
      , 3000)
  
  _uniqueID: (length=8) ->
    id = ""
    id += Math.random().toString(36).substr(2) while id.length < length
    id.substr 0, length
  
  readableDuration: (ms, style='colon') ->
    x = Math.floor(ms / 1000)
    seconds = x % 60
    seconds_with_zero = "#{if seconds < 10 then '0' else '' }#{seconds}"
    x = Math.floor(x / 60)
    minutes = x % 60
    minutes_with_zero = "#{if minutes < 10 then '0' else '' }#{minutes}"
    x = Math.floor(x / 60)
    hours = x % 24
    hours_with_zero = "#{if hours < 10 then '0' else '' }#{hours}"
    x = Math.floor(x / 24)
    days = x
    if style == 'letters'
      if days > 0
        "#{days}d #{hours}h #{minutes}m #{seconds}s"
      else if hours > 0
        "#{hours}h #{minutes}m #{seconds}s"
      else
        "#{minutes}m #{seconds}s"
    else
      if days > 0
        "#{days}::#{hours}:#{minutes_with_zero}:#{seconds_with_zero}"
      else if hours > 0
        "#{hours}:#{minutes_with_zero}:#{seconds_with_zero}"
      else
        "#{minutes}:#{seconds_with_zero}"