'
'	aIcku - another IPTV client for Roku OS
'	Copyright (C) 2024 Eric Kutcher
'	Copyright (C) 2026 Xin Wang
'	Released under the GPLv3 license.
'

sub Init()
'{
	m.top.visible = false

	m.button_background_color = "0x002040E0"
	m.button_color = "0x80808020"
	m.button_selected_color = "0xFFFFFF30"

	m.item_selected = 0

	m.panel = CreateObject( "roSGNode", "Rectangle" )
	m.panel.color = m.global.panel_color
	m.panel.width = m.global.screen_width
	m.panel.height = m.global.screen_height
	m.panel.translation = [ m.global.overscan_offset_x, m.global.overscan_offset_y ]

	m.title = CreateObject( "roSGNode", "Label" )
	m.title.width = m.global.screen_width
	m.title.height = 100
	m.title.horizAlign = "center"
	m.title.vertAlign = "center"
	m.title.font = CreateChineseFont( 36 )
	m.title.text = "Options"

	m.panel.AppendChild( m.title )

	row_line = CreateObject( "roSGNode", "Rectangle" )
	row_line.width = m.global.screen_width
	row_line.height = 3
	row_line.translation = [ 0, 100 ]
	row_line.color = "#FFFFFFFF"

	m.panel.AppendChild( row_line )

	''''''''''''''''''''''''

	m.palette = CreateObject( "roSGNode", "RSGPalette" )
	m.palette.colors = { DialogBackgroundColor: "0x001020E0",
					     DialogItemColor: "0xFFFFFFFF",
					     DialogTextColor: "0xFFFFFFFF",
					     DialogFocusColor: "0xFFFFFFFF",
					     DialogFocusItemColor: "0x002040E0",
					     DialogSecondaryTextColor: "0x80808020",
					     DialogSecondaryItemColor: "0x80808020",
					     DialogInputFieldColor: "0x80808020",
					     DialogKeyboardColor: "0x80808020",
					     DialogFootprintColor: "0x80808020" }

	m.top.GetScene().palette = m.palette

	m.keyboard_dialog = CreateObject( "roSGNode", "StandardKeyboardDialog" )
	m.keyboard_dialog.text = m.global.feed_url
	m.keyboard_dialog.textEditBox.cursorPosition = -1
	m.keyboard_dialog.textEditBox.maxTextLength = 2083
	m.keyboard_dialog.title = "Enter The Feed URL"
	m.keyboard_dialog.buttons = [ "OK", "Cancel" ]

	m.keyboard_dialog.ObserveField( "buttonSelected", "OnKeyboardDialogButtonSelection" )
	m.keyboard_dialog.ObserveField( "wasClosed", "OnKeyboardDialogClosed" )

	m.drawing_styles = {
		"icon": {
			"fontSize": 48
			"fontUri": "pkg:/components/fonts/aIcku.ttf"
			"color": "#FFFFFFFF"
		}
		"default": {
			"fontUri": GetChineseFontUri()
			"fontSize": 24
			"color": "#FFFFFFFF"
		}
	}

	label_height = 75

	''''''''''''''''''''''''

	m.options_columns = CreateObject( "roSGNode", "Rectangle" )
	m.options_columns.width = m.global.screen_width
	m.options_columns.height = 800
	m.options_columns.translation = [ 0, 105 ]
	m.options_columns.color = "0x00000000"



	' Feed URL

		m.label_feed = CreateObject( "roSGNode", "Label" )
		m.label_feed.height = label_height
		m.label_feed.translation = [ 20, 20 ]
		m.label_feed.vertAlign = "center"
		m.label_feed.font = CreateChineseFont( 24 )
		m.label_feed.text = "Feed URL:"

	m.options_columns.AppendChild( m.label_feed )


		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.height = label_height
		column_background.translation = [ 20, 20 + label_height ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		option_1 = CreateObject( "roSGNode", "Rectangle" )
		option_1.height = label_height
		option_1.width = m.global.screen_width - 40
		option_1.translation = [ 20, 20 + label_height ]
		option_1.color = m.button_selected_color

			button = CreateObject( "roSGNode", "ScrollingLabel" )
			button.height = label_height
			button.translation = [ 20, 0 ]
			button.vertAlign = "center"
			button.font = CreateChineseFont( 24 )
			button.text = m.global.feed_url
			button.maxWidth = option_1.width - 40

		column_background.width = option_1.width

		option_1.AppendChild( button )

	m.options_columns.AppendChild( option_1 )

	y_offset = option_1.boundingRect()[ "y" ] + option_1.boundingRect()[ "height" ]


	' Automatic Subtitles
	

		m.auto_subs_icon = CreateObject( "roSGNode", "MultiStyleLabel" )
		m.auto_subs_icon.height = label_height
		m.auto_subs_icon.translation = [ 20, 20 + y_offset ]
		m.auto_subs_icon.vertAlign = "center"
		m.auto_subs_icon.drawingStyles = m.drawing_styles
		if m.global.enable_automatic_subtitles = false
		'{
			m.auto_subs_icon.text = "<icon>" + chr( 59660 ) + "</icon>"	' Checkbox Unchecked
		'}
		else
		'{
			m.auto_subs_icon.text = "<icon>" + chr( 59661 ) + "</icon>"	' Checkbox Checked
		'}
		end if

	m.options_columns.AppendChild( m.auto_subs_icon )

		m.auto_subs_bg = CreateObject( "roSGNode", "Rectangle" )
		m.auto_subs_bg.height = label_height
		m.auto_subs_bg.translation = [ 20 + m.auto_subs_icon.boundingRect()[ "width" ] + 20, 20 + y_offset ]
		m.auto_subs_bg.color = m.button_background_color

	m.options_columns.AppendChild( m.auto_subs_bg )

		option_2 = CreateObject( "roSGNode", "Rectangle" )
		option_2.height = label_height
		option_2.translation = [ 20 + m.auto_subs_icon.boundingRect()[ "width" ] + 20, 20 + y_offset ]
		option_2.color = m.button_color

			m.auto_subs_label = CreateObject( "roSGNode", "MultiStyleLabel" )
			m.auto_subs_label.height = label_height
			m.auto_subs_label.translation = [ 20, 0 ]
			m.auto_subs_label.vertAlign = "center"
			m.auto_subs_label.drawingStyles = m.drawing_styles
			m.auto_subs_label.text = "Enable Automatic Subtitles"
			option_2.AppendChild( m.auto_subs_label )

		option_2.width = m.auto_subs_label.boundingRect()[ "width" ] + 40
		m.auto_subs_bg.width = option_2.width


	m.options_columns.AppendChild( option_2 )

	y_offset = option_2.boundingRect()[ "y" ] + option_2.boundingRect()[ "height" ]



	' Sort Type

		m.label_sort = CreateObject( "roSGNode", "Label" )
		m.label_sort.height = label_height
		m.label_sort.translation = [ 20, 20 + y_offset ]
		m.label_sort.vertAlign = "center"
		m.label_sort.font = CreateChineseFont( 24 )
		m.label_sort.text = "Sort channels by:"

	m.options_columns.AppendChild( m.label_sort )

		m.channel_sort_type_1 = CreateObject( "roSGNode", "MultiStyleLabel" )
		m.channel_sort_type_1.height = label_height
		m.channel_sort_type_1.translation = [ 20, 20 + y_offset + label_height ]
		m.channel_sort_type_1.vertAlign = "center"
		m.channel_sort_type_1.drawingStyles = m.drawing_styles
		m.channel_sort_type_1.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked

	m.options_columns.AppendChild( m.channel_sort_type_1 )

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.height = label_height
		column_background.translation = [ 20 + m.channel_sort_type_1.boundingRect()[ "width" ] + 20, 20 + y_offset + label_height ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		option_3 = CreateObject( "roSGNode", "Rectangle" )
		option_3.height = label_height
		option_3.translation = [ 20 + m.channel_sort_type_1.boundingRect()[ "width" ] + 20, 20 + y_offset + label_height ]
		option_3.color = m.button_color

			m.stream_type_number = CreateObject( "roSGNode", "MultiStyleLabel" )
			m.stream_type_number.height = label_height
			m.stream_type_number.translation = [ 20, 0 ]
			m.stream_type_number.vertAlign = "center"
			m.stream_type_number.drawingStyles = m.drawing_styles
			m.stream_type_number.text = "Number"
			option_3.AppendChild( m.stream_type_number )

		option_3.width = m.stream_type_number.boundingRect()[ "width" ] + 40
		column_background.width = option_3.width

	m.options_columns.AppendChild( option_3 )


	channel_sort_type_2_offset = 20 + m.channel_sort_type_1.boundingRect()[ "width" ] + 20 + option_3.width

		m.channel_sort_type_2 = CreateObject( "roSGNode", "MultiStyleLabel" )
		m.channel_sort_type_2.height = label_height
		m.channel_sort_type_2.translation = [ channel_sort_type_2_offset + 20, 20 + y_offset + label_height ]
		m.channel_sort_type_2.vertAlign = "center"
		m.channel_sort_type_2.drawingStyles = m.drawing_styles
		m.channel_sort_type_2.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked

	m.options_columns.AppendChild( m.channel_sort_type_2 )

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.height = label_height
		column_background.translation = [ channel_sort_type_2_offset + 20 + m.channel_sort_type_2.boundingRect()[ "width" ] + 20, 20 + y_offset + label_height ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		option_4 = CreateObject( "roSGNode", "Rectangle" )
		option_4.height = label_height
		option_4.translation = [ channel_sort_type_2_offset + 20 + m.channel_sort_type_2.boundingRect()[ "width" ] + 20, 20 + y_offset + label_height ]
		option_4.color = m.button_color

			m.stream_type_name = CreateObject( "roSGNode", "MultiStyleLabel" )
			m.stream_type_name.height = label_height
			m.stream_type_name.translation = [ 20, 0 ]
			m.stream_type_name.vertAlign = "center"
			m.stream_type_name.drawingStyles = m.drawing_styles
			m.stream_type_name.text = "Name"
			option_4.AppendChild( m.stream_type_name )

		option_4.width = m.stream_type_name.boundingRect()[ "width" ] + 40
		column_background.width = option_4.width

	m.options_columns.AppendChild( option_4 )

	y_offset = option_3.boundingRect()[ "y" ] + option_3.boundingRect()[ "height" ]


	if m.global.channel_sort_type = 0
	'{
		m.channel_sort_type_1.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked
		m.channel_sort_type_2.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Buttno Unchecked
	'}
	else
	'{
		m.channel_sort_type_2.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked
		m.channel_sort_type_1.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked
	'}
	end if




	' Resume last channel.

		m.resume_channel_icon = CreateObject( "roSGNode", "MultiStyleLabel" )
		m.resume_channel_icon.height = label_height
		m.resume_channel_icon.translation = [ 20, 20 + y_offset ]
		m.resume_channel_icon.vertAlign = "center"
		m.resume_channel_icon.drawingStyles = m.drawing_styles
		if m.global.resume_channel = false
		'{
			m.resume_channel_icon.text = "<icon>" + chr( 59660 ) + "</icon>"	' Checkbox Unchecked
		'}
		else
		'{
			m.resume_channel_icon.text = "<icon>" + chr( 59661 ) + "</icon>"	' Checkbox Checked
		'}
		end if

	m.options_columns.AppendChild( m.resume_channel_icon )

		m.resume_channel_bg = CreateObject( "roSGNode", "Rectangle" )
		m.resume_channel_bg.height = label_height
		m.resume_channel_bg.translation = [ 20 + m.resume_channel_icon.boundingRect()[ "width" ] + 20, 20 + y_offset ]
		m.resume_channel_bg.color = m.button_background_color

	m.options_columns.AppendChild( m.resume_channel_bg )

		option_5 = CreateObject( "roSGNode", "Rectangle" )
		option_5.height = label_height
		option_5.translation = [ 20 + m.resume_channel_icon.boundingRect()[ "width" ] + 20, 20 + y_offset ]
		option_5.color = m.button_color

			m.resume_channel_label = CreateObject( "roSGNode", "MultiStyleLabel" )
			m.resume_channel_label.height = label_height
			m.resume_channel_label.translation = [ 20, 0 ]
			m.resume_channel_label.vertAlign = "center"
			m.resume_channel_label.drawingStyles = m.drawing_styles
			m.resume_channel_label.text = "Resume Channel Upon Startup"
			option_5.AppendChild( m.resume_channel_label )

		option_5.width = m.resume_channel_label.boundingRect()[ "width" ] + 40
		m.resume_channel_bg.width = option_5.width

	m.options_columns.AppendChild( option_5 )

	y_offset = option_5.boundingRect()[ "y" ] + option_5.boundingRect()[ "height" ]



	' UI Language
		m.label_ui_lang = CreateObject( "roSGNode", "Label" )
		m.label_ui_lang.height = label_height
		m.label_ui_lang.translation = [ 20, 20 + y_offset ]
		m.label_ui_lang.vertAlign = "center"
		m.label_ui_lang.font = CreateChineseFont( 24 )
		m.label_ui_lang.text = "UI Language:"

	m.options_columns.AppendChild( m.label_ui_lang )

		m.ui_lang_1 = CreateObject( "roSGNode", "MultiStyleLabel" )
		m.ui_lang_1.height = label_height
		m.ui_lang_1.translation = [ 20, 20 + y_offset + label_height ]
		m.ui_lang_1.vertAlign = "center"
		m.ui_lang_1.drawingStyles = m.drawing_styles
		m.ui_lang_1.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked

	m.options_columns.AppendChild( m.ui_lang_1 )

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.height = label_height
		column_background.translation = [ 20 + m.ui_lang_1.boundingRect()[ "width" ] + 20, 20 + y_offset + label_height ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		option_6 = CreateObject( "roSGNode", "Rectangle" )
		option_6.height = label_height
		option_6.translation = [ 20 + m.ui_lang_1.boundingRect()[ "width" ] + 20, 20 + y_offset + label_height ]
		option_6.color = m.button_color

			m.ui_lang_en = CreateObject( "roSGNode", "MultiStyleLabel" )
			m.ui_lang_en.height = label_height
			m.ui_lang_en.translation = [ 20, 0 ]
			m.ui_lang_en.vertAlign = "center"
			m.ui_lang_en.drawingStyles = m.drawing_styles
			m.ui_lang_en.text = "English"
			option_6.AppendChild( m.ui_lang_en )

		option_6.width = m.ui_lang_en.boundingRect()[ "width" ] + 40
		column_background.width = option_6.width

	m.options_columns.AppendChild( option_6 )


	ui_lang_2_offset = 20 + m.ui_lang_1.boundingRect()[ "width" ] + 20 + option_6.width

		m.ui_lang_2 = CreateObject( "roSGNode", "MultiStyleLabel" )
		m.ui_lang_2.height = label_height
		m.ui_lang_2.translation = [ ui_lang_2_offset + 20, 20 + y_offset + label_height ]
		m.ui_lang_2.vertAlign = "center"
		m.ui_lang_2.drawingStyles = m.drawing_styles
		m.ui_lang_2.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked

	m.options_columns.AppendChild( m.ui_lang_2 )

		column_background = CreateObject( "roSGNode", "Rectangle" )
		column_background.height = label_height
		column_background.translation = [ ui_lang_2_offset + 20 + m.ui_lang_2.boundingRect()[ "width" ] + 20, 20 + y_offset + label_height ]
		column_background.color = m.button_background_color

	m.options_columns.AppendChild( column_background )

		option_7 = CreateObject( "roSGNode", "Rectangle" )
		option_7.height = label_height
		option_7.translation = [ ui_lang_2_offset + 20 + m.ui_lang_2.boundingRect()[ "width" ] + 20, 20 + y_offset + label_height ]
		option_7.color = m.button_color

			m.ui_lang_cn = CreateObject( "roSGNode", "MultiStyleLabel" )
			m.ui_lang_cn.height = label_height
			m.ui_lang_cn.translation = [ 20, 0 ]
			m.ui_lang_cn.vertAlign = "center"
			m.ui_lang_cn.drawingStyles = m.drawing_styles
			m.ui_lang_cn.text = "中文"
			option_7.AppendChild( m.ui_lang_cn )

		option_7.width = m.ui_lang_cn.boundingRect()[ "width" ] + 40
		column_background.width = option_7.width

	m.options_columns.AppendChild( option_7 )

	y_offset = option_6.boundingRect()[ "y" ] + option_6.boundingRect()[ "height" ]


	if m.global.ui_lang = "en"
	'{
		m.ui_lang_1.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked
		m.ui_lang_2.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked
	'}
	else
	'{
		m.ui_lang_2.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked
		m.ui_lang_1.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked
	'}
	end if




	' Overscan adjustments.

		m.overscan_bg = CreateObject( "roSGNode", "Rectangle" )
		m.overscan_bg.height = label_height
		m.overscan_bg.translation = [ 20, 20 + y_offset ]
		m.overscan_bg.color = m.button_background_color

	m.options_columns.AppendChild( m.overscan_bg )

		option_8 = CreateObject( "roSGNode", "Rectangle" )
		option_8.height = label_height
		option_8.translation = [ 20, 20 + y_offset ]
		option_8.color = m.button_color

			m.overscan_label = CreateObject( "roSGNode", "Label" )
			m.overscan_label.height = label_height
			m.overscan_label.translation = [ 20, 0 ]
			m.overscan_label.vertAlign = "center"
			m.overscan_label.font = CreateChineseFont( 24 )
			m.overscan_label.text = "Adjust Overscan Coordinates..."

		option_8.width = m.overscan_label.boundingRect()[ "width" ] + 40
		m.overscan_bg.width = option_8.width

		option_8.AppendChild( m.overscan_label )

	m.options_columns.AppendChild( option_8 )

	''''''''''''''''''''''''

	m.panel.AppendChild( m.options_columns )
	m.top.AppendChild( m.panel )

	' Add this last so that it can overlap the options window.
	m.adjust_overscan = CreateObject( "roSGNode", "AdjustOverscan" )
	m.adjust_overscan.ObserveField( "menu_state", "OnAdjustOverscanStateChanged" )
	m.top.AppendChild( m.adjust_overscan )

	m.options = [ option_1, option_2, option_3, option_4, option_5, option_6, option_7, option_8 ]

	m.global.ObserveField( "translations", "UpdateLang" )
	UpdateLang()
'}
end sub

sub OnKeyboardDialogButtonSelection()
'{
	if m.keyboard_dialog.buttonSelected = 0	' OK button
	'{
		m.options[ 0 ].GetChild( 0 ).text = m.keyboard_dialog.text

		m.global.feed_url = m.keyboard_dialog.text
	'}
	end if

	m.keyboard_dialog.close = true
'}
end sub

sub OnKeyboardDialogClosed()
'{
	m.top.GetScene().dialog = invalid
'}
end sub

sub OnTextBoxSelected()
'{
	m.keyboard_dialog.textEditBox.cursorPosition = -1

	m.top.GetScene().dialog = m.keyboard_dialog
'}
end sub

sub OnAdjustOverscanStateChanged()
'{
	if m.adjust_overscan.menu_state = 0
	'{
		m.adjust_overscan.visible = false
		m.options_columns.SetFocus( true )
	'}
	else if m.adjust_overscan.menu_state = 1
	'{
		m.adjust_overscan.visible = true
		m.adjust_overscan.SetFocus( true )
	'}
	end if
'}
end sub

function OnKeyEvent( key as string, press as boolean ) as boolean
'{
	if press
	'{
		if key = "back"
		'{
			m.top.menu_state = 0	' Hide
		'}
		else if key = "OK"
		'{
			if m.item_selected = 0
			'{
				OnTextBoxSelected()
			'}
			else if m.item_selected = 1
			'{
				if m.global.enable_automatic_subtitles = false
				'{
					m.global.enable_automatic_subtitles = true
					m.auto_subs_icon.text = "<icon>" + chr( 59661 ) + "</icon>"	' Checkbox Checked
				'}
				else
				'{
					m.global.enable_automatic_subtitles = false
					m.auto_subs_icon.text = "<icon>" + chr( 59660 ) + "</icon>"	' Checkbox Unchecked
				'}
				end if
			'}
			else if m.item_selected = 2 or m.item_selected = 3
			'{
				channel_sort_type = m.item_selected - 2
				if ( channel_sort_type = 0 or channel_sort_type = 1 ) and channel_sort_type <> m.global.channel_sort_type
				'{
					if channel_sort_type = 0
					'{
						m.channel_sort_type_1.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked
						m.channel_sort_type_2.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked
					'}
					else
					'{
						m.channel_sort_type_2.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked
						m.channel_sort_type_1.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked
					'}
					end if

					m.global.channel_sort_type = channel_sort_type
				'}
				end if
			'}
			else if m.item_selected = 4
			'{
				if m.global.resume_channel = false
				'{
					m.global.resume_channel = true
					m.resume_channel_icon.text = "<icon>" + chr( 59661 ) + "</icon>"	' Checkbox Checked
				'}
				else
				'{
					m.global.resume_channel = false
					m.resume_channel_icon.text = "<icon>" + chr( 59660 ) + "</icon>"	' Checkbox Unchecked
				'}
				end if
			'}
			else if m.item_selected = 5 or m.item_selected = 6
			'{
				ui_lang = "en"
				if m.item_selected = 6 then ui_lang = "cn"
				if ui_lang <> m.global.ui_lang
				'{
					if ui_lang = "en"
					'{
						m.ui_lang_1.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked
						m.ui_lang_2.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked
					'}
					else
					'{
						m.ui_lang_2.text = "<icon>" + chr( 59663 ) + "</icon>"	' Radio Button Checked
						m.ui_lang_1.text = "<icon>" + chr( 59662 ) + "</icon>"	' Radio Button Unchecked
					'}
					end if

					m.global.ui_lang = ui_lang
				'}
				end if
			'}
			else if m.item_selected = 7
			'{
				m.adjust_overscan.menu_state = 1
			'}
			end if
		'}
		else if key = "up"
		'{
			if m.item_selected = 2 or m.item_selected = 3
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected = 1
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			else if m.item_selected = 4
			'{
				m.options[ m.item_selected ].color = m.button_color
				if m.global.channel_sort_type = 0
				'{
					m.item_selected = 2
				'}
				else
				'{
					m.item_selected = 3
				'}
				end if
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			else if m.item_selected = 5 or m.item_selected = 6
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected = 4
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			else if m.item_selected = 7
			'{
				m.options[ m.item_selected ].color = m.button_color
				if m.global.ui_lang = "en"
				'{
					m.item_selected = 5
				'}
				else
				'{
					m.item_selected = 6
				'}
				end if
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			else if m.item_selected > 0
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected--
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			end if
		'}
		else if key = "down"
		'{
			if m.item_selected = 1
			'{
				m.options[ m.item_selected ].color = m.button_color
				if m.global.channel_sort_type = 0
				'{
					m.item_selected = 2
				'}
				else
				'{
					m.item_selected = 3
				'}
				end if
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			else if m.item_selected = 2 or m.item_selected = 3
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected = 4
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			else if m.item_selected = 4
			'{
				m.options[ m.item_selected ].color = m.button_color
				if m.global.ui_lang = "en"
				'{
					m.item_selected = 5
				'}
				else
				'{
					m.item_selected = 6
				'}
				end if
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			else if m.item_selected = 5 or m.item_selected = 6
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected = 7
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			else if m.item_selected < m.options.Count() - 1
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected++
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			end if
		'}
		else if key = "left"
		'{
			if m.item_selected = 3
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected--
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			else if m.item_selected = 6
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected--
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			end if
		'}
		else if key = "right"
		'{
			if m.item_selected = 2
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected++
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			else if m.item_selected = 5
			'{
				m.options[ m.item_selected ].color = m.button_color
				m.item_selected++
				m.options[ m.item_selected ].color = m.button_selected_color
			'}
			end if
		'}
		end if
	'}
	end if

	return true
'}
end function

sub UpdateLang()
	m.title.text = _tr( "options" )
	m.keyboard_dialog.title = _tr( "feed_url_title" )
	m.label_feed.text = _tr( "feed_url_label" )
	m.auto_subs_label.text = _tr( "enable_automatic_subtitles" )
	m.label_sort.text = _tr( "sort_channels_by" )
	m.stream_type_number.text = _tr( "number" )
	m.stream_type_name.text = _tr( "name" )
	m.resume_channel_label.text = _tr( "resume_channel" )
	m.label_ui_lang.text = _tr( "ui_language" )
	m.overscan_label.text = _tr( "adjust_overscan" )

	m.options[ 1 ].width = m.auto_subs_label.boundingRect()[ "width" ] + 40
	m.auto_subs_bg.width = m.options[ 1 ].width

	m.options[ 4 ].width = m.resume_channel_label.boundingRect()[ "width" ] + 40
	m.resume_channel_bg.width = m.options[ 4 ].width

	m.options[ 7 ].width = m.overscan_label.boundingRect()[ "width" ] + 40
	m.overscan_bg.width = m.options[ 7 ].width
end sub
