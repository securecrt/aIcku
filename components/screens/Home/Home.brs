'
'	aIcku - another IPTV client for Roku OS
'	Copyright (C) 2024 Eric Kutcher
'	Copyright (C) 2026 Xin Wang
'	Released under the GPLv3 license.
'

sub Init()
'{
	m.pending_play_content = invalid
	m.pending_play_index = -2
	m.suppress_menu_on_stop = false
	m.switching_channel_remotely = false

	m.current_main_menu_content_index = -1	' Used to determine whether we need to load the Live TV, Movies, or TV Shows groups.

	m.main_menu = m.top.FindNode( "MainMenu" )
	m.group_menu = m.top.FindNode( "GroupMenu" )
	m.channel_menu = m.top.FindNode( "ChannelMenu" )
	m.channel_guide = m.top.FindNode( "ChannelGuide" )
	m.options = m.top.FindNode( "Options" )

	m.video_player = m.top.FindNode( "VideoPlayer" )
	m.video_player.width = m.global.preferred_screen_width
	m.video_player.height = m.global.preferred_screen_height

	m.channel_guide.video_player = m.video_player	' We'll adjust the video player's background position in the channel guide.

	m.main_menu.SetFocus( true )

	m.current_menu = m.main_menu

	m.main_menu.ObserveField( "menu_state", "OnMainMenuStateChanged" )
	m.group_menu.ObserveField( "menu_state", "OnGroupMenuStateChanged" )
	m.channel_menu.ObserveField( "menu_state", "OnChannelMenuStateChanged" )
	m.channel_guide.ObserveField( "menu_state", "OnChannelGuideStateChanged" )
	m.options.ObserveField( "menu_state", "OnOptionsStateChanged" )

	m.main_menu.ObserveField( "content_index", "OnMainMenuItemSelected" )
	m.group_menu.ObserveField( "content_index", "OnGroupContentChange" )
	m.channel_menu.ObserveField( "content_index", "OnChannelSelected" )
	m.channel_guide.ObserveField( "content_index", "OnGuideChannelSelected" )

	m.group_menu.ObserveField( "update_content", "OnUpdateGroupContent" )
	m.channel_menu.ObserveField( "update_content", "OnUpdateChannelContent" )
	m.channel_guide.ObserveField( "update_content", "OnUpdateEPGContent" )

	m.video_player.video.ObserveField( "state", "OnVideoStateChange" )
	m.video_player.video.ObserveField( "globalCaptionMode", "OnGlobalCaptionModeChange" )
	m.global.ObserveField( "parental_control_active", "OnParentalControlActiveChange" )
	m.global.ObserveField( "translations", "UpdateLang" )

	m.socket_server = m.top.FindNode( "SocketServerTask" )
	m.socket_server.ObserveField( "control_command", "OnServerControlCommand" )
	m.socket_server.control = "run"

	m.epg_update_timer = CreateObject( "roSGNode", "Timer" )
	m.epg_update_timer.repeat = true
	m.epg_update_timer.duration = 30
	m.epg_update_timer.ObserveField( "fire", "UpdateSocketServerTitle" )
	m.epg_update_timer.control = "start"

	''''''''''''''''''''''''

	m.channel_number_timer = CreateObject( "roSGNode", "Timer" )
	m.channel_number_timer.repeat = false
	m.channel_number_timer.duration = 3
	m.channel_number_timer.ObserveField( "fire", "HandleChannelNumberInput" )

	m.channel_number_background = CreateObject( "roSGNode", "Rectangle" )
	m.channel_number_background.translation = [ m.global.overscan_offset_x + m.global.screen_width - 20, m.global.overscan_offset_y + 20 ]
	m.channel_number_background.color = m.global.panel_color

		m.channel_number = CreateObject( "roSGNode", "Label" )
		m.channel_number.numLines = 1
		m.channel_number.translation = [ 10, 10 ]
		m.channel_number.vertAlign = "center"
		m.channel_number.horizAlign = "right"
		m.channel_number.font = CreateChineseFont( 36 )
		m.channel_number.text = ""
		m.channel_number_background.AppendChild( m.channel_number )

	m.top.AppendChild( m.channel_number_background )

	m.channel_number_background.visible = false

	''''''''''''''''''''''''

	m.video_content_type = -1

	''''''''''''''''''''''''

	m.show_channel_menu = true	' We can turn it off when loading an inputted/resuming channel number.

	m.load_channel_type = 0	' 0 = Resuming Channel, 1 = Input Channel
	m.loading_channel = false

	if m.global.resume_channel = true
	'{
		m.load_channel_type = 0	' Resuming Channel
		m.loading_channel = true

		' m.global.channel_group_id and m.global.channel_number will have been set in main.
		m.global.load_channel = true
	'}
	else
	'{
		m.main_menu.menu_state = 1	' Start by opening the main menu.
	'}
	end if
