<?php

/**
 * Perhaps a bit of a naive attempt at parsing some text using an array of regular expressions.
 */

error_reporting(E_ALL & ~E_NOTICE);

/* try to capture foo, stuff in the middle, and the bracketed number at the end */
$line = 'foo stuff in the middle (4.4)';

$regexes = array(
	array('name' => 'foo', 'regex' => '/^foo/', 'backref_idx' => 0),
	array('name' => 'stuff in middle', 'regex' => '/(.*?)\(:?\d+\.?\d*\)/', 'backref_idx' => 1),
	array('name' => 'number at end', 'regex' => '/\(:?\d+\.?\d*\)/', 'backref_idx' => 0)
);

$parser = new tprLineParser($line, $regexes);
$parser->parse();

class tprLineParser {
	
	private $line;
	private $regexes;
	
	function __construct($line, $regexes) {
		$this->line = $line;
		$this->regexes = $regexes;
	}
	
	function parse() {
		
		$offset = 0;
		
		while( $pattern = array_shift($this->regexes) ) {
		
			preg_match($pattern['regex'], $this->line, $matches, PREG_OFFSET_CAPTURE, $offset);
			
			if( empty($matches)) {				
				echo 'Unable to find ', $pattern['name'], " while parsing: ", substr($this->line, $offset), "\n";
				continue;
			} 
			
			$match = $matches[$pattern['backref_idx']];
			
			$offset = $offset + strlen($match[0]);
			
			echo $pattern['name'], ": ", $match[0], "\n";
		
		}
	}
}



