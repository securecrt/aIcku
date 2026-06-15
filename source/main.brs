'
'	aIcku - another IPTV client for Roku OS
'	Copyright (C) 2024 Eric Kutcher
'	Copyright (C) 2026 Xin Wang
'	Released under the GPLv3 license.
'

sub RunUserInterface()
'{
	screen = CreateObject( "roSGScreen" )
	screen_port = CreateObject( "roMessagePort" )

	screen.SetMessagePort( screen_port )

	m.global = screen.GetGlobalNode()

	m.global.AddField( "ui_lang", "string", true )
	m.global.AddField( "translations", "assocarray", true )
	m.global.AddField( "feed_url", "string", true )

	m.global.AddField( "preferred_screen_width", "integer", false )
	m.global.AddField( "preferred_screen_height", "integer", false )
	m.global.AddField( "screen_width", "integer", false )
	m.global.AddField( "screen_height", "integer", false )
	m.global.AddField( "overscan_offset_x", "integer", false )
	m.global.AddField( "overscan_offset_y", "integer", false )
	m.global.AddField( "enable_automatic_subtitles", "bool", true )
	m.global.AddField( "channel_sort_type", "integer", true )
	m.global.AddField( "parental_control_active", "bool", true )
	m.global.AddField( "check_parental_control", "bool", true )

	m.global.AddField( "save_window_dimensions", "bool", true )

	m.global.AddField( "set_resume_channel", "bool", true )
	m.global.AddField( "resume_channel", "bool", true )

	m.global.AddField( "channel_group_id", "integer", false )
	m.global.AddField( "channel_number", "integer", false )
	m.global.AddField( "load_channel", "bool", true )

	m.global.AddField( "last_channel_group_id", "integer", false )
	m.global.AddField( "last_channel_number", "integer", false )

	m.global.AddField( "preferred_caption_language", "string", false )
	m.global.AddField( "caption_mode", "string", false )

	m.global.AddField( "current_content_type", "integer", 0 )	' 0 = Live TV, 1 = Movies, 2 = TV Shows

	m.global.AddField( "request_id", "integer", 0 )
	m.global.AddField( "group_id", "integer", 0 )
	m.global.AddField( "vod_content_group_id", "integer", 0 )		' The ID of a group that has VOD content.
	m.global.AddField( "channel_content_group_id", "integer", 0 )	' The ID of a group that has channel content.

	m.global.AddField( "load_request", "bool", true )	' Load either a group or channel/VOD content.

	m.global.AddField( "epg_content_limit", "integer", false )
	m.global.AddField( "epg_content_offset", "integer", false )
	m.global.AddField( "load_epg_chunk", "bool", true )

	m.global.AddField( "group_content_limit", "integer", false )
	m.global.AddField( "group_content_offset", "integer", false )
	m.global.AddField( "load_group_chunk", "bool", true )

	m.global.AddField( "content_limit", "integer", false )
	m.global.AddField( "content_offset", "integer", false )
	m.global.AddField( "load_content_chunk", "bool", true )

	m.global.AddField( "loading_content", "bool", false )
	m.global.AddField( "loading_epg", "bool", false )
	m.global.AddField( "loading_details", "integer", false )	' 0 = not loading, 1 = loading from VOD menu, 2 = loading from video player, 3 = loading from group menu



	m.global.AddField( "favorite_add_remove", "integer", false )
	m.global.AddField( "favorite_id", "integer", false )
	m.global.AddField( "set_favorite", "bool", true )
	m.global.AddField( "favorite_status", "integer", false )

	m.global.AddField( "details_name", "string", false )
	m.global.AddField( "details_year", "string", false )
	m.global.AddField( "details_season", "string", false )
	m.global.AddField( "details_episode", "string", false )
	m.global.AddField( "load_details", "bool", true )

	m.global.AddField( "panel_color", "string", false )

	m.global.panel_color = "0x001020E0"

	m.global.feed_url = ""
	m.global.parental_control_active = false
	m.global.check_parental_control = false

	m.global.enable_automatic_subtitles = false

	m.global.channel_sort_type = 0	' 0 = Number, 1 = Name

	m.global.preferred_screen_width = 1920
	m.global.preferred_screen_height = 1080

	m.global.screen_width = m.global.preferred_screen_width
	m.global.screen_height = m.global.preferred_screen_height

	m.global.overscan_offset_x = 0
	m.global.overscan_offset_y = 0

	m.global.save_window_dimensions = false

	m.global.current_content_type = -1



	m.global.loading_content = false
	m.global.loading_epg = false
	m.global.loading_details = 0

	m.global.request_id = 0
	m.global.group_id = 0
	m.global.vod_content_group_id = 0
	m.global.channel_content_group_id = 0

	m.global.load_request = false
	m.global.load_group_chunk = false
	m.global.load_content_chunk = false
	m.global.load_epg_chunk = false

	m.global.epg_content_limit = 100
	m.global.epg_content_offset = 0

	m.global.content_limit = 100
	m.global.content_offset = 0

	m.global.group_content_limit = 100
	m.global.group_content_offset = 0

	m.global.favorite_add_remove = 0
	m.global.favorite_id = 0
	m.global.set_favorite = false
	m.global.favorite_status = 0

	m.global.details_name = ""
	m.global.details_year = ""
	m.global.details_season = ""
	m.global.details_episode = ""
	m.global.load_details = false

	m.global.set_resume_channel = false
	m.global.resume_channel = false

	m.global.channel_group_id = -1
	m.global.channel_number = -1
	m.global.load_channel = false

	GetSettings()

	' channel_group_id and channel_number maybe have been saved.
	m.global.last_channel_group_id = m.global.channel_group_id
	m.global.last_channel_number = m.global.channel_number

	device_info = CreateObject( "roDeviceInfo" )

	country_code_map = { "en": "eng", "es": "spa", "fr": "fra",
						 "de": "deu", "it": "ita", "pt": "por",
						 "ru": "rus", "tr": "tur", "pl": "pol",
						 "uk": "ukr", "ro": "ron", "nl": "nld",
						 "hr": "hrv", "hu": "hun", "el": "ell",
						 "cs": "ces", "sv": "swe" }

	if country_code_map.Lookup( device_info.GetPreferredCaptionLanguage() ) <> invalid
	'{
		m.global.preferred_caption_language = country_code_map[ device_info.GetPreferredCaptionLanguage() ]
	'}
	else
	'{
		m.global.preferred_caption_language = "eng"
	'}
	end if
	m.global.caption_mode = device_info.GetCaptionsMode()

	'cec_status = CreateObject( "roCECStatus" )
	'cec_status.SetMessagePort( screen_port )

	hdmi_status = CreateObject( "roHdmiStatus" )
	hdmi_status.SetMessagePort( screen_port )

	' Allows the SceneGraph to defer back to main.
	m.global.ObserveField( "load_request", screen_port )
	m.global.ObserveField( "load_group_chunk", screen_port )
	m.global.ObserveField( "load_content_chunk", screen_port )
	m.global.ObserveField( "load_epg_chunk", screen_port )
	m.global.ObserveField( "load_details", screen_port )
	m.global.ObserveField( "load_channel", screen_port )
	m.global.ObserveField( "set_favorite", screen_port )
	m.global.ObserveField( "set_resume_channel", screen_port )
	m.global.ObserveField( "resume_channel", screen_port )
	m.global.ObserveField( "channel_sort_type", screen_port )
	m.global.ObserveField( "feed_url", screen_port )
	m.global.ObserveField( "ui_lang", screen_port )
	m.global.ObserveField( "enable_automatic_subtitles", screen_port )
	m.global.ObserveField( "save_window_dimensions", screen_port )
	m.global.ObserveField( "check_parental_control", screen_port )

	m.scene = screen.CreateScene( "Home" )
	m.scene.backgroundURI = ""
	m.scene.backgroundColor = "0x000000FF"

	' Register TV client IP with server
	device_info = CreateObject("roDeviceInfo")
	ipAddrs = device_info.GetIPAddrs()
	rokuIp = ""
	if ipAddrs <> invalid
		for each key in ipAddrs
			ip = ipAddrs[key]
			if ip <> invalid and ip <> "" and ip <> "127.0.0.1"
				rokuIp = ip
				exit for
			end if
		end for
	end if
	
	if rokuIp <> "" and m.global.feed_url <> ""
		m3uUrl = m.global.feed_url
		baseM3u = ""
		lastSlash = -1
		for i = m3uUrl.Len() - 1 to 0 step -1
			if m3uUrl.Mid( i, 1 ) = "/"
				lastSlash = i
				exit for
			end if
		end for
		if lastSlash <> -1
			baseM3u = m3uUrl.Mid( 0, lastSlash + 1 )
		end if
		
		if baseM3u <> ""
			registerUrl = baseM3u + "lock.php?register=true&ip=" + rokuIp + "&port=8090"
			m.register_transfer = CreateObject( "roUrlTransfer" )
			m.register_transfer.EnablePeerVerification( false )
			m.register_transfer.SetURL( registerUrl )
			m.register_transfer.SetMessagePort( screen_port )
			m.register_transfer.AsyncGetToString()
		end if
	end if

	screen.Show()

	while true
	'{
		msg = wait( 0, screen_port )

		msg_type = type( msg )

		if msg_type = "roSGNodeEvent"
		'{
			field = msg.GetField()
			if field = "load_request"
			'{
				' We don't know if this request is for group or channel/VOD content.
				LoadContent( m.global.current_content_type, m.global.channel_sort_type, m.global.request_id, m.global.content_limit, m.global.content_offset, "" )
			'}
			else if field = "load_group_chunk"
			'{
				LoadContent( m.global.current_content_type, m.global.channel_sort_type, m.global.group_id, m.global.group_content_limit, m.global.group_content_offset, "" )
			'}
			else if field = "load_content_chunk"
			'{
				content_group_id = -1
				if m.global.current_content_type = 0	' Live TV
				'{
					content_group_id = m.global.channel_content_group_id
				'}
				else if m.global.current_content_type = 1 or m.global.current_content_type = 2	' VOD Movies/TV Shows
				'{
					content_group_id = m.global.vod_content_group_id
				'}
				end if

				LoadContent( m.global.current_content_type, m.global.channel_sort_type, content_group_id, m.global.content_limit, m.global.content_offset, "" )
			'}
			else if field = "load_epg_chunk"
			'{
				LoadEPG( m.global.channel_sort_type, m.global.channel_content_group_id, m.global.epg_content_limit, m.global.epg_content_offset, "" )
			'}
			else if field = "load_details"
			'{
				LoadDetails( m.global.current_content_type, m.global.details_name, m.global.details_year, m.global.details_season, m.global.details_episode )
			'}
			else if field = "load_channel"
			'{
				LoadChannel( m.global.channel_group_id, m.global.channel_number )
			'}
			else if field = "set_favorite"
			'{
				SetFavorite( m.global.favorite_add_remove, m.global.favorite_id )
			'}
			else if field = "set_resume_channel"
			'{
				RegWrite( "RESUME_CHANNEL_GROUP_ID", m.global.channel_group_id.ToStr() )
				RegWrite( "RESUME_CHANNEL_NUMBER", m.global.channel_number.ToStr() )
			'}
			else if field = "resume_channel"
			'{
				value = "0"
				if m.global.resume_channel = true
				'{
					value = "1"
				'}
				end if

				RegWrite( "RESUME_CHANNEL", value )
			'}
			else if field = "channel_sort_type"
			'{
				RegWrite( "CHANNEL_SORT_TYPE", m.global.channel_sort_type.ToStr() )
			'}
			else if field = "feed_url"
			'{
				RegWrite( "FEED_URL", m.global.feed_url )
				FetchAndParseData()
			'}
			else if field = "ui_lang"
			'{
				RegWrite( "UI_LANG", m.global.ui_lang )
				m.global.translations = LoadTranslations( m.global.ui_lang )
			'}
			else if field = "check_parental_control"
			'{
				m.global.parental_control_active = QueryParentalControlStatus()
			'}
			else if field = "enable_automatic_subtitles"
			'{
				value = "0"
				if m.global.enable_automatic_subtitles = true
				'{
					value = "1"
				'}
				end if

				RegWrite( "ENABLE_AUTOMATIC_SUBTITLES", value )
			'}
			else if field = "save_window_dimensions"
			'{
				RegWrite( "SCREEN_WIDTH", m.global.screen_width.ToStr() )
				RegWrite( "SCREEN_HEIGHT", m.global.screen_height.ToStr() )
				RegWrite( "OVERSCAN_OFFSET_X", m.global.overscan_offset_x.ToStr() )
				RegWrite( "OVERSCAN_OFFSET_Y", m.global.overscan_offset_y.ToStr() )
			'}
			end if
		'}
		' else if msg_type = "roCECStatusEvent"
		' '{
		' 	' This could be used to determine if the TV is off.
		' '}
		else if msg_type = "roHdmiStatusEvent"
		'{
			if msg.GetInfo()[ "Plugged" ] = false
			'{
				m.scene.tv_is_off = true
			'}
			end if
		'}
		else if msg_type = "roSGScreenEvent"
		'{
			if msg.IsScreenClosed()
			'{
				exit while
			'}
			end if
		'}
		end if
	'}
	end while

	if screen <> invalid
	'{
		screen.Close()
		screen = invalid
	'}
	end if
