<?php

class tprScriptParser {

	private $script;
	private $doc;
	private $xmlScript;
	private $zip;
	private $show;

	public function __construct(tprZipEntry $zipEntry) {
		$this->zip = $zipEntry;
		$this->script = trim($zipEntry->getDocFileAsPlainText());

		//drupal_set_message($this->script);
	}

	public function getMp3ZipEntry() {

		$mp3NameIdx = substr($this->zip->getNameIndex(), 0, -3) . 'mp3' ;
		$mp3ZipEntry = new tprZipEntry($mp3NameIdx, $this->zip->getZipArchive());
		return $mp3ZipEntry;
	}

	public function parse() {
		//drupal_set_message("start to parse");

		// clean up the script first
		$this->script = str_replace(array('“', '”'), '"', $this->script);
		$this->script = str_replace(array('``',"''"), '"', $this->script);

		$this->script = str_replace('–', '-', $this->script);
		$this->script = str_replace('’', "'", $this->script);
		$this->script = str_replace('…', "... ", $this->script);

		//$this->script = str_replace('é', 'eeeee', $this->script);

		//drupal_set_message($this->script);

		$this->script = htmlentities(
		$this->script, ENT_NOQUOTES  , 'UTF-8'
		);


		//drupal_set_message('script: '. $this->script);

		$tok = trim(strtok($this->script, "\n"));

		$this->doc = new DOMDocument();
		$this->doc->formatOutput = true;

		$this->xmlScript = $this->doc->createElement('script');
		$this->doc->appendChild($this->xmlScript);

		while( $tok !== false ) {

			$tok = trim($tok);

			echo "LINE: ", $tok, "\n";
				
			//drupal_set_message("TOK: '" . $tok . "'");
				
			$parseResult = true;
			switch( true ) {

				case 'WEEK' == substr($tok, 0, 4):
					$parseResult = $this->parseWeek($tok);
					break;

				case 'feature' == strtolower(substr($tok, 0, 7)):
					$parseResult = $this->parseFeature($tok);
					break;

				case 'joanne tease' == strtolower(substr($tok, 0, 12)):
					$parseResult = $this->parseTease($tok);
					break;

				case 'joanne intro:' == strtolower(substr($tok, 0, 13)):
					$parseResult = $this->parseIntro($tok);
					break;

				case 'air date' == strtolower(substr($tok, 0, 8)):
					$parseResult = $this->parseAirDate($tok);
					break;

				case 'categories:' == strtolower(substr($tok, 0, 11)):
					$parseResult = $this->parseCategories($tok);
					break;

				case 'ages:' == strtolower(substr($tok, 0, 5)):
					$parseResult = $this->parseAges($tok);
					break;

				case 'joanne bridge:' == strtolower(substr($tok, 0, 14)):
					$parseResult = $this->parseBridge($tok);
					break;

				case 'clip:' == strtolower(substr($tok, 0, 5)):
					$tok = trim(trim(strtok("\n")), '()');
					$parseResult = $this->parseClip($tok);
					break;

				case 'joanne wrap:' == strtolower(substr($tok, 0, 12)):
					$parseResult = $this->parseWrap($tok);
					break;

			} // switch

			if( ! $parseResult )  $this->handleParseError($tok);
				
			$tok = strtok("\n");

		} // while

		$fullText = $this->doc->createElement('fullText', $this->script);
		$this->xmlScript->appendChild($fullText);

		$xml = $this->doc->saveXml();

		try {
			$s = new SimpleXmlElement($xml);
			$this->val($s->show->title, 'title');
			$this->val($s->show->intro, 'intro');
			$this->val($s->show->airDate, 'airDate');
			$this->val($s->show->tease, 'tease');
			$this->val($s->show->clip, 'clip');
			$this->val($s->fullText, 'fullText');
			$this->val($s->week->title, 'week');
		} catch (Exception $e) {
			throw new Exception(
				"Unable to read xml. An element is empty. "
				. $e->getMessage()
				);
		}

		//var_dump( (string)$s->show->airDate . " --- ". (string) $s->show->title . " --- " .(string)$s->show->intro);

		return $xml;
	}

