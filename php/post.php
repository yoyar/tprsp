#!/usr/bin/php
<?php

require_once 'do_post_request.inc.php';

if( empty($argv[1]) ) {
	echo "\tThe first argument must be a filename\n";
	usage();
}

$url = 'http://localhost:88/tprsp/php/word2json.php';

function usage() {
	echo "\t", 'Usage: ./', basename(__FILE__), ' <word_filename>', "\n";
	exit();
} 

echo do_post_request(
	$url,
	file_get_contents($argv[1])
);