'}
end sub

function RegRead( key, section = invalid ) as dynamic
'{
	if section = invalid
	'{
		section = "Default"
	'}
	end if

	sec = CreateObject( "roRegistrySection", section )

	if sec.Exists( key )
	'{
		return sec.Read( key )
	'}
	end if

	return invalid
'}
end function

sub RegWrite( key, val, section = invalid )
'{
	if section = invalid
	'{
		section = "Default"
	'}
	end if

	sec = CreateObject( "roRegistrySection", section )

	sec.Write( key, val )
	sec.Flush()
'}
end sub

sub GetSettings()
'{
	ui_lang = RegRead( "UI_LANG" )
	if ui_lang <> invalid
	'{
		m.global.ui_lang = ui_lang
	'}
	else
	'{
		m.global.ui_lang = "en"
	'}
	end if

	m.global.translations = LoadTranslations( m.global.ui_lang )

	feed_url = RegRead( "FEED_URL" )
	if feed_url <> invalid and feed_url <> ""
	'{
		m.global.feed_url = feed_url
	'}
	else
	'{
		' .feed_url format: a single line containing only the raw URL (e.g., http://your-iptv-server/iptv.m3u)
		m.global.feed_url = ReadAsciiFile( "pkg:/.feed_url" ).Trim()
	'}
	end if

	screen_width = RegRead( "SCREEN_WIDTH" )
	if screen_width <> invalid
	'{
		m.global.screen_width = screen_width.ToInt()
	'}
	end if
	screen_height = RegRead( "SCREEN_HEIGHT" )
	if screen_height <> invalid
	'{
		m.global.screen_height = screen_height.ToInt()
	'}
	end if
	overscan_offset_x = RegRead( "OVERSCAN_OFFSET_X" )
	if overscan_offset_x <> invalid
	'{
		m.global.overscan_offset_x = overscan_offset_x.ToInt()
	'}
	end if
	overscan_offset_y = RegRead( "OVERSCAN_OFFSET_Y" )
	if overscan_offset_y <> invalid
	'{
		m.global.overscan_offset_y = overscan_offset_y.ToInt()
	'}
	end if

	enable_automatic_subtitles = RegRead( "ENABLE_AUTOMATIC_SUBTITLES" )
	if enable_automatic_subtitles <> invalid and enable_automatic_subtitles = "1"
	'{
		m.global.enable_automatic_subtitles = true
	'}
	end if

	channel_sort_type = RegRead( "CHANNEL_SORT_TYPE" )
	if channel_sort_type <> invalid
	'{
		m.global.channel_sort_type = channel_sort_type.ToInt()
	'}
	end if

	resume_channel = RegRead( "RESUME_CHANNEL" )
	if resume_channel <> invalid and resume_channel = "1"
	'{
		m.global.resume_channel = true
	'}
	end if

	resume_channel_group_id = RegRead( "RESUME_CHANNEL_GROUP_ID" )
	if resume_channel_group_id <> invalid
	'{
		m.global.channel_group_id = resume_channel_group_id.ToInt()
	'}
	end if

	resume_channel_number = RegRead( "RESUME_CHANNEL_NUMBER" )
	if resume_channel_number <> invalid
	'{
		m.global.channel_number = resume_channel_number.ToInt()
	'}
	end if