	/**
	 * check if an xml element is empty, which is not allowed.
	 */
	private function val(SimpleXmlElement $x, $elementName ) {

		if( ! trim( (string)$x )) {

			throw new tprScriptParseException(
				"Xml element empty: &lt;$elementName&gt;. For entry: " . $this->zip			
			);
		}
	} //

	private function parseWrap($line) {

		if( ! preg_match('/Joanne Wrap:\s*(.*)\s*\(:?\d+\.?\d*\)/i', $line, $matches) ) {
			return false;
		}

		$wrap = $this->doc->createElement('wrap', $matches[1]);
		$this->show->appendChild($wrap);

		return true;
	}

	private function parseIntro($line) {




		if( ! preg_match('/Joanne Intro:\s+.*?\..*?\.\s+(.*)\s*\(:?\s*\d+\.?\d*\)/i', $line, $matches) ) {
			return false;
		}



		$intro = $this->doc->createElement('intro', $matches[1]);
		$this->show->appendChild($intro);

		return true;
	}

	private function parseBridge($line) {

		if( ! preg_match('/Joanne Bridge:\s*(.*?)\s*\(:?\d+\.?\d*\)/i', $line, $matches) ) {
			return false;
		}

		$bridge = $this->doc->createElement('bridge', $matches[1]);
		$this->show->appendChild($bridge);

		return true;
	}

	private function findTease($line) {

		//		drupal_set_message($line);

		if( ! preg_match('/Joanne Tease:\s*(.*?)\(:?\d+\.?\d*( secs)?\)/i', $line, $matches) ) {
			return false;
		}

		//	var_dump($matches);

		$teaser = trim($matches[1]);

		// remove the last period, and any other periods at the end of the string
		while( substr($teaser, -1 ) == '.' ) {
			$teaser = substr($teaser, 0, -1);
			$teaser = trim($teaser);
		}

		//		var_dump($teaser);

		if( FALSE !== ($pos = strpos($teaser, '?'))  ) {
			return substr($teaser, 0, $pos) . '?';

		} elseif ( preg_match('/([,])[^,]*?([Pp]arent\s+[Rr]eport)\..*?$/',  trim($matches[1]), $m) ) {

			//				var_dump($m);

			$punct = $m[1];
			',' == $punct && $punct = '.';
			$teaser = substr(trim($matches[1]), 0, - (strlen($m[0]))) . $punct;

			return $teaser;

		}  elseif( FALSE !== ($pos = strpos(substr($teaser, 0, -1), '.'))) {

			$t = substr($teaser, 0, $pos) . '.';

			return $t;
				
		}
		return false;
	}






	private function parseTease($line) {

		$teaser = $this->findTease($line);

		if( ! $teaser ) return false;

		$tease = $this->doc->createElement('tease', $teaser);
		$this->show->appendChild($tease);

		return true;
	}


	private function parseAges($line) {

		if( ! preg_match('/Ages:(.*)/i', $line, $matches) ) {
			return false;
		}

		if( ! isset($matches[1]) ) {
			return true; // ignore badly formed Ages line.
		}

		$letters = array_unique(explode(',', $matches[1]));

		if( ! empty($letters) ) {

			$ages = $this->doc->createElement( 'ages' );
			$this->xmlScript->appendChild($ages);

			foreach( $letters as $letter ) {

				if( '' == trim($letter) ) continue;

				$ages->appendChild(
				$this->doc->createElement('age', $this->agesLookup(trim($letter)))
				);
			}
		}

		return true;
	}

	private function parseClip($line) {

		$clip = $this->doc->createElement('clip', $line);

		$this->show->appendChild($clip);

		return true;
	}

