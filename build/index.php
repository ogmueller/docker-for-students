<?php

$phpVersion = phpversion();
[,$phpPort] = explode(':', $_SERVER['HTTP_HOST']);
$phpMyAdminPort = $_SERVER['PHPMYADMIN_PORT'];
$webMailPort = $_SERVER['WEBMAIL_PORT'];
$dsn = 'mysql:host=db;dbname=information_schema;char=utf8mb4';
$warning = [];
$error = [];

// check database
try {
	$db = new PDO($dsn, 'root', '');
	$query = 'SELECT schema_name FROM schemata WHERE schema_name NOT IN ("information_schema", "mysql", "performance_schema")';
	$list = [];
	foreach( $db->query($query) as $name ) {
		$list[] = $name['schema_name'];
	}
	if(empty($list)) {
		$warning[] = 'You have not created any database yet.';
	}
} catch (\PDOException $e) {
	$error[] = 'Not able to connect to database. Maybe it is not up and running.<br/><br/>'.$e->getMessage();
}

?><html>
<head>
<title>PHP</title>
<link rel="stylesheet" href="https://cdn.rawgit.com/Chalarangelo/mini.css/v3.0.1/dist/mini-default.min.css">
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
.card {
	align-self: flex-start;
}
</style>
</head>
<body>
<header class="sticky"><h1>PHP v<?=$phpVersion?> on Docker</h1></header>
    <div class="row">
	    <div class="card">
    		<div class="section"><a href="/php/">Your PHP</a></div>
    		<div class="section">You can access your PHP project files here. Just put all your files in the <code>/php</code> folder.<br/><br/>
    		A demo script called <a href="/php/phpinfo.php">phpinfo.php</a> will show you the current PHP version, configuration and environment.
    		</div>
    		<div class="section">Port: <?=$phpPort?></div>
    	</div>
	    <div class="card">
    		<div class="section"><a href="http://localhost:<?=$phpMyAdminPort?>">phpMyAdmin</a></div>
    		<div class="section">MariaDB is our database management system. You can easily access and manage it with phpMyAdmin using your web browser. phpMyAdmin allows you to select, insert, update and delete data, You can create and drop tables or backup and restore whole databases.</div>
    		<div class="section">Port: <?=$phpMyAdminPort?></div>
    	</div>
    	<div class="card">
    		<div class="section"><a href="http://localhost:<?=$webMailPort?>">Webmail</a></div>
			<div class="section">All emails should be caught by mailhog. We want to make sure, that we don't spam anybody by accident.<br>
If necessary those emails can also be "released" in the UI and received by an email client.</div>
    		<div class="section">Port: <?=$webMailPort?></div>
    	</div>
    </div>
    <?php
    if(!empty($warning) || !empty($error)) {
    	echo '
		<div class="row">';
			foreach ($warning as $text) {
	    		echo '<div class="card warning">
		    		<div class="section">Warning</div>
					<div class="section">'.$text.'</div>
				</div>';
			}
			foreach ($error as $text) {
	    		echo '<div class="card error">
		    		<div class="section">Error</div>
					<div class="section">'.$text.'</div>
				</div>';
			}
			echo '
		</div>';
    }
    ?>
</body>
</html>
