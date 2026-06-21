<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$cacheFile = 'epg_cache.xml';
$cacheLifetime = 43200; // 12 hours cache

// Fallback to system temp directory if local folder is not writable
if (!is_writable('.') && function_exists('sys_get_temp_dir')) {
    $tempDir = sys_get_temp_dir();
    if (is_writable($tempDir)) {
        $cacheFile = $tempDir . DIRECTORY_SEPARATOR . 'epg_cache.xml';
    }
}

// Helper function to parse XMLTV times
function parseXmltvTime($timeStr) {
    $timeStr = trim($timeStr);
    if (strlen($timeStr) < 14) {
        return 0;
    }
    $year = substr($timeStr, 0, 4);
    $month = substr($timeStr, 4, 2);
    $day = substr($timeStr, 6, 2);
    $hour = substr($timeStr, 8, 2);
    $minute = substr($timeStr, 10, 2);
    $second = substr($timeStr, 12, 2);
    
    $timezonePart = trim(substr($timeStr, 14));
    try {
        $dateStr = $year . $month . $day . $hour . $minute . $second . ' ' . (empty($timezonePart) ? '+0000' : $timezonePart);
        $dt = DateTime::createFromFormat('YmdHis O', $dateStr);
        if ($dt) {
            return $dt->getTimestamp();
        }
    } catch (Exception $e) {}
    return 0;
}

// Robust helper to fetch EPG contents with User-Agent, redirect support, and fallbacks
function fetchUrlContent($url) {
    $userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    
    // Method 1: cURL (handling open_basedir restrictions)
    if (extension_loaded('curl')) {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
        curl_setopt($ch, CURLOPT_MAXREDIRS, 5);
        curl_setopt($ch, CURLOPT_TIMEOUT, 30);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
        curl_setopt($ch, CURLOPT_USERAGENT, $userAgent);
        
        $data = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        
        // Manual redirect detection in case follow_location is disabled/blocked by PHP configuration
        if (($httpCode == 301 || $httpCode == 302) && empty($data)) {
            $redirectUrl = curl_getinfo($ch, CURLINFO_REDIRECT_URL);
            if ($redirectUrl) {
                curl_close($ch);
                return fetchUrlContent($redirectUrl);
            }
        }
        curl_close($ch);
        
        if ($data !== false && $httpCode == 200) {
            return $data;
        }
    }
    
    // Method 2: file_get_contents with stream context
    $opts = [
        'http' => [
            'method' => 'GET',
            'header' => "User-Agent: $userAgent\r\n",
            'follow_location' => 1,
            'max_redirects' => 5,
            'timeout' => 30
        ],
        'ssl' => [
            'verify_peer' => false,
            'verify_peer_name' => false,
        ]
    ];
    $context = stream_context_create($opts);
    return @file_get_contents($url, false, $context);
}

// Function to fetch and refresh cache
function refreshCache($cacheFile) {
    $url = 'http://epg.51zmt.top:8000/e.xml.gz';
    $data = fetchUrlContent($url);
    
    if ($data !== false && !empty($data)) {
        $isGz = (substr($data, 0, 2) === "\x1f\x8b");
        $xmlData = $isGz ? @gzdecode($data) : $data;
        if ($xmlData !== false && !empty($xmlData)) {
            $written = @file_put_contents($cacheFile, $xmlData);
            if ($written !== false) {
                return true;
            }
        }
    }
    return false;
}

// If cache file is missing or expired, try to update it
$cacheExists = file_exists($cacheFile);
$cacheExpired = $cacheExists ? ((time() - filemtime($cacheFile)) >= $cacheLifetime) : true;
if (!$cacheExists || $cacheExpired) {
    refreshCache($cacheFile);
}

// Case 1: Channel lookup request (returns JSON)
if (isset($_GET['channel'])) {
    header("Content-Type: application/json; charset=utf-8");
    $channelName = trim($_GET['channel']);
    
    // 1. Parse iptv.m3u to map display name to EPG channel ID
    $epgChannelId = $channelName;
    $m3uFile = 'iptv.m3u';
    if (file_exists($m3uFile)) {
        $m3uContent = file_get_contents($m3uFile);
        $lines = explode("\n", $m3uContent);
        for ($i = 0; $i < count($lines); $i++) {
            $line = trim($lines[$i]);
            if (strpos($line, '#EXTINF') === 0) {
                // Extract display name after comma
                $commaPos = strrpos($line, ',');
                if ($commaPos !== false) {
                    $displayName = trim(substr($line, $commaPos + 1));
                    if ($displayName === $channelName) {
                        // Extract tvg-name or tvg-id
                        preg_match('/tvg-name="([^"]*)"/i', $line, $matchesName);
                        preg_match('/tvg-id="([^"]*)"/i', $line, $matchesId);
                        if (!empty($matchesId[1])) {
                            $epgChannelId = $matchesId[1];
                        } else if (!empty($matchesName[1])) {
                            $epgChannelId = $matchesName[1];
                        }
                        break;
                    }
                }
            }
        }
    }
    
    // 2. Parse XMLTV to find current program
    $currentProgram = null;
    $found = false;
    $now = time();
    
    if (file_exists($cacheFile)) {
        $reader = new XMLReader();
        if ($reader->open($cacheFile)) {
            while ($reader->read()) {
                if ($reader->nodeType == XMLReader::ELEMENT && $reader->name === 'programme') {
                    $channelAttr = $reader->getAttribute('channel');
                    if ($channelAttr === $epgChannelId) {
                        $startAttr = $reader->getAttribute('start');
                        $stopAttr = $reader->getAttribute('stop');
                        
                        $startTs = parseXmltvTime($startAttr);
                        $stopTs = parseXmltvTime($stopAttr);
                        
                        if ($now >= $startTs && $now < $stopTs) {
                            $xmlNode = new SimpleXMLElement($reader->readOuterXml());
                            if (isset($xmlNode->title)) {
                                $currentProgram = (string)$xmlNode->title;
                                $found = true;
                                break;
                            }
                        }
                    }
                }
            }
            $reader->close();
        }
    }
    
    echo json_encode([
        'success' => true,
        'channel' => $channelName,
        'epg_channel' => $epgChannelId,
        'program' => $currentProgram,
        'found' => $found
    ]);
    exit;
}

// Case 2: Standard full EPG request (returns XML)
header("Content-Type: text/xml; charset=utf-8");
if (file_exists($cacheFile)) {
    echo file_get_contents($cacheFile);
    exit;
}

http_response_code(404);
echo "EPG XML data not available.";
exit;