'}
end sub

' ---------------------------------------- '
' Handle the opening/closing of menu items '
' ---------------------------------------- '
sub OnMainMenuStateChanged()
'{
	m.current_menu = m.main_menu

	if m.main_menu.menu_state = 0
	'{
		m.main_menu.visible = false
		m.video_player.SetFocus( true )
	'}
	else if m.main_menu.menu_state = 1
	'{
		m.main_menu.visible = true
		m.main_menu.SetFocus( true )
	'}
	end if
'}
end sub

sub OnGroupMenuStateChanged()
'{
	m.current_menu = m.group_menu

	if m.group_menu.menu_state = 0
	'{
		m.group_menu.visible = false
		m.video_player.SetFocus( true )
	'}
	else if m.group_menu.menu_state = 1
	'{
		m.group_menu.visible = true
		m.group_menu.SetFocus( true )
	'}
	else if m.group_menu.menu_state = -1
	'{
		m.group_menu.visible = false

		if m.switching_channel_remotely <> true
			m.main_menu.menu_state = 1
		end if
	'}
	end if
'}
end sub

sub OnChannelMenuStateChanged()
'{
	m.current_menu = m.channel_menu

	if m.channel_menu.menu_state = 0
	'{
		m.channel_menu.visible = false
		m.video_player.SetFocus( true )
	'}
	else if m.channel_menu.menu_state = 1
	'{
		m.channel_menu.visible = true
		m.channel_menu.SetFocus( true )
	'}
	else if m.channel_menu.menu_state = -1
	'{
		m.channel_menu.visible = false

		if m.switching_channel_remotely <> true
			m.group_menu.menu_state = 1
		end if
	'}
	end if
'}
end sub

sub OnChannelGuideStateChanged()
'{
	if m.channel_guide.menu_state = 0
	'{
		m.channel_guide.visible = false
		m.video_player.SetFocus( true )
	'}
	else if m.channel_guide.menu_state = 1
	'{
		m.channel_guide.visible = true
		m.channel_guide.SetFocus( true )
	'}
	end if
'}
end sub


sub OnOptionsStateChanged()
'{
	if m.options.menu_state = 0
	'{
		m.options.visible = false

		if m.switching_channel_remotely <> true
			m.main_menu.menu_state = 1
		end if
	'}
	else if m.options.menu_state = 1
	'{
		m.options.visible = true
		m.options.SetFocus( true )
	'}
	end if
'}
end sub
' ---------------------------------------- '
' ---------------------------------------- '
' ---------------------------------------- '

' ---------------------------------------- '
' Initiate loading of groups/content.      '
' ---------------------------------------- '
sub OnMainMenuItemSelected()
'{
	m.current_menu = m.main_menu
	m.main_menu.visible = false

	if m.main_menu.content_index = 0 ' Live TV
	'{
		' If the current menu is different from the last one that we were in, then we need to request the new menu's group content.
		if m.current_main_menu_content_index <> m.main_menu.content_index
		'{
			m.global.current_content_type = 0

			m.top.content = invalid
			m.top.group_content = invalid

			m.global.loading_content = true
			m.global.group_id = 0
			m.global.group_content_offset = 0
			m.global.load_group_chunk = true
		'}
		end if

		m.current_main_menu_content_index = m.main_menu.content_index

		m.group_menu.menu_state = 1	' Show
	'}
	else if m.main_menu.content_index = 1	' Options
	'{
		m.options.menu_state = 1	' Show
	'}
	end if
'}
end sub