'}
end sub

sub LoadContent( content_type as integer, sort_type as integer, id as integer, content_limit as integer, content_offset as integer, search_query as string )
'{
	got_content = false

	response = GetLocalContent( content_type, sort_type, id, content_limit, content_offset, search_query )
	if response <> invalid and response.data <> invalid
	'{
		if response.data.type = 0	' Groups
		'{
			got_content = true

			m.global.group_id = response.data.id

			content = CreateObject( "roSGNode", "GroupContentNode" )
			content.group_id = response.data.id
			content.Title = response.data.name
			content.total = response.data.total

			for each value in response.data.values
			'{
				if ( value.id <> invalid )
				'{
					node = CreateObject( "roSGNode", "GroupContentNode" )
					node.group_id = value.id
					node.Title = value.name

					content.AppendChild( node )
				'}
				end if
			'}
			end for

			m.scene.group_content = content
		'}
		else if response.data.type = 1	' Channels
		'{
			got_content = true

			content = CreateObject( "roSGNode", "GroupContentNode" )
			content.group_id = response.data.id
			content.Title = response.data.name
			content.total = response.data.total

			if m.global.current_content_type = 0	' Live TV
			'{
				m.global.channel_content_group_id = response.data.id

				for each value in response.data.values
				'{
					node = CreateObject( "roSGNode", "ChannelContentNode" )
					node.channel_id = value.id
					node.Number = value.number
					node.Title = value.name
					node.HDPosterUrl = value.logo_url
					node.Url = value.url
					node.StreamFormat = value.extension

					if value.headers <> ""
					'{
						node.HttpHeaders = value.headers.Split( Chr( 13 ) + Chr( 10 ) )
					'}
					end if

					if value.favorite <> 0
					'{
						node.Favorite = true
					'}
					end if

					content.AppendChild( node )
				'}
				end for
			'}
			end if

			m.scene.content = content
		'}
		end if
	'}
	end if

	if got_content = false
	'{
		' This is set to alwaysnotify in Home and Group Menu.
		' It allows the Group Menu to display "No Groups Available".
		m.scene.group_content = invalid
	'}
	end if
