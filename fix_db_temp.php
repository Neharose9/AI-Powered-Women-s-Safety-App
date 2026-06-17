<?php
$host = "localhost";
$user = "root";  
$pass = "RESHMANEHA";  
$dbname = "safetyapp";

$conn = new mysqli($host, $user, $pass, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

echo "Fixing database...<br>";

// 1. Check if column exists
$result = $conn->query("SHOW COLUMNS FROM users LIKE 'verification_code'");
if ($result->num_rows == 0) {
    if ($conn->query("ALTER TABLE users ADD COLUMN verification_code VARCHAR(6) NULL")) {
        echo "✅ Added verification_code column.<br>";
    } else {
        echo "❌ Error adding verification_code: " . $conn->error . "<br>";
    }
} else {
    echo "ℹ️ verification_code already exists.<br>";
}

// 2. Check is_email_verified
$result = $conn->query("SHOW COLUMNS FROM users LIKE 'is_email_verified'");
if ($result->num_rows == 0) {
    if ($conn->query("ALTER TABLE users ADD COLUMN is_email_verified INT DEFAULT 0")) {
        echo "✅ Added is_email_verified column.<br>";
    } else {
        echo "❌ Error adding is_email_verified: " . $conn->error . "<br>";
    }
} else {
    echo "ℹ️ is_email_verified already exists.<br>";
}

$conn->close();
echo "Done.";
?>
