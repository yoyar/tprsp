<?php

$include_path = ini_get('include_path');
ini_set('include_path', realpath('../../..') . ":$include_path");

require_once 'tprZipEntriesIterator.php';
require_once 'tprDocFileFilterIterator.php';
require_once 'tprScriptParser.php';

$filename = '/home/matt/Desktop/tpr-test-zips/testing.zip';

//$iter = new tprZipEntriesIterator($filename);
//
//foreach( $iter as $key => $value) {
//	
//	echo "Key: $key Value: $value \n";
//}

$iter = 
		new tprDocFileFilterIterator(
		new tprZipEntriesIterator($filename)
);

foreach($iter as $key => $zipEntry) {
	try {
		$parser = new tprScriptParser($zipEntry);
		$xml = $parser->parse();
		//echo $xml, "\n-----------------------------------------------------------\n";
	} catch (tprScriptParseException $e ) {
		throw new Exception('Unable to parse script.' . $e->getMessage(), 9);
	} 
}


