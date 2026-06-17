<?php
$host = "localhost";
$user = "root";  
$pass = "RESHMANEHA";  
$dbname = "safetyapp";

$conn = new mysqli($host, $user, $pass, $dbname);

if ($conn->connect_error) {
    die(json_encode(["success" => false, "message" => "Connection failed: " . $conn->connect_error]));
}

// Ensure the columns exist
$queries = [
    "ALTER TABLE users ADD COLUMN IF NOT EXISTS verification_code VARCHAR(6) NULL",
    "ALTER TABLE users ADD COLUMN IF NOT EXISTS is_email_verified INT DEFAULT 0"
];

foreach ($queries as $sql) {
    if (!$conn->query($sql)) {
        echo "Error: " . $conn->error . "\n";
    }
}

// Show current columns
$result = $conn->query("DESCRIBE users");
while ($row = $result->fetch_assoc()) {
    echo $row['Field'] . " (" . $row['Type'] . ")\n";
}

$conn->close();
?>
