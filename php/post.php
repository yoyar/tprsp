#!/usr/bin/php
<?php

if( empty($argv[1]) ) {
	echo "\tThe first argument must be a filename\n";
	usage();
}

function usage() {
	echo "\t", 'Usage: ./', basename(__FILE__), ' <word_filename>', "\n";
	exit();
} 

function do_post_request($url, $data, $optional_headers = null)
{
  /*
   * Credit to Wez
   * http://wezfurlong.org/blog/2006/nov/http-post-from-php-without-curl/
   */
  $params = array('http' => array(
              'method' => 'POST',
              'content' => $data
            ));
  if ($optional_headers !== null) {
    $params['http']['header'] = $optional_headers;
  }
  $ctx = stream_context_create($params);
  $fp = @fopen($url, 'rb', false, $ctx);
  if (!$fp) {
    throw new Exception("Problem with $url, $php_errormsg");
  }
  $response = @stream_get_contents($fp);
  if ($response === false) {
    throw new Exception("Problem reading data from $url, $php_errormsg");
  }
  return $response;
}

echo do_post_request(
	'http://localhost:88/word2json.php', 
	file_get_contents($argv[1])
);