'}
end sub

sub LoadEPG( sort_type as integer, id as integer, content_limit as integer, content_offset as integer, search_query as string )
'{
	got_content = false

	response = GetLocalEPG( sort_type, id, content_limit, content_offset, search_query )
	if response <> invalid and response.data <> invalid
	'{
		got_content = true

		content = CreateObject( "roSGNode", "GroupContentNode" )
		content.group_id = response.data.id
		content.Title = response.data.name
		content.total = response.data.total

		for each channel in response.data.values
		'{
			channel_node = CreateObject( "roSGNode", "ChannelContentNode" )
			channel_node.channel_id = channel.id
			channel_node.Number = channel.number
			channel_node.Title = channel.name
			channel_node.HDPosterUrl = channel.logo_url
			channel_node.Url = channel.url
			channel_node.StreamFormat = channel.extension

			if channel.headers <> ""
			'{
				channel_node.HttpHeaders = channel.headers.Split( Chr( 13 ) + Chr( 10 ) )
			'}
			end if

			if channel.favorite <> 0
			'{
				channel_node.Favorite = true
			'}
			end if

			for each program in channel.programs
			'{
				' Do not load programs with weird times.
				if program.start < program.stop
				'{
					program_node = CreateObject( "roSGNode", "EPGContentNode" )
					program_node.Title = program.title
					program_node.Description = program.description
					program_node.start_time = program.start
					program_node.end_time = program.stop

					channel_node.AppendChild( program_node )
				'}
				end if
			'}
			end for

			content.AppendChild( channel_node )
		'}
		end for

		m.scene.epg_content = content
	'}
	end if

	if got_content = false
	'{
		' This is set to alwaysnotify in Home and Channel Guide.
		' It allows the Channel Guide to display "Guide Not Available".
		m.scene.epg_content = invalid
	'}
	end if
'}
end sub

sub LoadDetails( content_type as integer, name as string, year as string, season as string, episode as string )
'{
	content_type = content_type
	name = name
	year = year
	season = season
	episode = episode
	m.scene.details_content = invalid
'}
end sub

