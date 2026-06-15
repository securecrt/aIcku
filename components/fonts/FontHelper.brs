'
'	aIcku - another IPTV client for Roku OS
'	Copyright (C) 2024 Eric Kutcher
'	Copyright (C) 2026 Xin Wang
'	Released under the GPLv3 license.
'
'	Chinese Font Helper
'	Creates Font objects using the bundled Chinese font.
'

function CreateChineseFont( size as integer ) as object
'{
	font_obj = CreateObject( "roSGNode", "Font" )
	font_obj.uri = "pkg:/components/fonts/NotoSansSC-Regular.ttf"
	font_obj.size = size
	return font_obj
'}
end function

function GetChineseFontUri() as string
'{
	return "pkg:/components/fonts/NotoSansSC-Regular.ttf"
'}
end function

function _tr( key as string ) as string
	globalNode = m.global
	if globalNode <> invalid and globalNode.translations <> invalid
		if globalNode.translations.DoesExist( key )
			return globalNode.translations[ key ]
		end if
		normalizedKey = LCase( key )
		if normalizedKey = "live tv"
			normalizedKey = "live_tv"
		end if
		if globalNode.translations.DoesExist( normalizedKey )
			return globalNode.translations[ normalizedKey ]
		end if
	end if
	return key
end function