sub OnGroupContentChange()
'{
	if m.switching_channel_remotely = true then return

	if m.group_menu.content_index >= 0
	'{
		' We don't know if this ID is for group or channel/VOD content, but it'll be determined when the request is fulfilled.
		m.global.request_id = m.group_menu.content.GetChild( m.group_menu.content_index ).group_id

		if m.current_main_menu_content_index = 0 and ( m.channel_menu.content = invalid or m.channel_menu.content <> invalid and m.channel_menu.content.group_id <> m.global.request_id )
		'{
			m.global.loading_content = true
			m.global.content_offset = -( Int( m.global.content_limit / 2 ) )
			m.global.load_request = true
		'}
		else
		'{
			m.current_menu = m.group_menu
			m.group_menu.visible = false

			if m.current_main_menu_content_index = 0
			'{
				m.channel_menu.menu_state = 1	' Show
			'}
			end if
		'}
		end if
	'}
	end if
'}
end sub
' ---------------------------------------- '
' ---------------------------------------- '
' ---------------------------------------- '

' ---------------------------------------- '
' Request the next group/content/epg chunk '
' ---------------------------------------- '
sub OnUpdateGroupContent()
'{
	if m.group_menu.update_content = true
	'{
		m.group_menu.update_content = false

		m.global.loading_content = true
		m.global.group_content_offset = m.group_menu.content_offset
		m.global.load_group_chunk = true
	'}
	end if
'}
end sub

sub OnUpdateChannelContent()
'{
	if m.channel_menu.update_content = true
	'{
		m.channel_menu.update_content = false

		m.global.loading_content = true
		m.global.content_offset = m.channel_menu.content_offset
		m.global.load_content_chunk = true
	'}
	end if
'}
end sub

sub OnUpdateEPGContent()
'{
	if m.channel_guide.update_content = true
	'{
		m.channel_guide.update_content = false

		m.global.loading_epg = true
		m.global.epg_content_offset = m.channel_guide.content_offset
		m.global.load_epg_chunk = true
	'}
	end if
'}
end sub
' ---------------------------------------- '
' ---------------------------------------- '
' ---------------------------------------- '

' ---------------------------------------- '
' Set the menu/guide's loaded content      '
' ---------------------------------------- '
sub OnLoadGroupContent()
'{
	m.global.loading_content = false

	if m.loading_channel = true
	'{
		m.loading_channel = false

		m.group_menu.content = m.top.group_content

		m.show_channel_menu = false

		' Load the TV Channel list.
		m.global.request_id = m.global.channel_group_id
		m.global.loading_content = true
		m.global.content_offset = -( Int( m.global.content_limit / 2 ) )
		m.global.load_request = true
	'}
	else	' For every other request, set the group menu's group content.
	'{
		m.group_menu.content = m.top.group_content
	'}
	end if
'}
end sub

sub OnLoadContent()
'{
	m.global.loading_content = false

	m.loading_channel = false

	if m.top.content <> invalid
	'{
		if m.show_channel_menu = true
		'{
			m.current_menu = m.group_menu
			m.group_menu.visible = false
		'}
		end if

		if m.current_main_menu_content_index = 0
		'{
			' Have we changed groups? If so, then clear the guide.
			clear_guide = false
			if m.channel_menu.content <> invalid and m.channel_menu.content.group_id <> m.top.content.group_id
			'{
				clear_guide = true
			'}
			end if

			m.channel_menu.content = m.top.content

			' The channel guide is not open and the channel menu doesn't want us to refresh the channel guide.
			if m.channel_guide.menu_state <> 1 and m.channel_menu.refresh = false
			'{
				if clear_guide = true
				'{
					m.channel_guide.content = invalid
				'}
				end if

				if m.show_channel_menu = true
				'{
					m.channel_menu.menu_state = 1	' Show
				'}
				else
				'{
					if m.load_channel_type = 0	' Resuming Channel
					'{
						m.current_menu = m.channel_menu
						m.video_player.SetFocus( true )
					'}
					end if
				'}
				end if
			'}
			else	' If the channel guide is open, then the last opened menu will have been the channel menu.
			'{
				' Does the channel menu want us to refresh the channel guide?
				if m.channel_menu.refresh = true
				'{
					m.channel_menu.refresh = false

					' Reload the channel guide content only if it has already been loaded.
					if m.global.loading_epg = false and m.channel_guide.content <> invalid
					'{
						m.channel_guide.reload_content = true
					'}
					end if
				'}
				end if

				m.current_menu = m.channel_menu
			'}
			end if
		'}
		end if
	'}
	end if

	m.show_channel_menu = true	' Default to true