sub LoadChannel( id as integer, channel_number as integer )
'{
	got_content = false

	response = GetLocalChannel( id, channel_number )
	if response <> invalid and response.data <> invalid
	'{
		' There should only be one channel.
		if response.data.values.Count() > 0
		'{
			got_content = true

			content = CreateObject( "roSGNode", "GroupContentNode" )
			content.group_id = response.data.id
			content.Title = response.data.name
			content.total = response.data.total

			m.global.channel_content_group_id = response.data.id

			''''''''''''''''''''''''

			value = response.data.values[ 0 ]

			node = CreateObject( "roSGNode", "ChannelContentNode" )
			node.channel_id = value.id
			node.Number = value.number
			node.Title = value.name
			node.HDPosterUrl = value.logo_url
			node.Url = value.url
			node.StreamFormat = value.extension

			if value.headers <> ""
			'{
				node.HttpHeaders = value.headers.Split( Chr( 13 ) + Chr( 10 ) )
			'}
			end if

			if value.favorite <> 0
			'{
				node.Favorite = true
			'}
			end if

			content.AppendChild( node )

			''''''''''''''''''''''''

			node = CreateObject( "roSGNode", "Node" )

			for each group in response.data.groups
			'{
				group_content = CreateObject( "roSGNode", "GroupContentNode" )
				group_content.group_id = group.id
				group_content.Title = group.name

				node.AppendChild( group_content )
			'}
			end for

			content.AppendChild( node )

			''''''''''''''''''''''''

			' Save our last valid channel number info if it doesn't match the previously saved channel number info.
			if id <> m.global.last_channel_group_id or channel_number <> m.global.last_channel_number
			'{
				RegWrite( "RESUME_CHANNEL_GROUP_ID", id.ToStr() )
				RegWrite( "RESUME_CHANNEL_NUMBER", channel_number.ToStr() )
			'}
			end if

			m.scene.channel_content = content
		'}
		end if
	'}
	end if

	if got_content = false
	'{
		' This is set to alwaysnotify in Home.
		m.scene.channel_content = invalid
	'}
	end if
'}
end sub

sub SetFavorite( add_remove_type as integer, channel_id as integer )
    ' Find the channel by ID
    channel = invalid
    for each ch in m.local_channels
        if ch.id = channel_id
            channel = ch
            exit for
        end if
    end for
    
    if channel = invalid
        m.global.favorite_status = -1
        return
    end if
    
    favs = GetFavorites()
    exists_idx = -1
    for i = 0 to favs.Count() - 1
        if favs[ i ] = channel.url
            exists_idx = i
            exit for
        end if
    end for
    
    if add_remove_type = 1 ' Add
        if exists_idx = -1
            favs.Push( channel.url )
        end if
        channel.favorite = 1
        
        has_fav_group = false
        for each gid in channel.group_ids
            if gid = 4 then has_fav_group = true
        end for
        if not has_fav_group then channel.group_ids.Push( 4 )
    else if add_remove_type = 0 ' Remove
        if exists_idx <> -1
            favs.Delete( exists_idx )
        end if
        channel.favorite = 0
        
        new_gids = []
        for each gid in channel.group_ids
            if gid <> 4 then new_gids.Push( gid )
        end for
        channel.group_ids = new_gids
    end if
    
    SaveFavorites( favs )
    m.global.favorite_status = 1
end sub

' ==========================================
' STANDALONE PARSERS & HELPERS
' ==========================================

sub FetchAndParseData()
    m.global.loading_content = true
    m.global.loading_epg = true
    
    m.local_channels = []
    m.local_groups = []
    
    m3uUrl = m.global.feed_url
    if m3uUrl = ""
        m.global.loading_content = false
        m.global.loading_epg = false
        return
    end if
    
    transfer = CreateObject( "roUrlTransfer" )
    transfer.EnablePeerVerification( false )
    transfer.SetURL( m3uUrl )
    m3uText = transfer.GetToString()
    if m3uText = ""
        m.global.loading_content = false
        m.global.loading_epg = false
        return
    end if
    
    ParseM3U( m3uText )
    
    epgUrl = ""
    lines = m3uText.Split( Chr( 10 ) )
    if lines.Count() > 0
        firstLine = lines[ 0 ]
        epgUrl = GetAttribute( firstLine, "x-tvg-url" )
    end if
    
    if epgUrl = ""
        lastSlash = m3uUrl.Len() - 1
        for i = m3uUrl.Len() - 1 to 0 step -1
            if m3uUrl.Mid( i, 1 ) = "/"
                lastSlash = i
                exit for
            end if
        end for
        epgUrl = m3uUrl.Mid( 0, lastSlash + 1 ) + "epg.xml"
    end if
    
    if epgUrl <> ""
        if epgUrl.Mid( 0, 7 ) <> "http://" and epgUrl.Mid( 0, 8 ) <> "https://"
            baseM3u = ""
            lastSlash = -1
            for i = m3uUrl.Len() - 1 to 0 step -1
                if m3uUrl.Mid( i, 1 ) = "/"
                    lastSlash = i
                    exit for
                end if
            end for
            if lastSlash <> -1
                baseM3u = m3uUrl.Mid( 0, lastSlash + 1 )
            end if
            epgUrl = baseM3u + epgUrl
        end if
    end if

    isGz = false
    if epgUrl.Len() >= 3 and epgUrl.Instr( "epg.php" ) = -1 and epgUrl.Instr( "decompress.php" ) = -1
        ext = LCase( epgUrl.Mid( epgUrl.Len() - 3, 3 ) )
        if ext = ".gz"
            isGz = true
        end if
    end if
    
    if isGz
        baseM3u = ""
        lastSlash = -1
        for i = m3uUrl.Len() - 1 to 0 step -1
            if m3uUrl.Mid( i, 1 ) = "/"
                lastSlash = i
                exit for
            end if
        end for
        if lastSlash <> -1
            baseM3u = m3uUrl.Mid( 0, lastSlash + 1 )
        end if
        
        if baseM3u <> ""
            proxyUrl = baseM3u + "epg.php?url=" + transfer.Escape( epgUrl )
            epgUrl = proxyUrl
        end if
    end if

    transfer.SetURL( epgUrl )
    xmlText = transfer.GetToString()
    if xmlText <> ""
        ParseXMLTV( xmlText )
    end if
    
    m.global.loading_content = false
    m.global.loading_epg = false