	private function parseCategories($line) {

		if( ! preg_match('/Categories:(.*)/i', $line, $matches) ) {
			return false;
		}

		if( ! isset($matches[1]) ) {
			return true; // ignore badly formed Categories line.
		}

		$letters = array_unique(explode(',', $matches[1]));

		if( ! empty($letters) ) {

			$categories = $this->doc->createElement( 'categories' );
			$this->xmlScript->appendChild($categories);

			foreach( $letters as $letter ) {

				if( '' == trim($letter) ) continue;

				$categories->appendChild(
				$this->doc->createElement('category', $this->categoriesLookup(trim($letter)))
				);
			}
		}

		return true;
	}

	private function agesLookup($letterCode) {
		$hash = $this->agesLookupHash();
		if( ! isset($hash[strtoupper($letterCode)])) {

			$nameIdx = $this->zip->getNameIndex();

			throw new tprScriptParseException(
				"An unknown Age code was found: [$letterCode]. Check the Category line in the script. [$nameIdx]"
			);
		}

		return $hash[$letterCode];
	}

	private function categoriesLookup($letterCode) {
		$hash = $this->categoriesLookupHash();
		if( ! isset($hash[strtoupper($letterCode)])) {

			$nameIdx = $this->zip->getNameIndex();

			throw new tprScriptParseException(
				"Entry: $nameIdx -- An unknown Category code was found: [$letterCode]. Check the Category line in the script."
			);
		}

		return $hash[$letterCode];
	}

	private function agesLookupHash() {
		return array(
			'N' => 'Newborn',
			'I' => 'Infant',
			'IT' => 'Toddler',
			'PS' => 'Preschool',
			'ES' => 'Early School',
			'PT' => 'Preteen',
			'T' => 'Teen',
		);
	}

	private function categoriesLookupHash() {
		return array(
				'B' => 'Behaviour',
				'D' => 'Development',
				'SF' =>'Safety',
				'E' => 'Education',
				'N' => 'Nutrition',
				'F' => 'Family Life',
				'H' => 'Health',
				'LS' => 'Limit Setting',
				'KC' => 'Kids Culture',
				'SL' => 'Sleep',
				'F'  => 'Family',
		);
	}

	private function parseAirDate($line) {

		if( ! preg_match('/Air Date:\s+(.*)/i', $line, $matches) ) return false;

		$date = strtotime($matches[1]);

		if( false === $date ) {
			throw new tprScriptParseException(
				"The air date is not a correctly formatted date: {$matches[1]} for entry: $this->zip"
			);
			return false;
		}
		// this is the format that scheduler module is expecting
		$airDate = $this->doc->createElement('airDate', date('Y-m-d H:i:s', $date));
		$this->show->appendChild($airDate);
			
		return true;
	}

	private function parseWeek($line) {

		//drupal_set_message("FOO");
		//fooooo();


		if( !preg_match('/^WEEK\s+(\d+)\s+-\s+(.*)$/', $line, $matches) ) {

				
			var_dump($matches);
				
			//drupal_set_message("Unable to parse Week line.");
			return false;
		}

		$weekNumber = $matches[1];
		$weekTitle = $matches[2];
		$week = $this->doc->createElement('week');


		$week->appendChild($this->doc->createElement('title', $weekTitle));
		$week->appendChild($this->doc->createElement('number', $weekNumber));

		$this->xmlScript->appendChild($week);

		return true;
	}

	private function handleParseError($line) {
		$err = "Unable to parse line: `$line' for entry: {$this->zip}\n";
		throw new tprScriptParseException($err);
	}

	private function parseFeature($line) {

		//		echo " feature LINE: ", $line, "\n";

		if( ! preg_match(
		//'/(\d+)-(\d+)\s+"([^"]+)",\s+"?([^,]+),\s+.*\s+"([^"]+)"/',
		//'/Feature:?\s+(\d+)\s*-?\s*(\d+)\s+-?\s+"([^"]+)"/',
			'/Feature:?\s+(\d{4})\s*-\s*(\d)\s*-?\s*"(.*?)".*/i', 
		$line,
		$matches
		) ) return false;

		$this->show = $this->doc->createElement('show');
		$this->xmlScript->appendChild($this->show);
		$this->show->appendChild($this->doc->createElement('title', $matches[3]));

		return true;
	}
}


class tprScriptParseException extends Exception {
}