'}
end sub

sub OnLoadEPGContent()
'{
	m.global.loading_epg = false

	m.channel_guide.content = m.top.epg_content

    UpdateSocketServerTitle()

	if m.channel_guide.refresh = true
	'{
		m.channel_guide.refresh = false

		m.channel_menu.reload_content = true
	'}
	end if
'}
end sub

sub OnLoadDetailsContent()
'{
	loading_details = m.global.loading_details

	m.global.loading_details = 0

	if loading_details = 2		' Loading details for video player info.
	'{
		m.video_player.details_content = m.top.details_content
	'}
	else if loading_details = 3		' Loading details for Group menu.
	'{
		m.group_menu.details_content = m.top.details_content
	'}
	end if
'}
end sub

sub OnLoadChannelContent()
'{
	channel_content = m.top.channel_content

	if channel_content <> invalid and channel_content.GetChildCount() = 2
	'{
		m.global.current_content_type = 0	' Live TV

		m.current_main_menu_content_index = 0	' Live TV

		''''''''''''''''''''''''

		' Play the TV channel that was last played.
		content = channel_content.GetChild( 0 )

		m.pending_play_content = content
		m.pending_play_index = -1

		m.global.check_parental_control = true

		''''''''''''''''''''''''

		' The group tree that would need to be entered in order to reach the channel.
		group_content = channel_content.GetChild( 1 )
		if group_content.GetChildCount() > 0
		'{
			' The group that the TV Channel is in.
			if m.global.channel_group_id <> m.global.request_id	' Load new group.
			'{
				' Recreates the Group Menu's group tree so we can navigate back.
				m.group_menu.enter_group_content = channel_content.GetChild( 1 )
			'}
			else	' Group already loaded.
			'{
				if m.channel_menu.content = invalid or m.channel_menu.content <> invalid and m.channel_menu.content.group_id <> m.global.request_id	' Load channel list.
				'{
					m.show_channel_menu = false

					' Load the TV Channel list.
					m.global.loading_content = true
					m.global.content_offset = -( Int( m.global.content_limit / 2 ) )
					m.global.load_request = true
				'}
				else	' Channel list already loaded.
				'{
					m.loading_channel = false
				'}
				end if
			'}
			end if
		'}
		else	' This shouldn't happen.
		'{
			m.loading_channel = false

			if m.load_channel_type = 0	' Resuming Channel
			'{
				m.main_menu.menu_state = 1	' Start by opening the main menu.
			'}
			end if
		'}
		end if
	'}
	else	' Failed to retreive the channel content.
	'{
		m.loading_channel = false

		if m.load_channel_type = 0	' Resuming Channel
		'{
			m.main_menu.menu_state = 1	' Start by opening the main menu.
		'}
		end if
	'}
	end if
'}
end sub
' ---------------------------------------- '
' ---------------------------------------- '
' ---------------------------------------- '

sub OnVideoStateChange()
'{
    UpdateSocketServerTitle()
    
    state = m.video_player.video.state
    if state = "playing"
        m.suppress_menu_on_stop = false
        m.switching_channel_remotely = false
    end if
    
    if m.loading_channel = true then return

	if state = "stopped" or state = "finished" or state = "error"
	'{
        if m.suppress_menu_on_stop = true or m.switching_channel_remotely = true
            m.suppress_menu_on_stop = false
            m.switching_channel_remotely = false
            return
        end if
		' If the channel guide is open and we play a video that stops/fails, then we want to keep the guide open and not display the previously opened menu.
		if m.channel_guide.menu_state <> 1
		'{
			m.current_menu.menu_state = 1	' Show
		'}
		else
		'{
			' The video player will hide the video options and video info menus whether they're open or not and set the focus back to itself.
			' This will ensure that the channel guide retains its focus while it's opened.
			m.channel_guide.SetFocus( true )
		'}
		end if
	'}
	end if
'}
end sub		