end sub

sub ParseM3U( m3uText as String )
    lines = m3uText.Split( Chr( 10 ) )
    favs = GetFavorites()
    groupsMap = {}
    channelId = 0
    
    for i = 0 to lines.Count() - 1
        line = lines[ i ].Trim()
        if line.Left( 7 ) = "#EXTINF"
            tvgId = GetAttribute( line, "tvg-id" )
            tvgName = GetAttribute( line, "tvg-name" )
            logoUrl = GetAttribute( line, "tvg-logo" )
            groupTitle = GetAttribute( line, "group-title" )
            if groupTitle = "" then groupTitle = "Other"
            
            displayName = ""
            lastComma = -1
            for j = line.Len() - 1 to 0 step -1
                if line.Mid( j, 1 ) = ","
                    lastComma = j
                    exit for
                end if
            end for
            if lastComma <> -1
                displayName = line.Mid( lastComma + 1 ).Trim()
            else
                displayName = tvgName
            end if
            
            streamUrl = ""
            for k = i + 1 to lines.Count() - 1
                nextLine = lines[ k ].Trim()
                if nextLine <> ""
                    if nextLine.Left( 7 ) = "#EXTINF"
                        exit for
                    else if nextLine.Left( 1 ) <> "#"
                        streamUrl = nextLine
                        i = k
                        exit for
                    end if
                end if
            end for
            
            if streamUrl <> ""
                groupId = 0
                if groupsMap.DoesExist( groupTitle )
                    groupId = groupsMap[ groupTitle ]
                else
                    groupId = 10000 + groupsMap.Count()
                    groupsMap[ groupTitle ] = groupId
                    m.local_groups.Push( { id: groupId, name: groupTitle } )
                end if
                
                favorite = 0
                for each favUrl in favs
                    if favUrl = streamUrl
                        favorite = 1
                        exit for
                    end if
                end for
                
                group_ids = [ 1, groupId ]
                if favorite = 1
                    group_ids.Push( 4 )
                end if
                
                ext = "ts"
                parsedPath = streamUrl
                qIdx = streamUrl.Instr( "?" )
                if qIdx <> -1
                    parsedPath = streamUrl.Mid( 0, qIdx )
                end if
                dotIdx = -1
                for j = parsedPath.Len() - 1 to 0 step -1
                    if parsedPath.Mid( j, 1 ) = "."
                        dotIdx = j
                        exit for
                    end if
                end for
                if dotIdx <> -1
                    ext = parsedPath.Mid( dotIdx + 1 ).Trim()
                end if
                
                guideIdName = tvgId
                if guideIdName = "" then guideIdName = tvgName
                if guideIdName = "" then guideIdName = displayName
                
                channel = {
                    id: channelId,
                    number: channelId + 1,
                    name: displayName,
                    guide_id_name: guideIdName,
                    guide_id: -1,
                    url: streamUrl,
                    extension: ext,
                    logo_url: logoUrl,
                    headers: "",
                    favorite: favorite,
                    group_ids: group_ids,
                    programs: []
                }
                
                m.local_channels.Push( channel )
                channelId++
            end if
        end if
    next
end sub

sub ParseXMLTV( xmlText as String )
    xml = CreateObject( "roXMLElement" )
    if not xml.Parse( xmlText )
        print "EPG XML Parse failed"
        return
    end if
    
    channelMap = {}
    for each ch in m.local_channels
        if ch.guide_id_name <> ""
            channelMap[ ch.guide_id_name ] = ch
        end if
    next
    
    programmes = xml.GetNamedElements( "programme" )
    
    currentTime = CreateObject( "roDateTime" ).AsSeconds()
    
    matchedCount = 0
    for each prog in programmes
        channelName = prog@channel
        if channelName <> invalid and channelMap.DoesExist( channelName )
            channel = channelMap[ channelName ]
            
            stopTimeStr = prog@stop
            stopTs = ParseXmltvTime( stopTimeStr )
            
            if stopTs > currentTime
                startTimeStr = prog@start
                startTs = ParseXmltvTime( startTimeStr )
                
                title_list = prog.GetNamedElements( "title" )
                title = ""
                if title_list.Count() > 0 then title = title_list[ 0 ].GetText()
                
                desc_list = prog.GetNamedElements( "desc" )
                desc = ""
                if desc_list.Count() > 0 then desc = desc_list[ 0 ].GetText()
                
                program = {
                    title: title,
                    start: startTs,
                    stop: stopTs,
                    description: desc
                }
                channel.programs.Push( program )
                matchedCount++
            end if
        end if
    next
