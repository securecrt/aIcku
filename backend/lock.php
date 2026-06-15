<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$statusFile = 'status.json';

// Handle OPTIONS preflight request for CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

// POST request: Save configuration (from Phone Web UI)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $locked = isset($input['locked']) ? (bool)$input['locked'] : false;
    
    // Preserve existing client info if present
    $data = ['locked' => $locked];
    if (file_exists($statusFile)) {
        $existing = json_decode(file_get_contents($statusFile), true);
        if (isset($existing['client_ip'])) {
            $data['client_ip'] = $existing['client_ip'];
            $data['client_port'] = $existing['client_port'];
        }
    }
    file_put_contents($statusFile, json_encode($data));
    echo json_encode(['success' => true, 'locked' => $locked]);
    exit;
}

// GET request
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Handle Roku IP Registration
    if (isset($_GET['register']) && $_GET['register'] === 'true') {
        $ip = isset($_GET['ip']) ? filter_var($_GET['ip'], FILTER_VALIDATE_IP) : '';
        $port = isset($_GET['port']) ? (int)$_GET['port'] : 8090;
        
        if ($ip) {
            $data = ['locked' => false];
            if (file_exists($statusFile)) {
                $existing = json_decode(file_get_contents($statusFile), true);
                if (isset($existing['locked'])) {
                    $data['locked'] = (bool)$existing['locked'];
                }
            }
            $data['client_ip'] = $ip;
            $data['client_port'] = $port;
            file_put_contents($statusFile, json_encode($data));
            echo json_encode(['success' => true, 'registered' => "$ip:$port"]);
            exit;
        }
        echo json_encode(['success' => false, 'error' => 'Invalid IP']);
        exit;
    }

    // Default GET status check
    $locked = false;
    $clientIp = null;
    $clientPort = null;
    if (file_exists($statusFile)) {
        $data = json_decode(file_get_contents($statusFile), true);
        if (isset($data['locked'])) {
            $locked = (bool)$data['locked'];
        }
        if (isset($data['client_ip'])) {
            $clientIp = $data['client_ip'];
            $clientPort = (int)$data['client_port'];
        }
    }
    
    $response = ['locked' => $locked];
    if ($clientIp !== null) {
        $response['client_ip'] = $clientIp;
        $response['client_port'] = $clientPort;
    }
    echo json_encode($response);
    exit;
}
?>