sub OnGlobalCaptionModeChange()
'{
	' The channel guide will adjust the video player dimensions so don't override it here.
	if m.channel_guide.visible = false
	'{
		if m.video_player.video.globalCaptionMode = "Off"
		'{
			m.video_player.video.width = m.global.screen_width
			m.video_player.video.height = m.global.screen_height
			m.video_player.video.translation = [ m.global.overscan_offset_x, m.global.overscan_offset_y ]
		'}
		else
		'{
			m.video_player.video.width = 0
			m.video_player.video.height = 0
			m.video_player.video.translation = [ 0, 0 ]
		'}
		end if
	'}
	end if
'}
end sub

sub PlayVideoContent( content as object, content_index as integer )
'{
	m.pending_play_content = content
	m.pending_play_index = content_index

	m.global.check_parental_control = true
'}
end sub

sub OnChannelSelected()
'{
    if m.switching_channel_remotely = true then return
	PlayVideoContent( m.channel_menu.content, m.channel_menu.content_index )
'}
end sub

sub OnGuideChannelSelected()
'{
	PlayVideoContent( m.channel_guide.content, m.channel_guide.content_index )
'}
end sub

sub OnTVIsOff()
'{
	' Triggered from the main thread when the TV is turned off. HDMI is detected as being unplugged.
	if m.top.tv_is_off = true
	'{
		m.top.tv_is_off = false

		if m.video_content_type = 0	' Live TV
		'{
			m.video_player.video.control = "stop"
		'}
		end if
	'}
	end if
'}
end sub

sub HandleChannelNumberInput()
'{
	channel_number = m.channel_number.text.ToInt()

	' Only switch if the channel number is different.
	if channel_number <> m.global.channel_number or m.video_player.video.state = "none" or m.video_player.video.state = "stopped" or m.video_player.video.state = "finished" or m.video_player.video.state = "error"
	'{
		channel_group_id = 1	' All group

		m.load_channel_type = 1	' Input Channel
		m.loading_channel = true

		' Save the last channel info so we can a/b.
		m.global.last_channel_group_id = m.global.channel_group_id
		m.global.last_channel_number = m.global.channel_number

		m.global.channel_group_id = channel_group_id
		m.global.channel_number = channel_number
		m.global.load_channel = true
	'}
	end if

	m.channel_number_background.visible = false
	m.channel_number.text = ""
'}
end sub

function OnKeyEvent( key as string, press as boolean ) as boolean
'{
	if press
	'{
		if key = "back"
		'{
			if m.video_player.video.state = "playing"
			'{
				m.video_player.video.control = "pause"
			'}
			else if m.video_player.video.state = "paused" or m.video_player.video.state = "buffering"
			'{
				m.video_player.video.control = "stop"
			'}
			end if
		'}
		else if key = "play"
		'{
			if m.video_player.video.state = "playing"
			'{
				m.video_player.video.control = "pause"
			'}
			else if m.video_player.video.state = "paused"
			'{
				m.video_player.video.control = "resume"
			'}
			end if
		'}
		else if key = "left"
		'{
			m.current_menu.menu_state = 1	' Show
		'}
		else if key = "right"
		'{
			if m.current_main_menu_content_index = 0 ' Only show the guide if it's for Live TV.
			'{
				m.current_menu.visible = false	' Retain the current menu's state.

				if m.global.loading_epg = false and m.channel_guide.content = invalid
				'{
					m.global.loading_epg = true
					m.global.epg_content_offset = -( Int( m.global.epg_content_limit / 2 ) )
					m.global.load_epg_chunk = true
				'}
				end if

				m.channel_guide.menu_state = 1	' Show
			'}
			end if
		'}
		else if key = "replay"
		'{
			if m.current_main_menu_content_index = 0 ' Only switch channel numbers if it's for Live TV.
			'{
				channel_number_group_id = m.global.last_channel_group_id
				channel_number = m.global.last_channel_number

				' Make sure the channel info is different.
				if channel_number_group_id <> -1 and channel_number <> -1 and channel_number <> m.global.channel_number
				'{
					m.load_channel_type = 1	' Input Channel
					m.loading_channel = true

					' Save the last channel info so we can a/b.
					m.global.last_channel_group_id = m.global.channel_group_id
					m.global.last_channel_number = m.global.channel_number

					m.global.channel_group_id = channel_number_group_id
					m.global.channel_number = channel_number
					m.global.load_channel = true
				'}
				end if
			'}
			end if
		'}
		else if key = "Lit_1" or key = "Lit_2" or key = "Lit_3" or key = "Lit_4" or key = "Lit_5" or key = "Lit_6" or key = "Lit_7" or key = "Lit_8" or key = "Lit_9" or key = "Lit_0"
		'{
			if m.current_main_menu_content_index = 0 ' Only show channel numbers if it's for Live TV.
			'{
				m.channel_number.text = m.channel_number.text + Right( key, 1 )
				m.channel_number_background.width = m.channel_number.boundingRect()[ "width" ] + 20
				m.channel_number_background.height = m.channel_number.boundingRect()[ "height" ] + 15	' It's not exactly centered.
				m.channel_number_background.translation = [ m.global.overscan_offset_x + m.global.screen_width - ( m.channel_number_background.width + 20 ), m.global.overscan_offset_y + 20 ]

				m.channel_number_background.visible = true

				m.channel_number_timer.control = "start"
			'}
			end if
		'}
		end if
	'}
	end if

	return true