end sub

function ParseXmltvTime( timeStr as String ) as Integer
    if timeStr.Len() < 14
        return 0
    end if
    
    year = timeStr.Mid( 0, 4 )
    month = timeStr.Mid( 4, 2 )
    day = timeStr.Mid( 6, 2 )
    hour = timeStr.Mid( 8, 2 )
    minute = timeStr.Mid( 10, 2 )
    second = timeStr.Mid( 12, 2 )
    
    isoStr = year + "-" + month + "-" + day + "T" + hour + ":" + minute + ":" + second + "Z"
    
    trimmed = timeStr.Trim()
    sign = ""
    signIdx = -1
    for idx = trimmed.Len() - 1 to 14 step -1
        char = trimmed.Mid( idx, 1 )
        if char = "+" or char = "-"
            sign = char
            signIdx = idx
            exit for
        end if
    end for
    
    offsetSeconds = 0
    if signIdx <> -1 and trimmed.Len() >= signIdx + 5
        offH = trimmed.Mid( signIdx + 1, 2 ).ToInt()
        offM = trimmed.Mid( signIdx + 3, 2 ).ToInt()
        offsetSeconds = offH * 3600 + offM * 60
        if sign = "-"
            offsetSeconds = -offsetSeconds
        end if
    end if
    
    dt = CreateObject( "roDateTime" )
    dt.FromISO8601String( isoStr )
    return dt.AsSeconds() - offsetSeconds
end function

function GetAttribute( line as String, attr as String ) as String
    regex = CreateObject( "roRegex", attr + "=""([^""]*)""", "i" )
    matches = regex.Match( line )
    if matches.Count() > 1
        return matches[ 1 ]
    end if
    return ""
end function

function GetFavorites() as Object
    json = RegRead( "FAVORITES_JSON" )
    if json <> invalid
        favs = ParseJson( json )
        if favs <> invalid
            return favs
        end if
    end if
    return []
end function

sub SaveFavorites( favs as Object )
    json = FormatJson( favs )
    RegWrite( "FAVORITES_JSON", json )
end sub

function GetLocalContent( content_type as integer, sort_type as integer, id as integer, limit as integer, offset as integer, search_query as string ) as Object
    search_query = search_query
    response = {
        data: {
            type: -1,
            total: 0,
            id: id,
            name: "",
            values: []
        }
    }
    
    if content_type <> 0
        return response
    end if
    
    if m.local_channels = invalid or m.local_channels.Count() = 0
        FetchAndParseData()
    end if
    
    if id = 0
        response.data.type = 0
        response.data.name = "Live TV"
        
        group_list = []
        group_list.Push( { id: 1, name: "All" } )
        
        favs = GetFavorites()
        if favs.Count() > 0
            group_list.Push( { id: 4, name: "Favorites" } )
        end if
        

        
        for each g in m.local_groups
            group_list.Push( { id: g.id, name: g.name } )
        end for
        
        response.data.total = group_list.Count()
        response.data.values = PaginateArray( group_list, limit, offset )
    else
        response.data.type = 1
        
        group_name = ""
        if id = 1
            group_name = "All"
        else if id = 4
            group_name = "Favorites"
        else
            for each g in m.local_groups
                if g.id = id
                    group_name = g.name
                    exit for
                end if
            end for
        end if
        response.data.name = group_name
        
        filtered_channels = []
        for each ch in m.local_channels
            in_group = false
            for each gid in ch.group_ids
                if gid = id
                    in_group = true
                    exit for
                end if
            end for
            
            if in_group
                filtered_channels.Push( ch )
            end if
        end for
        
        if sort_type = 1
            SortChannelsByName( filtered_channels )
        else
            SortChannelsByNumber( filtered_channels )
        end if
        
        response.data.total = filtered_channels.Count()
        response.data.values = PaginateArray( filtered_channels, limit, offset )
    end if
    
    return response
end function

function GetLocalEPG( sort_type as integer, id as integer, limit as integer, offset as integer, search_query as string ) as Object
    search_query = search_query
    response = {
        data: {
            id: id,
            name: "",
            total: 0,
            values: []
        }
    }
    
    if m.local_channels = invalid or m.local_channels.Count() = 0
        FetchAndParseData()
    end if
    
    group_name = ""
    if id = 0
        group_name = "Live TV"
    else if id = 1
        group_name = "All"
    else if id = 4
        group_name = "Favorites"
    else
        for each g in m.local_groups
            if g.id = id
                group_name = g.name
                exit for
            end if
        end for
    end if
    response.data.name = group_name
    
    filtered_channels = []
    for each ch in m.local_channels
        in_group = false
        for each gid in ch.group_ids
            if gid = id or ( id = 0 and gid = 1 )
                in_group = true
                exit for
            end if
        end for
        
        if in_group
            filtered_channels.Push( ch )
        end if
    end for
    
    if sort_type = 1
        SortChannelsByName( filtered_channels )
    else
        SortChannelsByNumber( filtered_channels )
    end if
    
    response.data.total = filtered_channels.Count()
    
    paginated_channels = PaginateArray( filtered_channels, limit, offset )
    
    values = []
    for each ch in paginated_channels
        ch_val = {
            id: ch.id,
            number: ch.number,
            name: ch.name,
            guide_id: ch.guide_id,
            url: ch.url,
            extension: ch.extension,
            logo_url: ch.logo_url,
            headers: ch.headers,
            favorite: ch.favorite,
            programs: ch.programs
        }
        values.Push( ch_val )
    end for
    
    response.data.values = values
    return response
