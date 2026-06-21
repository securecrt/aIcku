'
'	aIcku - another IPTV client for Roku OS
'	Copyright (C) 2026 Xin Wang
'	Released under the GPLv3 license.
'

sub init()
    m.top.functionName = "runServer"
end sub

sub runServer()
    messagePort = CreateObject("roMessagePort")
    tcpListen = CreateObject("roStreamSocket")
    tcpListen.setMessagePort(messagePort)
    
    addr = CreateObject("roSocketAddress")
    addr.setPort(8090)
    tcpListen.setAddress(addr)
    
    tcpListen.notifyReadable(true)
    tcpListen.listen(4)
    
    if not tcpListen.eOK()
        return
    end if
    
    connections = {}
    
    while true
        event = wait(0, messagePort)
        if type(event) = "roSocketEvent"
            changedID = event.getSocketID()
            
            if changedID = tcpListen.getID() and tcpListen.isReadable()
                newConnection = tcpListen.accept()
                if newConnection <> invalid
                    newConnection.notifyReadable(true)
                    newConnection.setMessagePort(messagePort)
                    connections[Stri(newConnection.getID()).Trim()] = {
                        socket: newConnection,
                        buffer: ""
                    }
                end if
            else
                connKey = Stri(changedID).Trim()
                conn = connections[connKey]
                if conn <> invalid and conn.socket.isReadable()
                    buf = CreateObject("roByteArray")
                    buf[1024] = 0
                    received = conn.socket.receive(buf, 0, 1024)
                    if received > 0
                        chunk = buf.ToAsciiString().Mid(0, received)
                        conn.buffer = conn.buffer + chunk
                        
                        ' Check if we received the end of HTTP headers
                        if Instr(1, conn.buffer, Chr(13) + Chr(10) + Chr(13) + Chr(10)) > 0 or Instr(1, conn.buffer, Chr(10) + Chr(10)) > 0
                            handleHttpRequest(conn)
                            conn.socket.close()
                            connections.Delete(connKey)
                        end if
                    else if received <= 0
                        conn.socket.close()
                        connections.Delete(connKey)
                    end if
                end if
            end if
        end if
    end while
end sub

sub handleHttpRequest(conn as Object)
    requestStr = conn.buffer
    
    lineRegex = CreateObject("roRegEx", "\r?\n", "")
    lines = lineRegex.Split(requestStr)
    if lines.Count() = 0 then return
    
    requestLine = lines[0]
    spaceRegex = CreateObject("roRegEx", " ", "")
    parts = spaceRegex.Split(requestLine)
    if parts.Count() < 2 then return
    
    method = parts[0]
    path = parts[1]
    
    ' Handle OPTIONS preflight request (CORS)
    if method = "OPTIONS"
        response = "HTTP/1.1 200 OK" + Chr(13) + Chr(10)
        response = response + "Access-Control-Allow-Origin: *" + Chr(13) + Chr(10)
        response = response + "Access-Control-Allow-Methods: GET, POST, OPTIONS" + Chr(13) + Chr(10)
        response = response + "Access-Control-Allow-Headers: Content-Type" + Chr(13) + Chr(10)
        response = response + "Connection: close" + Chr(13) + Chr(10) + Chr(13) + Chr(10)
        
        sendResponse(conn.socket, response)
        return
    end if
    
    ' Default response
    responseBody = "{""success"":false}"
    
    if path = "/status"
        state = m.top.video_state
        title = m.top.video_title
        
        ' Strip double quotes from title to keep JSON safe
        quoteRegex = CreateObject("roRegEx", """", "")
        cleanTitle = quoteRegex.ReplaceAll(title, "")
        
        isPlayingStr = "false"
        if state = "playing" then isPlayingStr = "true"
        
        responseBody = "{""playing"":" + isPlayingStr + ",""state"":""" + state + """,""title"":""" + cleanTitle + """}"
    else if path = "/stop"
        m.top.control_command = "stop"
        responseBody = "{""success"":true}"
    else if path.Left(13) = "/play?number="
        numStr = path.Mid(13)
        m.top.control_command = "play_number:" + numStr
        responseBody = "{""success"":true}"
    else if path = "/lock"
        m.top.control_command = "lock"
        responseBody = "{""success"":true}"
    else if path = "/unlock"
        m.top.control_command = "unlock"
        responseBody = "{""success"":true}"
    end if
    
    response = "HTTP/1.1 200 OK" + Chr(13) + Chr(10)
    response = response + "Content-Type: application/json" + Chr(13) + Chr(10)
    response = response + "Access-Control-Allow-Origin: *" + Chr(13) + Chr(10)
    response = response + "Connection: close" + Chr(13) + Chr(10) + Chr(13) + Chr(10)
    response = response + responseBody
    
    sendResponse(conn.socket, response)
end sub

sub sendResponse(socket as Object, data as String)
    buf = CreateObject("roByteArray")
    buf.FromAsciiString(data)
    socket.send(buf, 0, buf.Count())
end sub