'}
end function

sub ActuallyPlayVideoContent( content as object, content_index as integer )
'{
	if content <> invalid and content_index >= 0 and content.GetChildCount() > content_index
	'{
		content = content.GetChild( content_index )

		' Resume VOD Movies and TV Shows if they errored.
		if ( m.video_content_type = 1 or m.video_content_type = 2 ) and ( m.video_player.content <> invalid and m.video_player.content.isSameNode( content ) and m.video_player.video.state = "error" )
		'{
			m.video_player.resume = true
		'}
		else
		'{
			m.video_content_type = m.global.current_content_type

			m.video_player.content = content

			m.video_player.video.content.Title = content.Title
			m.video_player.video.content.Url = content.Url
			m.video_player.video.content.StreamFormat = content.StreamFormat
			m.video_player.video.content.HttpHeaders = content.HttpHeaders

			if m.video_content_type = 0	' Live TV
			'{
				m.video_player.video.content.SubtitleConfig = { TrackName: "eia608/1" }	' Closed captioning.
			'}
			else
			'{
				m.video_player.video.content.SubtitleConfig = content.SubtitleConfig
			'}
			end if

			m.video_player.video.control = "play"
		'}
		end if
	'}
	end if
'}
end sub

sub OnParentalControlActiveChange()
'{
    if m.global.parental_control_active = true
    '{
        ' Immediately stop any active playback
        if m.video_player.video.state = "playing" or m.video_player.video.state = "paused" or m.video_player.video.state = "buffering"
        '{
            m.video_player.video.control = "stop"
        '}
        end if

        ' Show parental control dialog
        dialog = CreateObject( "roSGNode", "Dialog" )
        dialog.id = "ParentalControlDialog"
        dialog.title = _tr( "parental_control_lock" )
        dialog.titleFont = CreateChineseFont( 36 )
        dialog.message = _tr( "parental_control_active_msg" )
        dialog.messageFont = CreateChineseFont( 28 )
        dialog.buttons = [ "OK" ]
        
        buttonGroup = dialog.findNode("buttonGroup")
        if buttonGroup <> invalid
            buttonGroup.textFont = CreateChineseFont( 28 )
            buttonGroup.focusedTextFont = CreateChineseFont( 28 )
        end if
        
        dialog.ObserveField( "buttonSelected", "OnParentalControlDialogClose" )
        m.top.GetScene().dialog = dialog
        
        ' Clear pending play info
        m.pending_play_content = invalid
        m.pending_play_index = -2
    '}
    else
    '{
        ' Dismiss lock dialog if active
        scene = m.top.GetScene()
        if scene.dialog <> invalid and scene.dialog.id = "ParentalControlDialog"
        '{
            scene.dialog = invalid
        '}
        end if

        ' Unlocked - play pending content if any
        if m.pending_play_content <> invalid
        '{
            if m.pending_play_index = -1
            '{
                ' Resume channel logic
                m.video_content_type = 0
                m.video_player.content = m.pending_play_content
                m.video_player.video.content.Title = m.pending_play_content.Title
                m.video_player.video.content.Url = m.pending_play_content.Url
                m.video_player.video.content.StreamFormat = m.pending_play_content.StreamFormat
                m.video_player.video.content.HttpHeaders = m.pending_play_content.HttpHeaders
                m.video_player.video.content.SubtitleConfig = { TrackName: "eia608/1" }
                m.video_player.video.control = "play"
            '}
            else if m.pending_play_index >= 0
            '{
                ActuallyPlayVideoContent( m.pending_play_content, m.pending_play_index )
            '}
            end if
            
            m.pending_play_content = invalid
            m.pending_play_index = -2
        '}
        end if
    '}
    end if