end function

function GetLocalChannel( id as integer, channel_number as integer ) as Object
    response = {
        data: {
            type: 3,
            total: 0,
            id: id,
            name: "",
            values: [],
            groups: []
        }
    }
    
    if m.local_channels = invalid or m.local_channels.Count() = 0
        FetchAndParseData()
    end if
    
    channel = invalid
    for each ch in m.local_channels
        if ch.number = channel_number
            channel = ch
            exit for
        end if
    end for
    
    if channel <> invalid
        response.data.total = 1
        
        ch_val = {
            id: channel.id,
            number: channel.number,
            name: channel.name,
            guide_id: channel.guide_id,
            url: channel.url,
            extension: channel.extension,
            logo_url: channel.logo_url,
            headers: channel.headers,
            favorite: channel.favorite
        }
        response.data.values.Push( ch_val )
        
        groups = []
        groups.Push( { id: 0, name: "Live TV" } )
        
        group_name = ""
        if id = 1
            group_name = "All"
        else if id = 4
            group_name = "Favorites"
        else
            for each g in m.local_groups
                if g.id = id
                    group_name = g.name
                    groups.Push( { id: g.id, name: g.name } )
                    exit for
                end if
            end for
        end if
        
        if id = 0 or id = 4
            response.data.id = 0
            response.data.name = "Live TV"
        else
            response.data.id = id
            response.data.name = group_name
        end if
        
        response.data.groups = groups
    end if
    
    return response
end function

function PaginateArray( arr as Object, limit as integer, offset as integer ) as Object
    total = arr.Count()
    if total = 0
        return []
    end if
    
    if limit >= total or limit <= 0
        return arr
    end if
    
    if offset < 0
        offset = ( total + ( offset mod total ) ) mod total
    else if offset >= total
        offset = offset mod total
    end if
    
    paginated = []
    if offset + limit <= total
        for i = 0 to limit - 1
            paginated.Push( arr[ offset + i ] )
        end for
    else
        first_part_len = total - offset
        for i = 0 to first_part_len - 1
            paginated.Push( arr[ offset + i ] )
        end for
        second_part_len = limit - first_part_len
        for i = 0 to second_part_len - 1
            paginated.Push( arr[ i ] )
        end for
    end if
    
    return paginated
end function

sub SortChannelsByName( channels as Object )
    count = channels.Count()
    if count < 2 then return
    for i = 0 to count - 2
        for j = 0 to count - i - 2
            if LCase( channels[ j ].name ) > LCase( channels[ j + 1 ].name )
                temp = channels[ j ]
                channels[ j ] = channels[ j + 1 ]
                channels[ j + 1 ] = temp
            end if
        end for
    end for
end sub

sub SortChannelsByNumber( channels as Object )
    count = channels.Count()
    if count < 2 then return
    for i = 0 to count - 2
        for j = 0 to count - i - 2
            if channels[ j ].number > channels[ j + 1 ].number
                temp = channels[ j ]
                channels[ j ] = channels[ j + 1 ]
                channels[ j + 1 ] = temp
            end if
        end for
    end for
end sub

function QueryParentalControlStatus() as Boolean
    locked = false
    m3uUrl = m.global.feed_url
    if m3uUrl = "" then return false
    
    baseM3u = ""
    lastSlash = -1
    for i = m3uUrl.Len() - 1 to 0 step -1
        if m3uUrl.Mid( i, 1 ) = "/"
            lastSlash = i
            exit for
        end if
    end for
    if lastSlash <> -1
        baseM3u = m3uUrl.Mid( 0, lastSlash + 1 )
    end if
    
    if baseM3u <> ""
        statusUrl = baseM3u + "lock.php"
        
        transfer = CreateObject( "roUrlTransfer" )
        transfer.EnablePeerVerification( false )
        transfer.SetURL( statusUrl )
        jsonText = transfer.GetToString()
        if jsonText <> ""
            response = ParseJson( jsonText )
            if response <> invalid and response.locked <> invalid
                locked = response.locked
            end if
        end if
    end if
    
    return locked
end function

function LoadTranslations( lang as string ) as Object
	translations = {}
	filePath = "pkg:/locale/" + lang + ".xml"
	xmlStr = ReadAsciiFile( filePath )
	if xmlStr <> ""
		xml = CreateObject( "roXMLElement" )
		if xml.Parse( xmlStr )
			strings = xml.GetNamedElements( "string" )
			for each s in strings
				id = s@id
				if id <> invalid and id <> ""
					translations[ id ] = s.GetText()
				end if
			end for
		else
			print "LoadTranslations: failed to parse XML"
		end if
	else
		print "LoadTranslations: XML file is empty or not found"
	end if
	return translations
end function