'}
end sub

sub UpdateLang()
    scene = m.top.GetScene()
    if scene.dialog <> invalid and scene.dialog.id = "ParentalControlDialog"
        scene.dialog.title = _tr( "parental_control_lock" )
        scene.dialog.message = _tr( "parental_control_active_msg" )
    end if
end sub

sub OnParentalControlDialogClose()
'{
    m.top.GetScene().dialog = invalid
'}
end sub

sub OnServerControlCommand()
'{
    command = m.socket_server.control_command
    if command = "stop"
        ' Force stop video playback
        if m.video_player.video.state = "playing" or m.video_player.video.state = "paused" or m.video_player.video.state = "buffering"
        '{
            m.video_player.video.control = "stop"
        '}
        end if
        ' Trigger parental lock
        m.global.parental_control_active = true
    else if command = "lock"
        m.global.parental_control_active = true
    else if command = "unlock"
        m.global.parental_control_active = false
    else if command.Left(12) = "play_number:"
        channel_number = command.Mid(12).ToInt()
        if channel_number > 0
            m.switching_channel_remotely = true
            ' Close any active menus and focus on video player
            m.main_menu.menu_state = 0
            m.group_menu.menu_state = 0
            m.channel_menu.menu_state = 0
            m.channel_guide.menu_state = 0
            m.options.menu_state = 0
            m.video_player.SetFocus(true)
            
            m.show_channel_menu = false
            m.suppress_menu_on_stop = true
            
            channel_group_id = 1    ' All group
            m.load_channel_type = 1 ' Input Channel
            m.loading_channel = true
            m.global.last_channel_group_id = m.global.channel_group_id
            m.global.last_channel_number = m.global.channel_number
            m.global.channel_group_id = channel_group_id
            m.global.channel_number = channel_number
            m.global.load_channel = true
        end if
    end if
'}
end sub

sub UpdateSocketServerTitle()
'{
    if m.socket_server <> invalid and m.video_player <> invalid and m.video_player.video <> invalid
    '{
        state = m.video_player.video.state
        m.socket_server.video_state = state
        if m.video_player.video.content <> invalid and m.video_player.video.content.title <> invalid
        '{
            channelTitle = m.video_player.video.content.title
            programTitle = GetCurrentProgramTitle(m.video_player.content)
            if programTitle <> ""
            '{
                m.socket_server.video_title = channelTitle + " - " + programTitle
            '}
            else
            '{
                m.socket_server.video_title = channelTitle
            '}
            end if
        '}
        else
        '{
            m.socket_server.video_title = ""
        '}
        end if
    '}
    end if
'}
end sub

function GetCurrentProgramTitle(channelContent as Object) as String
    if channelContent = invalid then return ""
    
    channelName = channelContent.title
    if channelName = "" or channelName = invalid then return ""
    
    guideContent = m.top.epg_content
    if guideContent = invalid then return ""
    
    guideChannel = invalid
    for i = 0 to guideContent.GetChildCount() - 1
        chNode = guideContent.GetChild(i)
        if chNode <> invalid and chNode.title = channelName
            guideChannel = chNode
            exit for
        end if
    end for
    
    if guideChannel = invalid then return ""
    
    count = guideChannel.GetChildCount()
    if count = 0 then return ""
    
    date_time = CreateObject( "roDateTime" )
    date_time.Mark()
    nowTime = date_time.AsSeconds()
    
    for i = 0 to count - 1
        program = guideChannel.GetChild(i)
        if program <> invalid and program.start_time <> invalid and program.end_time <> invalid
            if nowTime >= program.start_time and nowTime < program.end_time
                if program.Title <> invalid then return program.Title
            end if
        end if
    end for
    
    return ""
end function
